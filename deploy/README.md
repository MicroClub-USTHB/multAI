# MultiAI backend: production deployment

One compose project (`multai`) on the shared VPS, fronted by the host Caddy.
CD builds an amd64 image on every push to `main`/`develop` and deploys `main`.

| File | Goes to | Purpose |
|---|---|---|
| `compose.prod.yml` | `/opt/multai/compose.yml` (CD copies it) | the whole stack: api, web, 9 workers, postgres, redis, nats, minio |
| `deploy.sh` | `/opt/multai/deploy.sh` (CD copies it) | `deploy.sh <sha-tag>` backend, `deploy.sh web <tag>` frontend, with rollback |
| `.env.production.example` | `/opt/multai/.env` (you fill it, `chmod 600`) | every variable, placeholders only |
| `multai.caddy` | `/etc/caddy/sites/multai.caddy` (once) | TLS + routing |
| `../.github/workflows/cd.yml` | repo | build, push, deploy |

## Layout

```
https://<MULTAI_HOST>/            -> web   127.0.0.1:13000   (multAI-front, own repo + CD)
https://<MULTAI_HOST>/api/*       -> api   127.0.0.1:18000   (prefix stripped by Caddy)
https://<MULTAI_HOST>/api/internal/*  -> 404 (never public)
https://<S3_HOST>/                -> minio 127.0.0.1:19000   (S3 API only, for direct browser uploads)
HR-Events -> http://host.docker.internal:18000/internal/events   (host loopback)
```

`MULTAI_HOST` defaults to `multai.164-68-103-224.sslip.io` and `S3_HOST` to
`s3.multai.164-68-103-224.sslip.io` (sslip.io needs no DNS record; with a real
domain, add an A record for both names pointing at the VPS).

Networks: `backend` (internal, no outside access: data services, api, workers, web)
and `egress` (only containers that call the internet, or publish a loopback port:
api, web, minio for its loopback port, email/drive/upload/notification workers).
Postgres, Redis and NATS are never reachable from the host. MinIO's S3 API is
reachable on 127.0.0.1:19000 only (host Caddy proxies it); its console is not published.

## One-time server setup

```bash
# on the VPS, as root
mkdir -p /opt/multai/secrets && cd /opt/multai
# 1. fill the environment (generate secrets with the openssl hints in the file)
# from your machine: scp deploy/.env.production.example root@<vps>:/opt/multai/.env
chmod 600 .env && $EDITOR .env
# 2. optional: push notifications
#    put the Firebase service-account JSON at /opt/multai/secrets/firebase-credentials.json,
#    then set COMPOSE_PROFILES=firebase in .env
# 3. Caddy site (see the note below if Caddy is managed by Ansible)
# from your machine: scp deploy/multai.caddy root@<vps>:/etc/caddy/sites/multai.caddy
caddy validate --config /etc/caddy/Caddyfile && systemctl reload caddy
# 4. a deploy-only SSH key for CD
ssh-keygen -t ed25519 -f ./cd_key -N '' -C multai-cd   # append cd_key.pub to ~/.ssh/authorized_keys (or the deploy user's)
```

First deploy: push to `main` (or run the CD workflow). `compose.yml` and
`deploy.sh` do not exist yet on a fresh server; CD copies them, so only `.env`
needs to be there beforehand.

Caddy on this server is Ansible-managed (`/etc/caddy/Caddyfile` imports
`/etc/caddy/sites/*.caddy`). Add `multai.caddy` to the same role so a later
Ansible run does not remove it.

Register in the external consoles, **exact URLs**:

- MCDI redirect: `https://<MULTAI_HOST>/api/admin/auth/mcdi/callback`
- Google OAuth redirect: `https://<MULTAI_HOST>/api/staff/drive/callback`

## GitHub setup

Repository secrets (Settings, Secrets and variables, Actions):

| Secret | Value |
|---|---|
| `VPS_HOST` | the server address |
| `VPS_USER` | SSH user allowed to run `docker` |
| `VPS_SSH_KEY` | the **private** deploy key from step 4 |
| `VPS_KNOWN_HOSTS` | optional: `ssh-keyscan -t ed25519 <host>` from a trusted machine (otherwise the host key is trusted on first use, with a warning) |

Create the environment `production` (Settings, Environments); add required
reviewers there if you want a manual gate before each deploy.

The deploy job logs the server into GHCR with the run's short-lived
`GITHUB_TOKEN` (sent over stdin, never printed), so private images pull without
a stored personal token. If you prefer a long-lived login, run
`docker login ghcr.io` once on the server with a `read:packages` PAT.

## What a deploy does

`deploy.sh sha-<fullsha>`: pull; start postgres/redis/nats/minio; fetch the
face model once (`models-init`); **run migrations (a failure stops here, the
running app is untouched)**; roll api + workers (`up -d --wait`); check
`/health`; on failure restart the previous good tag. State lives in
`/opt/multai/.last_tag` and `.prev_tag` (backend), `.last_web_tag` and
`.prev_web_tag` (web). Migrations are not rolled back: keep them additive.

`deploy.sh web sha-<fullsha>` (called by the multAI-front CD): sets
`MULTAI_FRONT_TAG` in `.env`, pulls and restarts only `web`, checks
`/healthz`, restores the previous web tag on failure. The backend deploy leaves
`web` out of the stack until the first front deploy has recorded `.last_web_tag`.

## Roll back

- From GitHub: Actions, CD, Run workflow on `main` with `rollback_sha` = an older
  commit whose image was built. No build; that tag is redeployed.
- By hand: `ssh vps '/opt/multai/deploy.sh sha-<fullsha>'` (backend) or
  `... deploy.sh web sha-<fullsha>`. `.prev_tag` / `.prev_web_tag` hold the last one.
- Database: restore from backup; there is no automatic schema rollback.

## Resource budget

Measured on the built image (arm64 laptop, CPU provider; x86 will differ a little)
and estimated for the rest. Limits are hard caps, not reservations.

| Service | Cap (mem / cpu) | Expected use |
|---|---|---|
| api | 1152 MB / 1.5 | 230 MB at start; ~830 MB after the first face enrolment loads `buffalo_l` (measured) |
| photo-worker | 1152 MB / 2.0 | ~830 MB once the model is loaded (measured); 1 face about 1.0 s, 2 faces about 1.1 s |
| 7 light workers (email, upload-group, drive-sync, audit, storage-cleaner, event-lifecycle, upload-reconciler) | 192 MB / 0.5 each | 48 to 80 MB at import (measured), ~60 to 110 MB running |
| web | 256 MB / 0.5 | ~100 MB |
| postgres | 512 MB / 1.0 | 150 to 250 MB (`shared_buffers=128MB`, `max_connections=50`) |
| minio | 384 MB / 0.5 | ~120 MB |
| redis | 128 MB / 0.25 | under 30 MB (`maxmemory 96mb`, TTL keys only evicted) |
| nats | 96 MB / 0.25 | ~15 MB |
| migrate, models-init (one-shot) | 256 MB, 1024 MB | only during a deploy |

Steady state is about 2.0 to 2.4 GB; the caps add up to about 5.6 GB, so the
stack cannot take more than the box has only if everything peaks at once.
If the four products must stay under ~5 GB in the worst case, the cheapest
savings are: run `photo-worker` only when needed, or merge the seven light
workers into one container (about 300 MB less).

Image size (arm64, `docker images`): 2.34 GB before, 1.46 GB after. The CI amd64
image is of the same order. `.dockerignore` is stricter: the old one did not exclude `*firebase-adminsdk*.json`, so a local
`docker build` would have copied the service-account key into the image
(CI builds are not affected, the file is git-ignored).

## Direct photo uploads (public S3 host)

Browsers and phones upload photos straight to MinIO with presigned PUT URLs
(`POST` of an upload request returns them). The URL is signed for the host the
client will call, because SigV4 covers the `Host` header:

```
API (container)  --signs for-->  https://<S3_HOST>/images/staging/...?X-Amz-Signature=...
client           --PUT------->   Caddy (<S3_HOST>)  --->  127.0.0.1:19000 (minio:9000)
```

- `MINIO_PUBLIC_ENDPOINT` (= `S3_HOST`), `MINIO_PUBLIC_SECURE=true` and
  `MINIO_REGION` only exist on the **api** service; only the API hands URLs to
  clients. Server-side reads and writes keep using the internal `minio:9000`.
  With `MINIO_PUBLIC_ENDPOINT` empty (dev, staging) URLs keep the internal host.
- The signing client is given the region, so signing never calls the public host
  from inside the container (no hairpin through Caddy, no startup dependency on TLS).
- Caddy must pass `Host` through unchanged (the default for `reverse_proxy`); a
  `header_up Host` would make every upload fail with `SignatureDoesNotMatch`.
- **CORS is set in one place, MinIO** (`MINIO_API_CORS_ALLOW_ORIGIN=https://<MULTAI_HOST>`
  in `compose.prod.yml`). Caddy adds no `Access-Control-*` headers; two sources
  would give browsers duplicate `Access-Control-Allow-Origin` values and the
  upload would be blocked. Another origin (a local dev front) gets no allow header.
- Verified against a real MinIO and Caddy (`tests/integration/test_minio_public_presign.py`,
  needs docker): PUT/GET through a proxy on another host:port, a negative
  control (an internal-host URL is rejected with `SignatureDoesNotMatch` through
  the proxy), and the CORS preflight.

Checklist when turning this on:

1. `S3_HOST` is set in `/opt/multai/.env` (the example has it); the same name is
   the first line of the S3 block in `/etc/caddy/sites/multai.caddy`, or export
   `S3_HOST` for Caddy (`{$S3_HOST:...}` falls back to the sslip.io name).
2. Reload Caddy after copying the file: `caddy validate ... && systemctl reload caddy`.
3. Redeploy the stack so the api gets the new env and MinIO the loopback port and CORS.
4. Smoke test from outside: create an upload request, `PUT` a small image to the
   returned URL with `curl -X PUT --data-binary @x.jpg -H 'Content-Type: image/jpeg' '<url>'`
   (expect 200), then confirm it with the normal API flow.
5. URLs already issued before the change point at `http://minio:9000` and are
   dead; they expire on their own (the request must be re-created to get new ones).

## Known gaps to decide

1. `AUTO_APPROVE` defaults to `true` in the code; the example sets it to `false`.
2. The staging compose ran 6 of the 9 workers; here all 9 run, because
   `make run-workers` (the source of truth) does. Without `event-lifecycle`
   events never activate or archive; without `drive-sync` approved uploads never
   reach Drive.
3. Staging had the app on internal-only networks, so API and workers could not
   call MCDI, Google, the email API or FCM; here those containers are also on `egress`.
