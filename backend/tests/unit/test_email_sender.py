import io
import json
import logging
import urllib.error
from typing import Any

import pytest

from app.core.config import settings
from app.infra import email as email_module
from app.infra.email import EmailSender

KEY = "http_test_key"
OTP = "482913"


class FakeResponse:
    def __init__(self, status: int, body: dict[str, Any]) -> None:
        self.status = status
        self._body = json.dumps(body).encode()

    def read(self) -> bytes:
        return self._body

    def __enter__(self) -> "FakeResponse":
        return self

    def __exit__(self, *args: object) -> None:
        return None


@pytest.fixture
def configured(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "EMAIL_HTTP_API_KEY", KEY)
    monkeypatch.setattr(settings, "EMAIL_HTTP_BASE_URL", "https://email-api.test/v1/")
    monkeypatch.setattr(settings, "EMAIL_FROM", "microclub <noreply@bortocall.com>")
    monkeypatch.setattr(settings, "environment", "production")


@pytest.fixture
def calls(monkeypatch: pytest.MonkeyPatch) -> list[Any]:
    seen: list[Any] = []

    def fake_urlopen(request: Any, timeout: float = 0) -> FakeResponse:
        seen.append(request)
        return FakeResponse(
            202,
            {"message_id": "m-1", "accepted": ["person@example.com"], "suppressed": []},
        )

    monkeypatch.setattr(email_module.urllib.request, "urlopen", fake_urlopen)
    return seen


async def test_posts_a_transactional_message_with_the_bearer_key(
    configured: None, calls: list[Any]
) -> None:
    assert await EmailSender.send_otp_email("person@example.com", OTP) is True

    (request,) = calls
    assert request.full_url == "https://email-api.test/v1/messages"
    assert request.get_method() == "POST"
    assert request.get_header("Authorization") == f"Bearer {KEY}"
    assert request.get_header("Content-type") == "application/json"
    body = json.loads(request.data)
    assert body["from"] == "microclub <noreply@bortocall.com>"
    assert body["to"] == ["person@example.com"]
    assert body["category"] == "transactional"
    assert OTP in body["html"]
    assert body["subject"]


async def test_dev_without_a_key_logs_the_otp_and_skips_the_network(
    monkeypatch: pytest.MonkeyPatch, calls: list[Any], caplog: pytest.LogCaptureFixture
) -> None:
    monkeypatch.setattr(settings, "EMAIL_HTTP_API_KEY", "")
    monkeypatch.setattr(settings, "environment", "dev")

    with caplog.at_level(logging.INFO):
        assert await EmailSender.send_otp_email("person@example.com", OTP) is True

    assert calls == []


async def test_production_without_a_key_fails_and_never_logs_the_otp(
    monkeypatch: pytest.MonkeyPatch, calls: list[Any], caplog: pytest.LogCaptureFixture
) -> None:
    monkeypatch.setattr(settings, "EMAIL_HTTP_API_KEY", "")
    monkeypatch.setattr(settings, "environment", "production")

    with caplog.at_level(logging.DEBUG):
        assert await EmailSender.send_otp_email("person@example.com", OTP) is False

    assert calls == []
    assert OTP not in caplog.text


async def test_missing_sender_fails_without_calling_the_api(
    configured: None, monkeypatch: pytest.MonkeyPatch, calls: list[Any]
) -> None:
    monkeypatch.setattr(settings, "EMAIL_FROM", "")

    assert await EmailSender.send_otp_email("person@example.com", OTP) is False
    assert calls == []


async def test_an_http_error_fails_without_leaking_the_key_or_address(
    configured: None, monkeypatch: pytest.MonkeyPatch, caplog: pytest.LogCaptureFixture
) -> None:
    def refuse(request: Any, timeout: float = 0) -> Any:
        raise urllib.error.HTTPError(
            request.full_url,
            422,
            "Unprocessable",
            {},  # type: ignore[arg-type]
            io.BytesIO(b'{"code": "unverified_sender", "message": "person@example.com"}'),
        )

    monkeypatch.setattr(email_module.urllib.request, "urlopen", refuse)

    with caplog.at_level(logging.DEBUG):
        assert await EmailSender.send_otp_email("person@example.com", OTP) is False

    assert "422" in caplog.text and "unverified_sender" in caplog.text
    assert KEY not in caplog.text
    assert "person@example.com" not in caplog.text
    assert OTP not in caplog.text


async def test_a_network_error_fails(
    configured: None, monkeypatch: pytest.MonkeyPatch
) -> None:
    def down(request: Any, timeout: float = 0) -> Any:
        raise OSError("connection refused")

    monkeypatch.setattr(email_module.urllib.request, "urlopen", down)

    assert await EmailSender.send_otp_email("person@example.com", OTP) is False


async def test_a_suppressed_recipient_counts_as_not_sent(
    configured: None, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(
        email_module.urllib.request,
        "urlopen",
        lambda request, timeout=0: FakeResponse(
            202, {"message_id": "m-2", "accepted": [], "suppressed": ["person@example.com"]}
        ),
    )

    assert await EmailSender.send_otp_email("person@example.com", OTP) is False
