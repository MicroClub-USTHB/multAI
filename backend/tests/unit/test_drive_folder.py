import pytest
from fastapi import HTTPException

from app.service.drive_folder import extract_drive_folder_id


@pytest.mark.parametrize(
    "value",
    [
        "https://drive.google.com/drive/folders/1AbCdEfGhIjKlMnOp",
        "https://drive.google.com/drive/u/0/folders/1AbCdEfGhIjKlMnOp?usp=sharing",
        "https://drive.google.com/open?id=1AbCdEfGhIjKlMnOp",
        "  1AbCdEfGhIjKlMnOp  ",
    ],
)
def test_extract_folder_id(value: str) -> None:
    assert extract_drive_folder_id(value) == "1AbCdEfGhIjKlMnOp"


@pytest.mark.parametrize(
    "value", ["", "https://drive.google.com/file/d/1AbCdEfGhIjKlMnOp/view", "not a link!"]
)
def test_extract_folder_id_rejects(value: str) -> None:
    with pytest.raises(HTTPException) as exc:
        extract_drive_folder_id(value)
    assert exc.value.status_code == 400
