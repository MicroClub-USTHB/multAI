# Backend Gap Checklist (Frontend v1)

This repo’s frontend is built against the **current backend contract**:

- **Auth**: cookie session (`POST /admin/auth/login`, `GET /admin/auth/me`)
- **Staff APIs**: `/stuff/*`
- **Dev networking**: same-origin `/api/*` proxied to backend (Vite)
- **Media access**: backend-mediated paths only (preview binaries or signed URLs), never raw MinIO URLs

Use this document as the single checklist to confirm backend availability and to track what the PDF spec requires that the backend may not yet expose.

## Implemented / in-use endpoints (frontend calls today)

### Auth (cookie)
- [ ] `POST /admin/auth/login` (email/password)
- [ ] `GET /admin/auth/me` (current staff user)
- [ ] ⚠️ Missing: `POST /admin/auth/logout` (clear httpOnly cookie) — frontend currently “logs out” client-side only

### Notifications
- [ ] `GET /stuff/notifications`
- [ ] `POST /stuff/notifications/read`

### Multi: uploads (Google Drive-based requests)
- [ ] `GET /stuff/drive/status`
- [ ] `GET /stuff/drive/connect?redirect_url=...` (returns `authorization_url`)
- [ ] `POST /stuff/drive/disconnect`
- [ ] `POST /stuff/uploads/request` (creates request or request-group)
- [ ] `GET /stuff/uploads?scope=my|all&status=...`
- [ ] `GET /stuff/uploads/{request_id}`
- [ ] `GET /stuff/uploads/{request_id}/photos`
- [ ] `POST /stuff/uploads/{request_id}/approve`
- [ ] `POST /stuff/uploads/{request_id}/reject`
- [ ] `GET /stuff/uploads/groups?scope=my|all&status=...`
- [ ] `GET /stuff/uploads/groups/{group_id}`
- [ ] `GET /stuff/uploads/groups/{group_id}/photos`
- [ ] `POST /stuff/uploads/groups/{group_id}/approve`
- [ ] `POST /stuff/uploads/groups/{group_id}/reject`
- [ ] `GET /stuff/uploads/{request_id}/photos/{photo_id}/preview` (binary)

### Multi: events
- [ ] `GET /admin/events?scope=my|all&status=...` (verify actual params)
- [ ] `POST /admin/events`
- [ ] `POST /admin/events/{event_id}/archive`
- [ ] `POST /admin/events/{event_id}/schedule`
- [ ] `POST /admin/events/{event_id}/draft`

## PDF-required (likely gaps)

### Discord OAuth (web app auth)
- [ ] `GET /admin/auth/discord` (start OAuth) or equivalent
- [ ] `GET /admin/auth/discord/callback` (OAuth callback) or equivalent
- [ ] `GET /admin/auth/me` returns Discord-linked profile fields (if needed by UI)

### Direct-to-MinIO uploads (local bulk upload flow)
If the PDF requires local upload (bypassing Google Drive), the backend usually needs:
- [ ] Create upload session / request for local files
- [ ] Presigned upload URL(s) or multipart upload support
- [ ] Finalize/commit endpoint after uploads complete
- [ ] Processing status endpoint(s) for async pipeline (queued → processing → done/failed)
- [ ] Signed URL / secure preview endpoint(s) for private media

### Admin dashboard stats/alerts/logs
Current admin dashboard UI uses mocked data in the frontend. If the PDF requires real stats:
- [ ] Stats endpoints (processing load, drive usage, alert feed)
- [ ] Logs endpoints (sync errors, face matching logs, etc.)

## Uploads v1 decision (needs confirmation)

Pick one for v1 and align UI + backend:

- **Current frontend implementation**: Google Drive-based upload requests (`/stuff/drive/*`, `/stuff/uploads/*`)
- **PDF alternative**: local bulk uploads (requires presigned URLs + processing status APIs)

