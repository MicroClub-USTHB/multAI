# multAI — Project Context

> Snapshot taken **2026-11-27** on branch `develop`, by reading `backend/` and `frontend/`.
> Purpose: restore working context quickly if a session ends. This file describes what
> exists **now**, not an aspirational spec. Where older docs contradict the code, the code
> is treated as the truth and the discrepancy is called out.

---

## 1. What the product is

multAI (MultiAi) is Micro Club's **event photo management** system. A member only sees
their own photos, and only from events they attended. The repository holds three apps:

| Folder | App | Stack |
|---|---|---|
| `backend/` | API, workers, migrations | Python 3.12, FastAPI, PostgreSQL, Redis, NATS JetStream, MinIO, SQLAlchemy, Alembic, sqlc |
| `frontend/` | Staff/member web app | TypeScript, React 19, TanStack Start + Router + Query, Vite, Tailwind v4, shadcn-style UI, Zod |
| `mobile/` | Member mobile app | Flutter (out of scope for this snapshot) |
| `deploy/` | Production VPS stack | Docker Compose, Caddy, `deploy.sh`, Watchtower |

Core flow: staff create/sync events → staff upload event photos (direct to MinIO via
presigned URLs, or via Google Drive) → a photo worker detects faces and matches them
against enrolled members → members are notified → members see only their approved photos.

---

## 2. How to run things

### Backend (from `backend/`)

Three documented run modes, see `backend/docs/RUN_MODES.md`:

1. **Dev mode (hot reload)** — infra in Docker, API on host:
   ```bash
   docker compose -f docker-compose.yml up -d
   make run-app            # uvicorn app.main:app --reload
   make run-workers        # optional: all 9 workers in parallel
   ```
2. **Staging mode** — prebuilt image `ghcr.io/microclub-usthb/multai-back:latest`
   ```bash
   docker compose -f docker-compose.staging.yml up -d
   ```
3. **Staging-check mode** — local code in staging-like containers:
   ```bash
   make staging-check-up / make staging-check-logs / make staging-check-down
   ```

Other useful targets:

```bash
make dev                 # infra + app + workers
make test                # uv run pytest
make lint                # uv run ruff check .
make check_type          # uv run mypy .
make gen                 # sqlc generate --file db/sqlc.yaml
make m-up / m-down       # alembic upgrade/downgrade + regenerate db/schema.sql
make seed                # scripts/seed.py
```

Requirements: Python `>=3.12`, `uv`, Docker. `.env` is required and validated by
`app/core/config.py` (`Settings`), including base64 AES `encryption_key`,
`jwt_secret`, `FACE_ENCRYPTION_KEY`, Postgres/Redis/NATS/MinIO credentials,
Google OAuth, Firebase, MCDI SSO, email HTTP API, and `HR_EVENTS_SERVICE_KEY`.

Health: `GET /health` checks Postgres + Redis and returns 503 with failing components.
`GET /docs`, `/redoc`, `/openapi.json` only when `settings.debug` is true.

### Frontend (from `frontend/`)

```bash
npm install
npm run dev        # vite dev --port 3000
npm run build
npm test           # vitest run --config vitest.config.cjs
npm run lint
npm run typecheck  # tsc --noEmit
```

Networking: code calls relative `/api/*`. Vite proxies `/api/*` to
`VITE_API_PROXY_TARGET` and strips `/api` (see `vite.config.ts`). The dev proxy also
removes `Secure` and relaxes `SameSite=Strict` → `Lax` on auth cookies so login works
over plain HTTP. `SERVER_URL` (server-side) or `window.location.origin` is required to
build absolute URLs during SSR.

---

## 3. Backend architecture (`backend/`)

```
app/
  main.py            FastAPI app, lifespan, CORS, request logging, /health
  container.py       Composition root (manual DI): builds queriers + services per request
  core/              config, security/JWT, exceptions, logging, image validation, constants
  deps/              FastAPI dependencies: cookie_auth, token_auth, service_auth,
                     rate_limit, client_ip, ai_deps
  infra/             database (SQLAlchemy async engine), redis, nats, minio,
                     google_drive, email
  router/            HTTP layer, split by audience: web, staff, mobile, internal
  schema/            Pydantic request/response models mirroring router split
  service/           Business logic (auth, events, uploads, approvals, faces, stats…)
  worker/            NATS JetStream consumers (9 workers)
db/
  queries/*.sql      Source queries
  generated/         sqlc output: AsyncQuerier + dataclass models (do not hand-edit)
  schema.sql         Dumped/cleaned schema
migrations/
  versions/          Alembic revisions
  sql/up|down/*.sql  Raw SQL applied by the revisions
tests/               unit, integration, e2e, security
scripts/             seed, admin seed, Drive helpers, backup, manual triggers
```

Key conventions:

- **No ORM models for queries.** Data access goes through sqlc-generated
  `AsyncQuerier` objects constructed with a per-request `AsyncConnection`
  (`app/infra/database.get_db`). Editing `db/queries/*.sql` requires
  `make gen`.
- **Manual dependency injection** via `Container` (`app/container.py`). Services receive
  queriers and collaborators in `__init__`. `get_container` is a FastAPI dependency.
- Routers are mounted by audience:
  - `/admin/*` — web admin/staff dashboard (cookie session)
  - `/staff/*` — staff/media-team operations (cookie session)
  - `/user/*` — mobile app (Bearer access token)
  - `/internal/*` — service-to-service (shared key)
- Migrations are hand-authored `.sql` up/down files wrapped by Alembic revisions.
- Ruff (E,F,W,C90; line length 88) and strict-ish mypy (`disallow_untyped_defs`)
  over `app`, `db`, `migrations`; `db/generated` excluded.

### 3.1 API surface (actual routes)

#### Web admin — prefix `/admin` (cookie auth)

| Method & path | Notes |
|---|---|
| `GET /admin/auth/mcdi/login` | Starts MCDI SSO; sets `mcdi_state` cookie |
| `GET /admin/auth/mcdi/callback` | Exchanges code, verifies staff email, sets `access_token` httpOnly cookie, redirects to `{CORS_ORIGINS[0]}/multi` |
| `GET /admin/auth/me` | Current `StaffUser` |
| `POST /admin/auth/logout` | 204; revokes MCDI token and deletes cookie |
| `GET /admin/events/` | List/filter (`limit`, `offset`, `name`, `status`) |
| `POST /admin/events/{id}/archive｜schedule｜draft` | Status transitions |
| `GET/POST /admin/users/`, `GET/PUT/DELETE /admin/users/{id}` | End-user CRUD |
| `POST /admin/users/{id}/block｜unblock` | Blocking |
| `GET/POST /admin/staff-users/`, `PATCH/DELETE /admin/staff-users/{id}` | Staff account CRUD |
| `GET /admin/audits` | Admin audit log |
| `GET /admin/stats/dashboard｜processing-load｜storage｜alerts` | Admin only |

#### Staff — prefix `/staff` (cookie auth)

| Method & path | Notes |
|---|---|
| `GET /staff/drive/connect` | Returns Google authorization URL |
| `GET /staff/drive/callback` | OAuth callback |
| `GET /staff/drive/status` | Connection state |
| `POST /staff/drive/disconnect` | Revoke/disconnect |
| `GET /staff/drive/browse`, `/search` | Browse/search Drive |
| `POST /staff/drive/files/import` | Import existing Drive files |
| `POST /staff/drive/import-urls` | Individual Drive file URLs → new (draft) event, files staged in MinIO, auto-approved, face processing queued |
| `GET /staff/notifications`, `POST /staff/notifications/read` | Staff notifications |
| `POST /staff/uploads/request` | Create upload request or group (Drive-based) |
| `GET /staff/uploads` | List requests (`scope=my|all`, `status`) |
| `GET /staff/uploads/{id}`, `/{id}/photos`, `/{id}/photos/{photo_id}/preview` | Detail + binary preview |
| `POST /staff/uploads/{id}/approve｜reject` | Per-request moderation |
| `GET /staff/uploads/groups`, `/groups/{id}`, `/groups/{id}/photos` | Group views |
| `POST /staff/uploads/groups/{id}/approve｜reject` | Group moderation |
| `POST /staff/uploads/direct/groups` | Create direct-upload group for an event |
| `POST /staff/uploads/direct/groups/{id}/batches` | Register files, get presigned PUT URLs |
| `POST /staff/uploads/direct/photos/{photo_id}/confirm｜fail` | Finalize per-file transfer |
| `POST /staff/uploads/direct/groups/{id}/resume` | Re-issue URLs for pending files |
| `GET /staff/uploads/direct/groups/{id}` | Group processing/transfer status |

#### Mobile — prefix `/user` (Bearer session token)

- Auth: `POST /auth/register`, `/register/resend-otp`, `/register/verify`, `/login`,
  `/refresh`, `/logout`, `/revoke-device`, `/devices/token`, `/devices/inactivate`,
  `GET /auth/me`, `PATCH /auth/me/profile`, `POST /auth/me/avatar`,
  `GET /auth/me/avatar/image`.
- Enrollment: `POST /enroll` (face embedding).
- Events: `POST /event/join` (QR code), `GET /event/me`.
- Photos: `GET /photos` (rate limited 20/60s), `GET /photos/event/{event_id}`,
  `GET /photos/{photo_id}/image`.
- Approvals: `GET /photos/approvals`, `POST /photos/{photo_id}/decision`.
- Notifications: `GET /notifications`, `POST /notifications/read`.
- Audits: `GET /audits`.

#### Internal — prefix `/internal` (shared `X-Service-Key`)

- `POST /internal/events` — idempotent HR-Events push (create/link/update by
  `external_id`). Rejects when `HR_EVENTS_SERVICE_KEY` is unset.

### 3.2 Authentication

- **Web/staff (cookie):** MCDI SSO. `access_token` is an httpOnly cookie (7 days).
  `get_current_staff_user` validates the token against MCDI (Redis-cached 60 s), then
  looks up a local `StaffUser` by normalized email. No local passwords for staff.
  Roles: `admin`, `multi_team_lead`, `multi`. Guards:
  `require_admin_staff`, `require_multi_team_lead_staff` (`admin` + `multi_team_lead`).
- **Mobile (token):** JWT access token (15 min) + refresh token; session stored in
  Postgres and cached in Redis. Idle/absolute expiry, device limits (3 sessions),
  blocked-user checks. `require_onboarded_mobile_user` gates face-dependent routes.
- **Service:** constant-time shared-key check for `/internal/*`; closed when key unset.

### 3.3 Infrastructure & workers

Infra: **PostgreSQL** (source of truth), **Redis** (session/cache, rate limits),
**NATS JetStream** (async jobs), **MinIO** (object storage, presigned URLs),
**Google Drive** (legacy/alternative media source), **Firebase** (push).

Workers (`make run-workers` starts all):

| Worker | Responsibility |
|---|---|
| `audit` | Consumes `audit.event` → audit records |
| `notification` | Consumes `notifications.<priority>.*` → Firebase push, retries, invalid-token cleanup |
| `email_worker` | Consumes `email.send_otp` → transactional email HTTP API |
| `photo_worker` | Consumes `photo.process` → face detection/embedding/matching |
| `upload_group_worker` | Consumes `staff.upload_group.import_requested` → process Drive import groups |
| `storage_cleaner` | Consumes cleanup subject → remove expired MinIO objects |
| `event_lifecycle` | Polls event lifecycle (scheduled → archived etc.) |
| `upload_reconciler` | Reconciles stale direct uploads (default every 300 s) |
| `drive_sync` | Consumes `photo.drive_sync.requested` → sync approved photos back to Drive |

Relevant config knobs in `app/core/config.py`: photo approval timeout (7 days),
storage retention after event end (20 days), direct-upload presign expiry (1800 s),
stale pending (45 min), batch size (200), `AUTO_APPROVE`.

### 3.4 Data model highlights (`db/generated/models.py`)

- `User` — end users, profile, `face_embedding`, `blocked`, auth/SSO ids.
- `StaffUser` — dashboard accounts, `email`, `role` (`admin|multi_team_lead|multi`).
- `Event` — `event_code` (QR), `event_date`, `end_date`, `status` (`draft|scheduled|archived`), `external_id` (HR sync).
- `EventParticipant` — user↔event membership (scan to join).
- `Photo` — MinIO/Drive identifiers, `status` (`pending|approved|rejected`), sync/cleanup fields.
- `PhotoFace`, `FaceMatch` — embeddings and matches.
- `PhotoApproval` — mobile user approval decisions with expiry.
- `UploadRequest`, `UploadRequestGroup`, `UploadRequestPhoto` — staff upload review flow (Drive and direct).
- `Session`, `RefreshToken`, `Device` — mobile auth/session.
- `Notification`, `StaffNotification`, `Audit`, stats queries.

---

## 4. Frontend architecture (`frontend/`)

```text
src/
  routes/            TanStack file-based routes
    __root.tsx       HTML shell, providers (Theme, Query, Auth), devtools
    index.tsx        Landing → link to /multi
    auth/login.tsx   Login page (MCDI start button)
    multi.tsx        Protected layout: AuthGuard + MainLayout + Outlet
    multi/index.tsx  Dashboard (currently mock stats)
    multi/events.tsx, upload.tsx, requests.tsx, team.tsx, notifications.tsx,
    multi/drive-settings/index.tsx
  features/
    common/auth/     session-api, AuthProvider contract, AuthGuard, LoginForm, utils/tests
    common/notifications/
    multi/events/    api + hooks + components (list/create/status, PDF export)
    multi/media-upload/  direct-to-MinIO bulk uploader (XHR progress, retry, pause)
    multi/uploads/   Drive upload request/group review
    multi/drive/     Drive settings — currently in-memory server-fn mocks
    multi/stats/     dashboard — currently mock data
    multi/team/, multi/photos/   currently placeholders/empty api
  shared/
    api/client.ts    Older fetch wrapper (superset-like); features use the utils client
    utils/api-client.ts  Actual apiGet/apiPost/apiPatch/apiPut/apiDelete (credentials: include)
    ui/              App UI kit (button, input, table, dialog, sidebar, chart…)
  providers/AuthProvider.tsx   useQuery(['currentUser'] → getAdminMe), logout mutation
  hooks/useAuth.ts             AuthContext
```

Routing and access:

- Root wraps everything in `ThemeProvider` → `TanStackQueryProvider` → `AuthProvider`.
- `/multi` is guarded by `AuthGuard` with `allowedRoles = ['admin','multi','multi_team_lead']`.
- `AuthProvider` hydrates from `GET /admin/auth/me`; no token in localStorage.
  `isCheckingSession` shows `LoadingPage` until hydration resolves.
- `api-client` sends `credentials: 'include'` by default; `ApiError` extracts
  FastAPI `detail` (string or validation array).

Frontend state:

- TanStack Query for server state; query keys like `['multi','events', params]`,
  `['multi','upload-groups', scope]`, `['currentUser']`.
- Redux Toolkit is listed in `tech-stack.md`, but I found no store usage in `src/`.
  Treat TanStack Query as the actual state layer.

Actual frontend→backend calls found in code:

| Feature | Call |
|---|---|
| Auth | `GET /admin/auth/me`, `POST /admin/auth/logout` |
| Events | `GET /admin/events/?…`, `POST /admin/events/`, `POST /admin/events/{id}/{draft|schedule|archive}` |
| Notifications | `GET /staff/notifications`, `POST /staff/notifications/read` |
| Upload groups | `GET /staff/uploads/groups?scope=…`, `GET /staff/uploads/groups/{id}`, `POST …/approve`, `POST …/reject` |
| Preview | `GET /staff/uploads/{requestId}/photos/{photoId}/preview` (blob URL) |
| Direct upload | `POST /staff/uploads/direct/groups`, `…/batches`, `…/photos/{id}/confirm|fail`, `…/resume`, `GET …/groups/{id}` |
| Drive URL import | `POST /staff/drive/import-urls` |

Direct-upload UX (`features/multi/media-upload`):

1. Select event → `POST /staff/uploads/direct/groups`.
2. Register files in batches (≤200) → receive `photo_id` + presigned `upload_url`.
3. `PUT` bytes straight to MinIO via XHR (progress, 3 retries with backoff, pause/abort).
4. `POST /photos/{id}/confirm` (or `/fail`), then poll `GET /groups/{id}` for
   `processing_status` / processed / failed counts.
5. A group is auto-approved when every photo is confirmed if backend `AUTO_APPROVE=true`,
   otherwise a team lead approves in `/multi/requests`.

---

## 5. Known discrepancies and gaps (important when resuming)

These are real, verified mismatches/stubs — not guesses:

1. **Stale frontend docs.** `frontend/README.md`, `frontend/docs/integration.md`, and
   `frontend/docs/backend-gap-checklist.md` describe `/stuff/*` and email/password
   admin login. The backend now uses `/staff/*` and **MCDI SSO**; the current frontend
   code already calls `/staff/*` and `/admin/auth/me`. Do not trust those older docs.
2. **Event creation endpoint missing.** Frontend `createMultiEvent` calls
   `POST /admin/events/`, but the backend router only defines `GET /admin/events/` and
   status transitions. Creating an event from the web UI will 405/404 until that route
   is added. Event creation currently reaches the system via `/internal/events` (HR sync).
3. **Drive Settings are mocked.** `features/multi/drive/api.ts` is a `createServerFn`
   in-memory mock, although the backend exposes `/staff/drive/*`.
4. **Dashboard stats are mocked.** `features/multi/stats/hooks.ts` returns `data.ts`
   mocks, although `/admin/stats/dashboard|processing-load|storage|alerts` exist.
5. **Team management page is a placeholder** (`/multi/team` renders “Hello”).
   `features/multi/team/api.ts` is empty; backend staff-user CRUD exists.
6. **`features/multi/photos/api.ts`, `stats/api.ts` are empty**; no member/gallery UI
   is wired in this app yet.
7. **Two frontend HTTP clients coexist.** `shared/api/client.ts` and
   `shared/utils/api-client.ts`. Features use the latter (`apiGet/apiPost/...`).
   Prefer `shared/utils/api-client.ts` for new code.
8. **README says `/staff` vs `/stuff`** inconsistently across documents; backend truth
   is `/staff`.
9. **No admin password login exists.** `/auth/login` should start MCDI SSO
   (`/admin/auth/mcdi/login`); any email/password form is out of date.
10. **`/health` depends on Redis internals** (`RedisClient._client.ping()`), so a Redis
    client refactor must update it.

Working-tree state at snapshot: clean, single visible commit
(`866ed64 chore: fix local setup gaps (#92)`), branch `develop`.

---

## 6. Verification & CI

- Backend CI (`.github/workflows/backend-ci.yml`): ruff, mypy, pytest, Docker build,
  triggered on `backend/**`.
- Frontend CI (`frontend-ci.yml`): build, lint, typecheck, tests.
- CD (`cd.yml`): builds both images on `main`/`develop`, pushes
  `ghcr.io/microclub-usthb/multai-back` and `multai-front`; Watchtower deploys.
- Backend tests are grouped by marker: `unit`, `integration` (needs infra),
  `e2e` (needs running backend), `security`; see `backend/pyproject.toml`.
- Mobile has no CI.

Useful focused commands:

```bash
# backend
cd backend && uv run pytest tests/unit/test_mcdi_auth.py -q
cd backend && uv run ruff check app && uv run mypy app

# frontend
cd frontend && npm run typecheck
cd frontend && npm test -- src/features/common/auth/utils.test.ts
```

---

## 7. Conventions to follow

- Backend: one router per audience/domain; Pydantic schemas under `app/schema/{request,response}/<audience>`; business logic in `app/service`; never build SQL in services — add it to `db/queries/*.sql` and regenerate.
- New backend endpoint checklist: schema(s) → query (if DB) → service method → router → wire service in `Container` → tests → `make lint` / `make check_type`.
- Frontend: feature-first folders (`features/<domain>/{api,hooks,components,types}`); server calls through `shared/utils/api-client.ts`; TanStack Query keys/`hooks.ts` per feature; UI from `shared/ui`; forms with TanStack Form + Zod; no secrets or auth tokens in browser storage.
- Keep response shapes aligned: FastAPI returns snake_case; frontend types/mappers normalize as needed (`toMultiEvent`, `toAdminProfile`, …).

---

## 8. Fast resume checklist

1. Read this file, then `backend/app/main.py`, `backend/app/container.py`,
   `backend/app/core/config.py` (settings), and `frontend/src/routes/__root.tsx`.
2. `docker compose -f backend/docker-compose.yml up -d` + `make run-app` in `backend/`.
3. `npm run dev` in `frontend/`, open `http://localhost:3000`, login via MCDI.
4. Confirm API at `http://localhost:8000/health` and `/docs`.
5. If touching DB: edit `db/queries/*.sql` → `make gen`; migration via `make migration-create`.
6. Before finishing: run the narrowest relevant check (ruff/mypy/pytest or
   lint/typecheck/vitest) and report exactly what ran.

### Most likely next tasks

- Add `POST /admin/events/` (create event) to match the frontend, or change the UI to
  rely on HR sync only.
- Replace Drive Settings mocks with `/staff/drive/*`.
- Wire dashboard stats to `/admin/stats/*` and remove `data.ts` mocks.
- Implement Team Management using `/admin/staff-users/*`.
- Build the multi-team photo browse/review UI (`features/multi/photos`).
- Update stale `frontend/README.md` and `frontend/docs/*` to `/staff` + MCDI.
