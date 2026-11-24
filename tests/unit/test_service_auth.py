import pytest
from fastapi import HTTPException

from app.core.config import settings
from app.deps.service_auth import require_service_key


async def test_valid_key_passes(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "HR_EVENTS_SERVICE_KEY", "s3cret")
    assert await require_service_key("s3cret") is None


async def test_wrong_key_401(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "HR_EVENTS_SERVICE_KEY", "s3cret")
    with pytest.raises(HTTPException) as exc:
        await require_service_key("nope")
    assert exc.value.status_code == 401


async def test_missing_header_401(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "HR_EVENTS_SERVICE_KEY", "s3cret")
    with pytest.raises(HTTPException) as exc:
        await require_service_key(None)
    assert exc.value.status_code == 401


async def test_unset_server_key_rejects_everything(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(settings, "HR_EVENTS_SERVICE_KEY", "")
    for header in ("", None, "anything"):
        with pytest.raises(HTTPException) as exc:
            await require_service_key(header)
        assert exc.value.status_code == 401
