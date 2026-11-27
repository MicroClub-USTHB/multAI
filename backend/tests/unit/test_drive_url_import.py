import pytest
from fastapi import HTTPException

from app.service.drive_import import (
    extract_drive_file_id,
    extract_unique_drive_file_ids,
)

FILE_ID = "1AbCdEfGhIjKlMnOpQrStUvWxYz012345"


def test_extracts_file_id_from_common_url_forms() -> None:
    assert (
        extract_drive_file_id(
            f"https://drive.google.com/file/d/{FILE_ID}/view?usp=sharing"
        )
        == FILE_ID
    )
    assert (
        extract_drive_file_id(f"https://drive.google.com/open?id={FILE_ID}")
        == FILE_ID
    )
    assert (
        extract_drive_file_id(f"https://drive.google.com/uc?id={FILE_ID}&export=download")
        == FILE_ID
    )
    assert extract_drive_file_id(f"  {FILE_ID}  ") == FILE_ID


def test_deduplicates_file_ids_preserving_order() -> None:
    other = "9ZyXwVuTsRqPoNmLkJiHgFeDcBa876543"
    urls = [
        f"https://drive.google.com/file/d/{FILE_ID}/view",
        f"https://drive.google.com/open?id={other}",
        f"https://drive.google.com/file/d/{FILE_ID}/view",
    ]

    assert extract_unique_drive_file_ids(urls) == [FILE_ID, other]


def test_rejects_folder_links() -> None:
    with pytest.raises(HTTPException) as exc_info:
        extract_drive_file_id("https://drive.google.com/drive/folders/abcDEF123456")

    assert exc_info.value.status_code == 400
    assert "Folder links" in str(exc_info.value.detail)


def test_rejects_unparseable_values() -> None:
    with pytest.raises(HTTPException) as exc_info:
        extract_drive_file_id("https://example.com/not-a-drive-file")

    assert exc_info.value.status_code == 400
