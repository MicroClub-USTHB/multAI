import pytest

from app.infra.google_drive import GoogleDriveClient, GoogleDriveFileMetadata

FOLDER = GoogleDriveClient._drive_folder_mime_type


def _meta(id: str, mime: str) -> GoogleDriveFileMetadata:
    return GoogleDriveFileMetadata(id=id, name=id, mime_type=mime, size_bytes=1)


@pytest.mark.asyncio
async def test_recursive_listing_walks_subfolders(monkeypatch: pytest.MonkeyPatch) -> None:
    tree = {
        "root": [_meta("a.jpg", "image/jpeg"), _meta("sub", FOLDER)],
        "sub": [_meta("b.png", "image/png"), _meta("root", FOLDER)],  # cycle
    }

    async def fake_list(*, access_token: str, folder_id: str, files_out: list) -> list[str]:
        subs = []
        for item in tree[folder_id]:
            if item.mime_type == FOLDER:
                subs.append(item.id)
            else:
                files_out.append(item)
        return subs

    monkeypatch.setattr(GoogleDriveClient, "_list_single_folder", staticmethod(fake_list))

    flat = await GoogleDriveClient.list_folder_files(access_token="t", folder_id="root")
    assert [f.id for f in flat] == ["a.jpg"]
    deep = await GoogleDriveClient.list_folder_files(
        access_token="t", folder_id="root", recursive=True
    )
    assert sorted(f.id for f in deep) == ["a.jpg", "b.png"]
