import re

from app.core.exceptions import AppException

_FOLDER_PATTERNS = (
    re.compile(r"/folders/([A-Za-z0-9_-]+)"),
    re.compile(r"[?&]id=([A-Za-z0-9_-]+)"),
)
_BARE_ID = re.compile(r"[A-Za-z0-9_-]{10,}")


def extract_drive_folder_id(value: str) -> str:
    """Return the Drive folder id from a folder link (or a bare id)."""
    raw = value.strip()
    if not raw:
        raise AppException.bad_request("Drive folder link must not be empty")
    if "/file/d/" in raw:
        raise AppException.bad_request(
            "That is a file link. Paste the link of the folder."
        )
    for pattern in _FOLDER_PATTERNS:
        match = pattern.search(raw)
        if match is not None:
            return match.group(1)
    if _BARE_ID.fullmatch(raw):
        return raw
    raise AppException.bad_request("Could not read a Drive folder id from that link")
