import asyncio
import json
import logging
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from email.message import Message

from app.core.exceptions import AppException
from app.core.config import settings
from app.core.constant import (
    GOOGLE_AUTH_URL,
    GOOGLE_DRIVE_FILES_URL,
    GOOGLE_TOKEN_URL,
    GOOGLE_USERINFO_URL,
)

GOOGLE_DRIVE_LIST_FILES_URL = "https://www.googleapis.com/drive/v3/files"

logger = logging.getLogger(__name__)

# Google throttles anonymous-looking clients (urllib's default agent, bursts)
# with 429s, 5xx and an HTML "automated queries" page. Identify ourselves,
# pace API-key downloads, and back off before giving up.
_USER_AGENT = "multai-drive-import/1.0"
_RETRY_DELAYS_SECONDS = (3, 10, 30, 60, 120)
_API_KEY_DOWNLOAD_PAUSE_SECONDS = 0.4


def _is_retryable(status: int, body: str) -> bool:
    if status in (408, 429) or status >= 500:
        return True
    lowered = body.lower()
    return "automated queries" in lowered or "ratelimitexceeded" in lowered.replace(
        " ", ""
    ) or "userratelimit" in lowered


def _urlopen_with_retry(
    request: urllib.request.Request, timeout: int
) -> tuple[bytes, Message]:
    """urlopen that backs off and retries on Google throttling. Blocking."""
    request.add_header("User-Agent", _USER_AGENT)
    attempt = 0
    while True:
        try:
            with urllib.request.urlopen(request, timeout=timeout) as response:
                return response.read(), response.headers
        except urllib.error.HTTPError as exc:
            body = exc.read().decode("utf-8", errors="ignore")
            if attempt < len(_RETRY_DELAYS_SECONDS) and _is_retryable(exc.code, body):
                delay = _RETRY_DELAYS_SECONDS[attempt]
                logger.warning(
                    "google_drive throttled (HTTP %s), retry %d in %ss",
                    exc.code,
                    attempt + 1,
                    delay,
                )
                time.sleep(delay)
                attempt += 1
                continue
            raise urllib.error.HTTPError(
                exc.url, exc.code, body or exc.reason, exc.headers, None
            ) from exc
        except urllib.error.URLError:
            if attempt < len(_RETRY_DELAYS_SECONDS):
                time.sleep(_RETRY_DELAYS_SECONDS[attempt])
                attempt += 1
                continue
            raise


@dataclass
class GoogleTokenResponse:
    access_token: str
    refresh_token: str | None
    expires_at: datetime | None
    scope: str
    token_type: str


@dataclass
class GoogleUserInfo:
    id: str
    email: str
    verified_email: bool


@dataclass
class GoogleDriveFileMetadata:
    id: str
    name: str
    mime_type: str
    size_bytes: int


@dataclass
class GoogleDriveFileDownload:
    metadata: GoogleDriveFileMetadata
    content: bytes


API_KEY_CREDENTIAL_PREFIX = "apikey:"


class GoogleDriveClient:
    _drive_folder_mime_type = "application/vnd.google-apps.folder"

    @staticmethod
    def api_key_credential(api_key: str) -> str:
        """Wrap an API key so it can travel where an OAuth access token does.

        Only works on files and folders shared as "anyone with the link".
        """
        return f"{API_KEY_CREDENTIAL_PREFIX}{api_key}"

    @staticmethod
    def _credentials(
        credential: str, query_params: dict[str, str]
    ) -> tuple[dict[str, str], dict[str, str]]:
        """Return (headers, query_params) for either an OAuth token or an API key."""
        if credential.startswith(API_KEY_CREDENTIAL_PREFIX):
            key = credential[len(API_KEY_CREDENTIAL_PREFIX) :]
            return {}, {**query_params, "key": key}
        return {"Authorization": f"Bearer {credential}"}, query_params

    @staticmethod
    def _require_str(data: dict[str, object], key: str) -> str:
        value = data.get(key)
        if not isinstance(value, str) or not value:
            raise AppException.bad_request(f"Google response missing '{key}'")
        return value

    @staticmethod
    def _optional_str(data: dict[str, object], key: str) -> str | None:
        value = data.get(key)
        if value is None:
            return None
        if not isinstance(value, str):
            raise AppException.bad_request(f"Google response field '{key}' is invalid")
        return value

    @staticmethod
    def validate_settings() -> None:
        if (
            not settings.GOOGLE_CLIENT_ID
            or not settings.GOOGLE_CLIENT_SECRET
            or not settings.GOOGLE_REDIRECT_URI
        ):
            raise AppException.bad_request(
                "Google Drive OAuth is not configured in environment variables"
            )

    @staticmethod
    def build_consent_url(state: str) -> str:
        GoogleDriveClient.validate_settings()
        query = urllib.parse.urlencode(
            {
                "client_id": settings.GOOGLE_CLIENT_ID,
                "redirect_uri": settings.GOOGLE_REDIRECT_URI,
                "response_type": "code",
                "scope": settings.GOOGLE_OAUTH_SCOPES,
                "access_type": "offline",
                "include_granted_scopes": "true",
                "prompt": "consent",
                "state": state,
            }
        )
        return f"{GOOGLE_AUTH_URL}?{query}"

    @staticmethod
    async def exchange_code(code: str) -> GoogleTokenResponse:
        GoogleDriveClient.validate_settings()
        payload = {
            "code": code,
            "client_id": settings.GOOGLE_CLIENT_ID,
            "client_secret": settings.GOOGLE_CLIENT_SECRET,
            "redirect_uri": settings.GOOGLE_REDIRECT_URI,
            "grant_type": "authorization_code",
        }
        data = await GoogleDriveClient._post_form(GOOGLE_TOKEN_URL, payload)
        expires_at = None
        expires_in = data.get("expires_in")
        if isinstance(expires_in, int):
            expires_at = datetime.now(timezone.utc) + timedelta(seconds=expires_in)

        return GoogleTokenResponse(
            access_token=GoogleDriveClient._require_str(data, "access_token"),
            refresh_token=GoogleDriveClient._optional_str(data, "refresh_token"),
            expires_at=expires_at,
            scope=GoogleDriveClient._optional_str(data, "scope")
            or settings.GOOGLE_OAUTH_SCOPES,
            token_type=GoogleDriveClient._optional_str(data, "token_type") or "Bearer",
        )

    @staticmethod
    async def refresh_access_token(refresh_token: str) -> GoogleTokenResponse:
        GoogleDriveClient.validate_settings()
        payload = {
            "client_id": settings.GOOGLE_CLIENT_ID,
            "client_secret": settings.GOOGLE_CLIENT_SECRET,
            "refresh_token": refresh_token,
            "grant_type": "refresh_token",
        }
        data = await GoogleDriveClient._post_form(GOOGLE_TOKEN_URL, payload)
        expires_at = None
        expires_in = data.get("expires_in")
        if isinstance(expires_in, int):
            expires_at = datetime.now(timezone.utc) + timedelta(seconds=expires_in)

        return GoogleTokenResponse(
            access_token=GoogleDriveClient._require_str(data, "access_token"),
            refresh_token=GoogleDriveClient._optional_str(data, "refresh_token"),
            expires_at=expires_at,
            scope=GoogleDriveClient._optional_str(data, "scope")
            or settings.GOOGLE_OAUTH_SCOPES,
            token_type=GoogleDriveClient._optional_str(data, "token_type") or "Bearer",
        )

    @staticmethod
    async def get_user_info(access_token: str) -> GoogleUserInfo:
        data = await GoogleDriveClient._get_json(
            GOOGLE_USERINFO_URL,
            headers={"Authorization": f"Bearer {access_token}"},
            error_context="Google user info request",
        )
        return GoogleUserInfo(
            id=GoogleDriveClient._require_str(data, "id"),
            email=GoogleDriveClient._require_str(data, "email"),
            verified_email=bool(data.get("verified_email", False)),
        )

    @staticmethod
    async def create_folder(
        *,
        access_token: str,
        name: str,
        parent_id: str | None,
    ) -> GoogleDriveFileMetadata:
        metadata: dict[str, object] = {
            "name": name,
            "mimeType": GoogleDriveClient._drive_folder_mime_type,
        }
        if parent_id:
            metadata["parents"] = [parent_id]

        encoded = json.dumps(metadata).encode("utf-8")

        def _request() -> dict[str, object]:
            request = urllib.request.Request(
                "https://www.googleapis.com/drive/v3/files?supportsAllDrives=true&fields=id,name,mimeType,size",
                data=encoded,
                headers={
                    "Authorization": f"Bearer {access_token}",
                    "Content-Type": "application/json",
                },
                method="POST",
            )
            try:
                with urllib.request.urlopen(request, timeout=15) as response:
                    return json.loads(response.read().decode("utf-8"))
            except urllib.error.HTTPError as exc:
                details = exc.read().decode("utf-8", errors="ignore")
                raise AppException.bad_request(
                    f"Google folder creation failed: {details or exc.reason}"
                ) from exc
            except urllib.error.URLError as exc:
                raise AppException.internal_error(
                    "Unable to reach Google APIs"
                ) from exc

        result = await asyncio.to_thread(_request)
        return GoogleDriveFileMetadata(
            id=GoogleDriveClient._require_str(result, "id"),
            name=GoogleDriveClient._require_str(result, "name"),
            mime_type=GoogleDriveClient._require_str(result, "mimeType"),
            size_bytes=0,
        )

    @staticmethod
    async def get_file_metadata(
        *,
        access_token: str,
        file_id: str,
    ) -> GoogleDriveFileMetadata:
        headers, params = GoogleDriveClient._credentials(
            access_token,
            {"fields": "id,name,mimeType,size", "supportsAllDrives": "true"},
        )
        data = await GoogleDriveClient._get_json(
            GOOGLE_DRIVE_FILES_URL.format(file_id=urllib.parse.quote(file_id, safe="")),
            headers=headers,
            query_params=params,
            error_context="Google Drive file metadata request",
        )
        size_raw = data.get("size", "0")
        if not isinstance(size_raw, (str, int)):
            raise AppException.bad_request("Google Drive file size is invalid")
        try:
            size_bytes = int(size_raw)
        except (TypeError, ValueError) as exc:
            raise AppException.bad_request("Google Drive file size is invalid") from exc

        return GoogleDriveFileMetadata(
            id=GoogleDriveClient._require_str(data, "id"),
            name=GoogleDriveClient._require_str(data, "name"),
            mime_type=GoogleDriveClient._require_str(data, "mimeType"),
            size_bytes=size_bytes,
        )

    @staticmethod
    async def upload_file(
        *,
        access_token: str,
        file_name: str,
        content_type: str,
        data: bytes,
        folder_id: str | None,
    ) -> GoogleDriveFileMetadata:
        boundary = "multai-drive-upload-boundary"
        metadata: dict[str, object] = {"name": file_name}
        if folder_id:
            metadata["parents"] = [folder_id]

        body = (
            (
                f"--{boundary}\r\n"
                "Content-Type: application/json; charset=UTF-8\r\n\r\n"
                f"{json.dumps(metadata)}\r\n"
                f"--{boundary}\r\n"
                f"Content-Type: {content_type}\r\n\r\n"
            ).encode("utf-8")
            + data
            + f"\r\n--{boundary}--".encode("utf-8")
        )

        def _request() -> dict[str, object]:
            url = (
                "https://www.googleapis.com/upload/drive/v3/files"
                "?uploadType=multipart&supportsAllDrives=true&fields=id,name,mimeType,size"
            )
            request = urllib.request.Request(
                url,
                data=body,
                headers={
                    "Authorization": f"Bearer {access_token}",
                    "Content-Type": f"multipart/related; boundary={boundary}",
                },
                method="POST",
            )
            try:
                with urllib.request.urlopen(request, timeout=60) as response:
                    return json.loads(response.read().decode("utf-8"))
            except urllib.error.HTTPError as exc:
                details = exc.read().decode("utf-8", errors="ignore")
                raise AppException.bad_request(
                    f"Google Drive file upload failed: {details or exc.reason}"
                ) from exc
            except urllib.error.URLError as exc:
                raise AppException.internal_error(
                    "Unable to reach Google APIs"
                ) from exc

        result = await asyncio.to_thread(_request)
        size_raw = result.get("size", "0")
        try:
            size_bytes = (
                int(size_raw) if isinstance(size_raw, (str, int)) else len(data)
            )
        except (TypeError, ValueError):
            size_bytes = len(data)

        return GoogleDriveFileMetadata(
            id=GoogleDriveClient._require_str(result, "id"),
            name=GoogleDriveClient._require_str(result, "name"),
            mime_type=GoogleDriveClient._require_str(result, "mimeType"),
            size_bytes=size_bytes,
        )

    @staticmethod
    async def download_file(
        *,
        access_token: str,
        file_id: str,
    ) -> GoogleDriveFileDownload:
        metadata = await GoogleDriveClient.get_file_metadata(
            access_token=access_token,
            file_id=file_id,
        )
        headers, params = GoogleDriveClient._credentials(
            access_token, {"alt": "media", "supportsAllDrives": "true"}
        )
        if access_token.startswith(API_KEY_CREDENTIAL_PREFIX):
            await asyncio.sleep(_API_KEY_DOWNLOAD_PAUSE_SECONDS)
        content, _, _ = await GoogleDriveClient._get_bytes(
            GOOGLE_DRIVE_FILES_URL.format(file_id=urllib.parse.quote(file_id, safe="")),
            headers=headers,
            query_params=params,
        )
        return GoogleDriveFileDownload(metadata=metadata, content=content)

    @staticmethod
    async def list_folder_files(
        *,
        access_token: str,
        folder_id: str,
        recursive: bool = False,
    ) -> list[GoogleDriveFileMetadata]:
        """List files in a folder; with recursive=True also walks subfolders."""
        files: list[GoogleDriveFileMetadata] = []
        pending_folders = [folder_id]
        seen_folders = {folder_id}
        while pending_folders:
            current = pending_folders.pop(0)
            subfolders = await GoogleDriveClient._list_single_folder(
                access_token=access_token, folder_id=current, files_out=files
            )
            if recursive:
                for sub in subfolders:
                    if sub not in seen_folders:
                        seen_folders.add(sub)
                        pending_folders.append(sub)
        return files

    @staticmethod
    async def _list_single_folder(
        *,
        access_token: str,
        folder_id: str,
        files_out: list[GoogleDriveFileMetadata],
    ) -> list[str]:
        """Append the folder's files to files_out and return its subfolder ids."""
        subfolder_ids: list[str] = []
        next_page_token: str | None = None

        while True:
            query_params = {
                "q": f"'{folder_id}' in parents and trashed = false",
                "fields": "nextPageToken,files(id,name,mimeType,size)",
                "supportsAllDrives": "true",
                "includeItemsFromAllDrives": "true",
                "pageSize": "100",
            }
            if next_page_token is not None:
                query_params["pageToken"] = next_page_token
            headers, params = GoogleDriveClient._credentials(
                access_token, query_params
            )

            data = await GoogleDriveClient._get_json(
                GOOGLE_DRIVE_LIST_FILES_URL,
                headers=headers,
                query_params=params,
                error_context="Google Drive folder listing request",
            )

            raw_files = data.get("files", [])
            if not isinstance(raw_files, list):
                raise AppException.bad_request(
                    "Google Drive folder listing response is invalid"
                )

            for raw_file in raw_files:
                if not isinstance(raw_file, dict):
                    raise AppException.bad_request(
                        "Google Drive folder entry is invalid"
                    )
                metadata = GoogleDriveClient._file_metadata_from_dict(raw_file)
                if metadata.mime_type == GoogleDriveClient._drive_folder_mime_type:
                    subfolder_ids.append(metadata.id)
                    continue
                files_out.append(metadata)

            next_page_token_raw = data.get("nextPageToken")
            if next_page_token_raw is None:
                break
            if not isinstance(next_page_token_raw, str) or not next_page_token_raw:
                raise AppException.bad_request(
                    "Google Drive next page token is invalid"
                )
            next_page_token = next_page_token_raw

        return subfolder_ids

    @staticmethod
    async def list_folder_contents(
        *,
        access_token: str,
        folder_id: str | None = None,
    ) -> list[GoogleDriveFileMetadata]:
        """Like list_folder_files but includes folders. folder_id=None means root."""
        parent = folder_id or "root"
        items: list[GoogleDriveFileMetadata] = []
        next_page_token: str | None = None

        while True:
            query_params = {
                "q": f"'{parent}' in parents and trashed = false",
                "fields": "nextPageToken,files(id,name,mimeType,size)",
                "supportsAllDrives": "true",
                "includeItemsFromAllDrives": "true",
                "pageSize": "100",
            }
            if next_page_token is not None:
                query_params["pageToken"] = next_page_token

            data = await GoogleDriveClient._get_json(
                GOOGLE_DRIVE_LIST_FILES_URL,
                headers={"Authorization": f"Bearer {access_token}"},
                query_params=query_params,
                error_context="Google Drive folder browse request",
            )

            raw_files = data.get("files", [])
            if not isinstance(raw_files, list):
                raise AppException.bad_request(
                    "Google Drive folder listing response is invalid"
                )

            for raw_file in raw_files:
                if not isinstance(raw_file, dict):
                    continue
                items.append(GoogleDriveClient._file_metadata_from_dict(raw_file))

            next_page_token_raw = data.get("nextPageToken")
            if not isinstance(next_page_token_raw, str) or not next_page_token_raw:
                break
            next_page_token = next_page_token_raw

        return items

    @staticmethod
    async def search_files(
        *,
        access_token: str,
        query: str,
        file_type: str | None = None,
    ) -> list[GoogleDriveFileMetadata]:
        """Search Drive by name. file_type can be 'folder' or 'image'."""
        q_parts = [f"name contains '{query}'", "trashed = false"]
        if file_type == "folder":
            q_parts.append(f"mimeType = '{GoogleDriveClient._drive_folder_mime_type}'")
        elif file_type == "image":
            q_parts.append("mimeType contains 'image/'")

        items: list[GoogleDriveFileMetadata] = []
        next_page_token: str | None = None

        while True:
            query_params = {
                "q": " and ".join(q_parts),
                "fields": "nextPageToken,files(id,name,mimeType,size)",
                "supportsAllDrives": "true",
                "includeItemsFromAllDrives": "true",
                "pageSize": "100",
            }
            if next_page_token is not None:
                query_params["pageToken"] = next_page_token

            data = await GoogleDriveClient._get_json(
                GOOGLE_DRIVE_LIST_FILES_URL,
                headers={"Authorization": f"Bearer {access_token}"},
                query_params=query_params,
                error_context="Google Drive search request",
            )

            raw_files = data.get("files", [])
            if not isinstance(raw_files, list):
                break

            for raw_file in raw_files:
                if not isinstance(raw_file, dict):
                    continue
                items.append(GoogleDriveClient._file_metadata_from_dict(raw_file))

            next_page_token_raw = data.get("nextPageToken")
            if not isinstance(next_page_token_raw, str) or not next_page_token_raw:
                break
            next_page_token = next_page_token_raw

        return items

    @staticmethod
    def _file_metadata_from_dict(data: dict[str, object]) -> GoogleDriveFileMetadata:
        size_raw = data.get("size", "0")
        if not isinstance(size_raw, (str, int)):
            raise AppException.bad_request("Google Drive file size is invalid")
        try:
            size_bytes = int(size_raw)
        except (TypeError, ValueError) as exc:
            raise AppException.bad_request("Google Drive file size is invalid") from exc

        return GoogleDriveFileMetadata(
            id=GoogleDriveClient._require_str(data, "id"),
            name=GoogleDriveClient._require_str(data, "name"),
            mime_type=GoogleDriveClient._require_str(data, "mimeType"),
            size_bytes=size_bytes,
        )

    @staticmethod
    async def _post_form(url: str, payload: dict[str, str]) -> dict[str, object]:
        encoded = urllib.parse.urlencode(payload).encode("utf-8")

        def _request() -> dict[str, object]:
            request = urllib.request.Request(
                url,
                data=encoded,
                headers={"Content-Type": "application/x-www-form-urlencoded"},
                method="POST",
            )
            try:
                with urllib.request.urlopen(request, timeout=15) as response:
                    return json.loads(response.read().decode("utf-8"))
            except urllib.error.HTTPError as exc:
                details = exc.read().decode("utf-8", errors="ignore")
                if "invalid_grant" in details:
                    raise AppException.unauthorized("invalid_grant") from exc
                raise AppException.bad_request(
                    f"Google token exchange failed: {details or exc.reason}"
                ) from exc
            except urllib.error.URLError as exc:
                raise AppException.internal_error(
                    "Unable to reach Google OAuth endpoints"
                ) from exc

        return await asyncio.to_thread(_request)

    @staticmethod
    async def _get_json(
        url: str,
        headers: dict[str, str] | None = None,
        query_params: dict[str, str] | None = None,
        error_context: str = "Google API request",
    ) -> dict[str, object]:
        def _request() -> dict[str, object]:
            final_url = url
            if query_params:
                final_url = f"{url}?{urllib.parse.urlencode(query_params)}"
            request = urllib.request.Request(
                final_url, headers=headers or {}, method="GET"
            )
            try:
                body, _ = _urlopen_with_retry(request, timeout=15)
                return json.loads(body.decode("utf-8"))
            except urllib.error.HTTPError as exc:
                details = exc.msg if isinstance(exc.msg, str) else ""
                raise AppException.bad_request(
                    f"{error_context} failed: {details or exc.reason}"
                ) from exc
            except urllib.error.URLError as exc:
                raise AppException.internal_error(
                    "Unable to reach Google APIs"
                ) from exc

        return await asyncio.to_thread(_request)

    @staticmethod
    async def _get_bytes(
        url: str,
        headers: dict[str, str] | None = None,
        query_params: dict[str, str] | None = None,
    ) -> tuple[bytes, str, str]:
        def _request() -> tuple[bytes, str, str]:
            final_url = url
            if query_params:
                final_url = f"{url}?{urllib.parse.urlencode(query_params)}"
            request = urllib.request.Request(
                final_url, headers=headers or {}, method="GET"
            )
            try:
                body, response_headers = _urlopen_with_retry(request, timeout=30)
                content_type = response_headers.get_content_type()
                file_name = response_headers.get_filename() or ""
                return body, content_type, file_name
            except urllib.error.HTTPError as exc:
                details = exc.msg if isinstance(exc.msg, str) else ""
                raise AppException.bad_request(
                    f"Google file download failed: {details or exc.reason}"
                ) from exc
            except urllib.error.URLError as exc:
                raise AppException.internal_error(
                    "Unable to download file from Google Drive"
                ) from exc

        return await asyncio.to_thread(_request)
