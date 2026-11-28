import io
import urllib.error
import urllib.request
from email.message import Message
from unittest.mock import MagicMock

import pytest

from app.infra import google_drive as gd


def _http_error(code: int, body: str) -> urllib.error.HTTPError:
    return urllib.error.HTTPError(
        "http://x", code, "err", Message(), io.BytesIO(body.encode())
    )


def test_is_retryable() -> None:
    assert gd._is_retryable(429, "")
    assert gd._is_retryable(503, "")
    assert gd._is_retryable(400, "<html>automated queries</html>")
    assert not gd._is_retryable(404, "not found")
    assert not gd._is_retryable(403, "forbidden")


def test_retries_then_succeeds(monkeypatch: pytest.MonkeyPatch) -> None:
    calls = {"n": 0}
    ok = MagicMock()
    ok.__enter__.return_value.read.return_value = b"data"
    ok.__enter__.return_value.headers = Message()

    def fake_urlopen(request: object, timeout: int) -> MagicMock:
        calls["n"] += 1
        if calls["n"] < 3:
            raise _http_error(429, "slow down")
        return ok

    monkeypatch.setattr(urllib.request, "urlopen", fake_urlopen)
    monkeypatch.setattr(gd.time, "sleep", lambda s: None)
    body, _ = gd._urlopen_with_retry(urllib.request.Request("http://x"), timeout=5)
    assert body == b"data"
    assert calls["n"] == 3


def test_non_retryable_error_is_not_retried(monkeypatch: pytest.MonkeyPatch) -> None:
    calls = {"n": 0}

    def fake_urlopen(request: object, timeout: int) -> MagicMock:
        calls["n"] += 1
        raise _http_error(404, "missing")

    monkeypatch.setattr(urllib.request, "urlopen", fake_urlopen)
    monkeypatch.setattr(gd.time, "sleep", lambda s: None)
    with pytest.raises(urllib.error.HTTPError):
        gd._urlopen_with_retry(urllib.request.Request("http://x"), timeout=5)
    assert calls["n"] == 1
