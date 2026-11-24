# HR-Events -> MultiAi Event Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Events are created only in HR-Events; each new event is pushed to MultiAi, which creates its own event row and join code. MultiAi stops creating events itself.

**Architecture:** HR-Events writes a row to a new `multiai_event_outbox` table when an event is created; a worker (modelled on the existing submission outbox worker) POSTs it to MultiAi `POST /internal/events` with a shared service key and retries on failure. MultiAi upserts on `external_id` (HR-Events event id) and generates `event_code` on first insert.

**Tech Stack:** MultiAi: FastAPI, SQLC, Alembic SQL migrations, pytest. HR-Events: NestJS 12, Drizzle, vitest.

**Spec:** `docs/superpowers/specs/2026-11-23-hr-events-sync-design.md` (MultiAi backend repo).

## Global Constraints

- MultiAi generates `event_code` (`secrets.token_urlsafe(8)`) on first insert only; it is never overwritten.
- Service auth header: `X-Service-Key`, compared with `hmac.compare_digest`; missing or wrong key -> 401.
- Sync is create-only. No update/archive propagation.
- HR-Events rules (`AGENTS.md`): create modules with `pnpm --filter @hr-event/api new:module`; no new libraries (use built-in `fetch`); never edit `docs/`, `.githooks/`, `pnpm-lock.yaml`; never disable checks; no Co-Authored-By; do not commit/push unless asked; finish with `pnpm check`. **HR-Events tasks (5-9) need owner approval first: this feature is outside phase 1 (S1-S14).**
- MultiAi: never hand-edit `db/generated/`; run `make gen`. Never commit the Firebase credentials JSON.
- Synced events get MultiAi status `draft` (my call: staff schedules them), `event_date = starts_at`, `end_date = ends_at`, `created_by = NULL`.

## Review Focus

- Same HR event id sent twice (retry after a lost response) -> one row, same `event_code`, 200 both times.
- Pre-existing MultiAi event with same `name` + `event_date` and `external_id` NULL -> linked, code and photos kept.
- Two legacy MultiAi events with identical name + date -> link only one (oldest by `created_at`), never fail.
- `ends_at` missing/before `starts_at` in payload -> 422, nothing stored.
- Wrong/absent `X-Service-Key`, or `HR_EVENTS_SERVICE_KEY` unset on the server -> 401 (never open by default).
- MultiAi down during HR event creation -> HR event still created; outbox row retried later.

---

## MultiAi backend (`MultiAi/multAI-back`)

### Task 1: Schema + queries

**Files:**
- Create: `migrations/sql/up/events_external_id.sql`, `migrations/sql/down/events_external_id.sql`, `migrations/versions/<rev>_events_external_id.py`
- Modify: `db/queries/events.sql`; regenerated `db/generated/events.py`, `db/generated/models.py`, `db/schema.sql`

**Interfaces:**
- Produces (SQLC queriers on `event_queries.AsyncQuerier`): `get_event_by_external_id(external_id: str) -> Event | None`, `link_legacy_event(external_id: str, name: str, event_date: datetime) -> Event | None`, `create_synced_event(name, event_code, event_date, end_date, status, external_id) -> Event | None`.

- [ ] **Step 1:** Up SQL: `ALTER TABLE events ADD COLUMN external_id text UNIQUE; ALTER TABLE events ALTER COLUMN created_by DROP NOT NULL;`. Down SQL reverses (down must first `DELETE`/fail-safe note: re-adding NOT NULL is only valid when no NULL rows; document this in the file).
- [ ] **Step 2:** Alembic revision file following `f3a1b7c9d201_...py` (use `run_sql_up/run_sql_down("events_external_id")`); `down_revision` = current head from `uv run alembic heads`.
- [ ] **Step 3:** Add the three queries to `db/queries/events.sql`. `link_legacy_event` is one `UPDATE events SET external_id=$1 WHERE id = (SELECT id FROM events WHERE external_id IS NULL AND name=$2 AND event_date=$3 ORDER BY created_at LIMIT 1) RETURNING *`.
- [ ] **Step 4:** Run `make m-up` then `make gen`. Expected: `events.external_id` in `db/schema.sql`; generated queriers exist; `make check_type` passes.
- [ ] **Step 5:** Commit `feat(events): add external_id and nullable created_by`.

### Task 2: Service-key auth + config

**Files:** Create `app/deps/service_auth.py`, `tests/unit/test_service_auth.py`; Modify `app/core/config.py` (add `HR_EVENTS_SERVICE_KEY: str = ""` beside the MCDI block), `.env.example` if present.

**Interfaces:** Produces `async def require_service_key(x_service_key: str | None = Header(default=None)) -> None` raising `HTTPException(401)`.

- [ ] **Step 1:** Write tests `test_valid_key_passes`, `test_wrong_key_401`, `test_missing_header_401`, `test_unset_server_key_401` (server key `""` rejects even an empty header).
- [ ] **Step 2:** Run `uv run pytest tests/unit/test_service_auth.py -v`; expect FAIL (module missing).
- [ ] **Step 3:** Implement `require_service_key` with `hmac.compare_digest` on encoded bytes.
- [ ] **Step 4:** Re-run; expect PASS. Commit `feat(auth): service key dependency`.

### Task 3: Sync service

**Files:** Modify `app/service/event.py`, `app/schema/request/web/event.py` -> add `app/schema/request/internal/event.py`; Test `tests/unit/test_event_sync.py` (fake queriers).

**Interfaces:**
- Consumes: Task 1 queriers.
- Produces: `class HrEventSync(BaseModel): external_id: str (min_length=1); name: str (min_length=1); starts_at: datetime; ends_at: datetime` with validator `ends_at >= starts_at`; `EventService.sync_from_hr(req: HrEventSync) -> EventResponse`.

- [ ] **Step 1:** Tests: `test_creates_event_with_generated_code`, `test_same_external_id_returns_existing_without_new_code`, `test_links_legacy_event_by_name_and_date`, `test_ends_before_starts_rejected`.
- [ ] **Step 2:** Run; expect FAIL.
- [ ] **Step 3:** Implement order: lookup by `external_id` -> else `link_legacy_event` -> else `create_synced_event` (code from `secrets.token_urlsafe(8)`). On unique-violation race, re-select by `external_id`.
- [ ] **Step 4:** Run; expect PASS. Commit `feat(events): sync_from_hr`.

### Task 4: Internal endpoint + remove create

**Files:** Create `app/router/internal/__init__.py`, `app/router/internal/events.py`, `tests/integration/test_internal_events.py`; Modify `app/main.py` (include router near line 172), `app/router/web/event.py` (delete `create_event` route and `EventCreate` import), `app/service/event.py` (delete `create_event`), `app/schema/request/web/event.py` (delete `EventCreate`).

**Interfaces:** Produces `POST /internal/events` (dependency `require_service_key`, body `HrEventSync`, response `EventResponse` incl. `event_code`, status 200).

- [ ] **Step 1:** Integration tests: valid key -> 200 + `event_code`; repeat -> same `id`/`event_code`; no key -> 401; `POST /admin/events/` -> 405/404.
- [ ] **Step 2:** Run `uv run pytest tests/integration/test_internal_events.py -v`; expect FAIL.
- [ ] **Step 3:** Implement router + mount; remove old create path (`grep -rn "create_event\|EventCreate" app tests` must return nothing).
- [ ] **Step 4:** Run full `uv run pytest -m "not e2e"` and `make lint check_type`; expect pass. Commit `feat(events): internal sync endpoint, remove create`.

---

## HR-Events backend (`HR-Events/apps/api`) - needs owner approval (outside S1-S14)

### Task 5: Config

**Files:** Modify `src/app/dtos/app.env.dto.ts` (add `MULTIAI_BASE_URL: z.string().url().optional()`, `MULTIAI_SERVICE_KEY: z.string().optional()`); Create `src/configs/multiai.config.ts` (`registerAs('multiai', ...)` -> `IMultiaiConfig { baseUrl?: string; serviceKey?: string; timeoutMs: number }`, `timeoutMs` 10000), register in `src/configs/index.ts`; document in `AGENTS.md` env table only if guides allow (else ask owner). Sync is disabled when either var is unset.

- [ ] Test `test/configs/multiai.config.spec.ts` (unset -> disabled; set -> values). Run `pnpm --filter @hr-event/api test`; commit.

### Task 6: Outbox table + repository

**Files:** Create module via `pnpm --filter @hr-event/api new:module multiai-sync` (generator output decides layout); table `multiai_event_outbox` (`id` uuid pk, `eventId` uuid unique, `status` pending|processing|sent|failed, `attempts`, `nextAttemptAt`, `lockedUntil`, `lastError`, `sentAt`, timestamps) mirroring `submission.registration-outbox.table.ts`; generate migration with `pnpm --filter @hr-event/api db:generate` (expect `0029_*.sql`).

**Interfaces:** Produces `MultiaiSyncRepository.enqueue(eventId: string): Promise<void>` (insert `ON CONFLICT (event_id) DO NOTHING`), `claimDue(limit: number, now: Date): Promise<IOutboxRow[]>`, `markSent(id)`, `markFailed(id, error, nextAttemptAt)`.

- [ ] Integration test (`test-int`): enqueue twice -> one row; claimDue skips locked/future rows. Commit.

### Task 7: Enqueue on create

**Files:** Modify `src/modules/event/domains/event.domain.ts:47` (`create`): after `eventRepository.create` succeeds, call `multiaiSyncRepository.enqueue(event.id)` (same transaction if the repository pattern allows; otherwise after, and Task 9 repairs misses). No-op when sync disabled. Event creation must never fail because enqueue fails (log and continue).

- [ ] Unit test in `test/modules/event/`: create enqueues once; enqueue throwing still returns the event; disabled config does not enqueue.

### Task 8: Outbox worker

**Files:** Create `multiai-sync.outbox-worker.service.ts` mirroring `submission.outbox-worker.service.ts` and registering via `WorkerService.registerIntervalJob('multiai-event-outbox', queueIntervalSeconds, ...)`.

**Behaviour:** for each claimed row load the event, `POST {baseUrl}/internal/events` with `X-Service-Key` and JSON `{ external_id: event.id, name, starts_at, ends_at }` (ISO strings); 2xx -> `markSent`; 4xx (except 429)/5xx/network -> `markFailed` with exponential backoff (30s doubling, cap 1h), `failed` after 10 attempts.

- [ ] Unit tests with mocked `fetch`: 200 marks sent; 500 reschedules with backoff; 401 marks failed-retry; header and body exact. Commit.

### Task 9: Backfill

**Files:** Create `scripts/backfill-multiai-events.mjs` (pattern: `scripts/db-seed.mjs`): enqueue every non-archived event lacking an outbox row; the worker delivers them.

- [ ] Test: run twice -> same row count. Run `pnpm check` from repo root; expect green.

---

## Rollout order

1. MultiAi Tasks 1-4, deploy, set `HR_EVENTS_SERVICE_KEY`.
2. HR-Events Tasks 5-9 behind owner approval; set `MULTIAI_BASE_URL` + `MULTIAI_SERVICE_KEY`; run backfill once.
3. Staff read each event's `event_code` in the MultiAi dashboard and send it to attendees.

## Self-review notes

- Spec coverage: create path removed (T4), notification (T6-8), idempotency (T3), codes (T3), backfill (T9), schema (T1). Legacy name+date linking (T1/T3).
- Open item left to the builder: archived HR events in backfill are skipped (my call).
