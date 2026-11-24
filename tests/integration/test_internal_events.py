from types import SimpleNamespace

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from app.container import get_container
from app.core.config import settings
from app.router.internal import router as internal_router
from app.router.web.event import router as web_event_router
from app.service.event import EventService
from tests.unit.test_event_sync import FakeEventQuerier

BODY = {
    "external_id": "hr-1",
    "name": "Hackathon",
    "starts_at": "2026-12-01T18:00:00Z",
    "ends_at": "2026-12-01T22:00:00Z",
}
KEY = {"X-Service-Key": "s3cret"}


@pytest.fixture
def client(monkeypatch: pytest.MonkeyPatch) -> TestClient:
    monkeypatch.setattr(settings, "HR_EVENTS_SERVICE_KEY", "s3cret")
    q = FakeEventQuerier()
    service = EventService(e_querier=q, p_querier=None)  # type: ignore[arg-type]
    app = FastAPI()
    app.include_router(internal_router)
    app.dependency_overrides[get_container] = lambda: SimpleNamespace(
        event_service=service
    )
    return TestClient(app)


def test_valid_key_creates_event_with_code(client: TestClient) -> None:
    res = client.post("/internal/events", json=BODY, headers=KEY)
    assert res.status_code == 200
    assert res.json()["event_code"]
    assert res.json()["external_id"] == "hr-1"


def test_repeat_returns_same_event_and_code(client: TestClient) -> None:
    first = client.post("/internal/events", json=BODY, headers=KEY).json()
    second = client.post("/internal/events", json=BODY, headers=KEY).json()
    assert second["id"] == first["id"]
    assert second["event_code"] == first["event_code"]


def test_missing_or_wrong_key_401(client: TestClient) -> None:
    assert client.post("/internal/events", json=BODY).status_code == 401
    bad = {"X-Service-Key": "nope"}
    assert client.post("/internal/events", json=BODY, headers=bad).status_code == 401


def test_invalid_dates_422(client: TestClient) -> None:
    bad = {**BODY, "starts_at": BODY["ends_at"], "ends_at": BODY["starts_at"]}
    assert client.post("/internal/events", json=bad, headers=KEY).status_code == 422


def test_staff_create_event_route_removed() -> None:
    methods = {
        m for r in web_event_router.routes if r.path == "/events/" for m in r.methods
    }
    assert "POST" not in methods
