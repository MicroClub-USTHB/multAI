"""
Integration tests for the Photo Approval Flow.

These tests use a real PostgreSQL database but mock MinIO and NATS.
They verify the full lifecycle of a group photo requiring multi-user approval.
"""

import uuid
import datetime
from unittest.mock import AsyncMock, MagicMock

import pytest
from sqlalchemy import text

from app.service.photo_approval import PhotoApprovalService
from db.generated import user as user_queries
from db.generated import staff_user as staff_queries
from db.generated import events as event_queries
from db.generated import photos as photo_queries
from db.generated import photo_approvals as approval_queries


# ===========================================================================
# Fixtures
# ===========================================================================


@pytest.fixture
def mock_storage() -> AsyncMock:
    from app.service.staged_upload_storage import StagedUploadStorageService

    svc = MagicMock(spec=StagedUploadStorageService)
    svc.delete_storage_key = AsyncMock()
    return svc


@pytest.fixture
def mock_audit() -> AsyncMock:
    from app.service.audit import AuditService

    svc = MagicMock(spec=AuditService)
    svc.create_record = AsyncMock()
    return svc


@pytest.fixture
async def db_conn():
    from sqlalchemy.ext.asyncio import create_async_engine
    from app.core.config import settings

    url = f"postgresql+asyncpg://{settings.POSTGRES_USER}:{settings.POSTGRES_PASSWORD}@{settings.POSTGRES_HOST}:{settings.POSTGRES_PORT}/{settings.POSTGRES_DB}"
    engine = create_async_engine(url, pool_pre_ping=True)
    async with engine.connect() as conn:
        yield conn
    await engine.dispose()


@pytest.fixture
def approval_service(
    mock_storage: AsyncMock,
    mock_audit: AsyncMock,
    db_conn,
) -> PhotoApprovalService:
    return PhotoApprovalService(
        photo_approval_querier=approval_queries.AsyncQuerier(db_conn),
        photo_querier=photo_queries.AsyncQuerier(db_conn),
        storage_service=mock_storage,
        audit_service=mock_audit,
    )


# ===========================================================================
# Tests
# ===========================================================================

# Mark these as integration tests (require DB)
pytestmark = pytest.mark.integration


@pytest.mark.asyncio
async def test_group_photo_approval_lifecycle(
    approval_service: PhotoApprovalService,
    mock_storage: AsyncMock,
    mock_audit: AsyncMock,
    db_conn,
) -> None:
    """Test that a photo becomes 'approved' only when all pending approvals are approved."""
    event_id = uuid.uuid4()
    photo_id = uuid.uuid4()

    sq = staff_queries.AsyncQuerier(db_conn)
    uq = user_queries.AsyncQuerier(db_conn)
    eq = event_queries.AsyncQuerier(db_conn)
    pq = photo_queries.AsyncQuerier(db_conn)
    aq = approval_queries.AsyncQuerier(db_conn)

    staff = await sq.create_admin(
        email=f"admin-{uuid.uuid4()}@test.com", password="hash"
    )
    event_creator_id = staff.id

    user_ids = []
    for i in range(3):
        u = await uq.create_user(
            email=f"approval-{uuid.uuid4()}@test.com", hashed_password="hash"
        )
        user_ids.append(u.id)

    uploader_id, user1_id, user2_id = user_ids

    event = await eq.create_event(
        event_queries.CreateEventParams(
            name="Approval Test Event",
            event_code=f"APP{str(event_id)[:4]}",
            event_date=datetime.datetime.now(datetime.timezone.utc),
            end_date=datetime.datetime.now(datetime.timezone.utc)
            + datetime.timedelta(days=1),
            status="scheduled",
            created_by=event_creator_id,
        )
    )
    event_id = event.id

    await pq.create_photo(
        photo_queries.CreatePhotoParams(
            event_id=event_id,
            storage_key="test/group.jpg",
            source="direct",
            taken_at=None,
            day_number=None,
            visibility="public",
        )
    )

    # Set status to pending and id
    await db_conn.execute(
        text(
            f"UPDATE photos SET id = '{photo_id}', status = 'pending', uploaded_by = '{uploader_id}' WHERE storage_key = 'test/group.jpg'"
        )
    )

    await aq.create_photo_approval(
        photo_id=photo_id, user_id=user1_id, decision="pending"
    )
    await aq.create_photo_approval(
        photo_id=photo_id, user_id=user2_id, decision="pending"
    )

    try:
        # 2. User 1 approves
        result1 = await approval_service.decide(
            photo_id=photo_id, user_id=user1_id, decision="approved"
        )
        assert result1 == "pending", (
            "Photo should remain pending because User 2 hasn't approved yet"
        )

        photo = await photo_queries.AsyncQuerier(db_conn).get_photo_by_id(id=photo_id)
        assert photo.status == "pending"

        # 3. User 2 approves
        result2 = await approval_service.decide(
            photo_id=photo_id, user_id=user2_id, decision="approved"
        )
        assert result2 == "approved", (
            "Photo should be approved since all users approved"
        )

        photo = await photo_queries.AsyncQuerier(db_conn).get_photo_by_id(id=photo_id)
        assert photo.status == "approved"

    finally:
        # 4. Cleanup
        await db_conn.execute(
            text(f"DELETE FROM photo_approvals WHERE photo_id = '{photo_id}'")
        )
        await db_conn.execute(text(f"DELETE FROM photos WHERE id = '{photo_id}'"))
        await db_conn.execute(text(f"DELETE FROM events WHERE id = '{event_id}'"))
        await db_conn.execute(
            text(f"DELETE FROM users WHERE id IN ('{user1_id}', '{user2_id}')")
        )
        await db_conn.execute(
            text(f"DELETE FROM staff_users WHERE id = '{event_creator_id}'")
        )
        await db_conn.commit()


@pytest.mark.asyncio
async def test_group_photo_rejection_deletes_storage(
    approval_service: PhotoApprovalService,
    mock_storage: AsyncMock,
    db_conn,
) -> None:
    """Test that a single rejection sets the photo to 'rejected' and deletes from MinIO."""
    event_id = uuid.uuid4()
    photo_id = uuid.uuid4()

    sq = staff_queries.AsyncQuerier(db_conn)
    uq = user_queries.AsyncQuerier(db_conn)
    eq = event_queries.AsyncQuerier(db_conn)
    pq = photo_queries.AsyncQuerier(db_conn)
    aq = approval_queries.AsyncQuerier(db_conn)

    staff = await sq.create_admin(
        email=f"admin-{uuid.uuid4()}@test.com", password="hash"
    )
    event_creator_id = staff.id

    user_ids = []
    for i in range(2):
        u = await uq.create_user(
            email=f"reject-{uuid.uuid4()}@test.com", hashed_password="hash"
        )
        user_ids.append(u.id)

    uploader_id, user1_id = user_ids

    event = await eq.create_event(
        event_queries.CreateEventParams(
            name="Reject Test Event",
            event_code=f"REJ{str(event_id)[:4]}",
            event_date=datetime.datetime.now(datetime.timezone.utc),
            end_date=datetime.datetime.now(datetime.timezone.utc)
            + datetime.timedelta(days=1),
            status="scheduled",
            created_by=event_creator_id,
        )
    )
    event_id = event.id

    await pq.create_photo(
        photo_queries.CreatePhotoParams(
            event_id=event_id,
            storage_key="test/reject.jpg",
            source="direct",
            taken_at=None,
            day_number=None,
            visibility="public",
        )
    )

    await db_conn.execute(
        text(
            f"UPDATE photos SET id = '{photo_id}', status = 'pending', uploaded_by = '{uploader_id}' WHERE storage_key = 'test/reject.jpg'"
        )
    )

    await aq.create_photo_approval(
        photo_id=photo_id, user_id=user1_id, decision="pending"
    )

    try:
        # 2. User 1 rejects
        result = await approval_service.decide(
            photo_id=photo_id, user_id=user1_id, decision="rejected"
        )

        # 3. Verify
        assert result == "rejected"
        mock_storage.delete_storage_key.assert_called_once_with("test/reject.jpg")

        photo = await photo_queries.AsyncQuerier(db_conn).get_photo_by_id(id=photo_id)
        assert photo.status == "rejected"

    finally:
        await db_conn.execute(
            text(f"DELETE FROM photo_approvals WHERE photo_id = '{photo_id}'")
        )
        await db_conn.execute(text(f"DELETE FROM photos WHERE id = '{photo_id}'"))
        await db_conn.execute(text(f"DELETE FROM events WHERE id = '{event_id}'"))
        await db_conn.execute(
            text(f"DELETE FROM users WHERE id IN ('{uploader_id}', '{user1_id}')")
        )
        await db_conn.execute(
            text(f"DELETE FROM staff_users WHERE id = '{event_creator_id}'")
        )
        await db_conn.commit()


@pytest.mark.asyncio
async def test_rejection_removes_photo_from_every_user(
    approval_service: PhotoApprovalService,
    mock_storage: AsyncMock,
    db_conn,
) -> None:
    """A rejection must delete all approval rows and hide the photo from lists."""
    event_id = uuid.uuid4()
    photo_id = uuid.uuid4()

    sq = staff_queries.AsyncQuerier(db_conn)
    uq = user_queries.AsyncQuerier(db_conn)
    eq = event_queries.AsyncQuerier(db_conn)
    pq = photo_queries.AsyncQuerier(db_conn)
    aq = approval_queries.AsyncQuerier(db_conn)

    staff = await sq.create_admin(
        email=f"admin-{uuid.uuid4()}@test.com", password="hash"
    )
    event_creator_id = staff.id

    user_ids = []
    for _ in range(3):
        u = await uq.create_user(
            email=f"reject-all-{uuid.uuid4()}@test.com", hashed_password="hash"
        )
        user_ids.append(u.id)

    uploader_id, rejecter_id, other_id = user_ids

    event = await eq.create_event(
        event_queries.CreateEventParams(
            name="Reject All Test Event",
            event_code=f"RA{str(event_id)[:6]}",
            event_date=datetime.datetime.now(datetime.timezone.utc),
            end_date=datetime.datetime.now(datetime.timezone.utc)
            + datetime.timedelta(days=1),
            status="scheduled",
            created_by=event_creator_id,
        )
    )
    event_id = event.id

    await pq.create_photo(
        photo_queries.CreatePhotoParams(
            event_id=event_id,
            storage_key="test/reject-all.jpg",
            source="direct",
            taken_at=None,
            day_number=None,
            visibility="public",
        )
    )
    await db_conn.execute(
        text(
            f"UPDATE photos SET id = '{photo_id}', status = 'pending', "
            f"uploaded_by = '{uploader_id}' WHERE storage_key = 'test/reject-all.jpg'"
        )
    )

    for uid in user_ids:
        await aq.create_photo_approval(
            photo_id=photo_id, user_id=uid, decision="pending"
        )

    try:
        result = await approval_service.decide(
            photo_id=photo_id, user_id=rejecter_id, decision="rejected"
        )
        assert result == "rejected"

        # Photo is rejected.
        photo = await pq.get_photo_by_id(id=photo_id)
        assert photo is not None and photo.status == "rejected"

        # No approval rows remain for anyone.
        remaining = [
            a
            async for a in aq.get_photo_approvals_by_photo_id(photo_id=photo_id)
        ]
        assert remaining == []

        # Neither the rejecter nor the other pending user see it anymore.
        for uid in (rejecter_id, other_id):
            listed = [
                a
                async for a in aq.list_approvals_by_user_and_status(
                    user_id=uid, limit=50, offset=0, status="pending"
                )
            ]
            assert listed == []

        # The rejection is idempotent from the API's point of view: a second
        # decision no longer finds an approval row.
        with pytest.raises(Exception):
            await approval_service.decide(
                photo_id=photo_id, user_id=other_id, decision="rejected"
            )
    finally:
        await db_conn.execute(
            text(f"DELETE FROM photo_approvals WHERE photo_id = '{photo_id}'")
        )
        await db_conn.execute(text(f"DELETE FROM photos WHERE id = '{photo_id}'"))
        await db_conn.execute(text(f"DELETE FROM events WHERE id = '{event_id}'"))
        await db_conn.execute(
            text(
                "DELETE FROM users WHERE id IN "
                f"('{uploader_id}', '{rejecter_id}', '{other_id}')"
            )
        )
        await db_conn.execute(
            text(f"DELETE FROM staff_users WHERE id = '{event_creator_id}'")
        )
        await db_conn.commit()


@pytest.mark.asyncio
async def test_list_excludes_rejected_photos_even_with_leftover_rows(
    db_conn,
) -> None:
    """Defense in depth: the list query itself must hide rejected photos."""
    event_id = uuid.uuid4()
    photo_id = uuid.uuid4()

    sq = staff_queries.AsyncQuerier(db_conn)
    uq = user_queries.AsyncQuerier(db_conn)
    eq = event_queries.AsyncQuerier(db_conn)
    pq = photo_queries.AsyncQuerier(db_conn)
    aq = approval_queries.AsyncQuerier(db_conn)

    staff = await sq.create_admin(
        email=f"admin-{uuid.uuid4()}@test.com", password="hash"
    )
    event_creator_id = staff.id

    user = await uq.create_user(
        email=f"list-rejected-{uuid.uuid4()}@test.com", hashed_password="hash"
    )
    user_id = user.id

    event = await eq.create_event(
        event_queries.CreateEventParams(
            name="List Rejected Test Event",
            event_code=f"LR{str(event_id)[:6]}",
            event_date=datetime.datetime.now(datetime.timezone.utc),
            end_date=datetime.datetime.now(datetime.timezone.utc)
            + datetime.timedelta(days=1),
            status="scheduled",
            created_by=event_creator_id,
        )
    )
    event_id = event.id

    await pq.create_photo(
        photo_queries.CreatePhotoParams(
            event_id=event_id,
            storage_key="test/list-rejected.jpg",
            source="direct",
            taken_at=None,
            day_number=None,
            visibility="public",
        )
    )
    await db_conn.execute(
        text(
            f"UPDATE photos SET id = '{photo_id}', status = 'rejected', "
            f"uploaded_by = '{user_id}' WHERE storage_key = 'test/list-rejected.jpg'"
        )
    )
    await aq.create_photo_approval(
        photo_id=photo_id, user_id=user_id, decision="pending"
    )

    try:
        listed = [
            a
            async for a in aq.list_approvals_by_user_and_status(
                user_id=user_id, limit=50, offset=0, status=None
            )
        ]
        assert listed == []
    finally:
        await db_conn.execute(
            text(f"DELETE FROM photo_approvals WHERE photo_id = '{photo_id}'")
        )
        await db_conn.execute(text(f"DELETE FROM photos WHERE id = '{photo_id}'"))
        await db_conn.execute(text(f"DELETE FROM events WHERE id = '{event_id}'"))
        await db_conn.execute(text(f"DELETE FROM users WHERE id = '{user_id}'"))
        await db_conn.execute(
            text(f"DELETE FROM staff_users WHERE id = '{event_creator_id}'")
        )
        await db_conn.commit()
