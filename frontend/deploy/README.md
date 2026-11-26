# deploy: frontend

Container image for the MultiAi web app. The compose stack, Caddy site and `deploy.sh`
live in the repo-root `deploy/` folder (`/opt/multai` on the VPS); the repo-level CD workflow
(`.github/workflows/cd.yml`) builds this image and asks that stack to roll the `web` service.

```
browser ──https──> host Caddy (multai.<ip>.sslip.io)
                     ├─ /api/*  (prefix stripped) ──> 127.0.0.1:18000  API (multAI-back)
                     └─ everything else ───────────> 127.0.0.1:13000  this container (:3000)
                                                         └─ /api/* -> http://api:8000   (SSR only, optional proxy)
```

## Image

`ghcr.io/microclub-usthb/multai-front`, `linux/amd64`. Tags: `sha-<full sha>` (every build), `latest` (main), `develop` (develop).

| File | Role |
| --- | --- |
| `Dockerfile` | build (`npm ci` + `vite build`) then a `node:22-alpine` runtime, user `node`, ~340 MB |
| `deploy/runtime-package.mjs` | lists the packages `dist/server` imports at runtime, so only those are installed (the SSR bundle keeps its dependencies external, and several build tools sit in `dependencies`) |
| `deploy/serve.mjs` | the server: static files, SSR, `/healthz`, optional `/api` proxy; Node built-ins only |
| `deploy/web-service.example.yml` | the `web` block to merge into `/opt/multai/compose.yml` |
| `.github/workflows/cd.yml` | build, push, deploy |

Measured locally: ~57 MiB idle, ~60 MiB after 120 SSR renders, `docker stop` in 0.6 s.

## Variables

| Variable | When | Value in production | Notes |
| --- | --- | --- | --- |
| `VITE_API_BASE_URL` | **build** (Docker ARG, repo variable `VITE_API_BASE_URL`) | `/api` (default) | Relative on purpose: the browser calls `https://<host>/api/...`, same origin as the page, so no CORS and the staff cookie stays first-party. Caddy strips `/api`. |
| `VITE_APP_TITLE` | **build** (repo variable `VITE_APP_TITLE`) | `MultAI` | |
| `VITE_SITE_URL` | **build** (repo variable `MULTAI_PUBLIC_URL`) | `https://multai.164-68-103-224.sslip.io` | Optional; only used as an absolute-URL fallback. |
| `SERVER_URL` | **runtime** | `http://127.0.0.1:3000` | Origin used for calls made during SSR. `buildUrl` appends `/api/...` to it, so it cannot be the API's own address (`http://api:8000/api/...` does not exist). |
| `API_PROXY_TARGET` | **runtime** (optional) | `http://api:8000` | Makes the container proxy `/api/*` (prefix stripped) to the API, which is what lets `SERVER_URL` stay internal. Unset = no proxy; then `SERVER_URL` must be the public `https://<host>`. |
| `PORT` | runtime | `3000` | |
| `NODE_OPTIONS` | runtime | `--max-old-space-size=160` (image default) | Caps the heap; the container limit is 256 MB. |

Today nothing renders data on the server (the only `loader` calls a mock server function), so `SERVER_URL` is a safety net. Server-side
requests carry no browser cookie: authenticated data has to be fetched in the browser, as the app already does.

## Plug into /opt/multai

1. Merge the `web` service from `deploy/web-service.example.yml` into `/opt/multai/compose.yml`
   (it joins the `backend` network where the API service is named `api`; if the backend compose names them differently, change `API_PROXY_TARGET` and `networks`).
2. In the Caddy site for the host: `handle_path /api/*` to `127.0.0.1:18000` (and 404 for `/api/internal/*`), `handle` to `127.0.0.1:13000`.
3. `/opt/multai/deploy.sh web <tag>` must, for the **web service only**:
   set `MULTAI_FRONT_TAG=<tag>` (the tag is the full image tag, e.g. `sha-<sha>`), `docker compose pull web`, `docker compose up -d web --wait`,
   and on failure put the previous tag back and `up -d web` again, exit non-zero.
4. The server must be able to pull the image. The deploy job logs the server into GHCR with the job's short-lived `GITHUB_TOKEN`, so the package can stay private.
   First push: in GitHub, give this repo access to the package (Package settings, Manage Actions access) if GHCR created it without.

## GitHub setup (this repo)

| Kind | Name | Value |
| --- | --- | --- |
| Environment | `production` | create it (add required reviewers if you want a manual gate) |
| Secret | `VPS_HOST` | `164.68.103.224` |
| Secret | `VPS_USER` | `root` (or a deploy user allowed to run docker) |
| Secret | `VPS_SSH_KEY` | private key of a key authorised on the VPS (a dedicated deploy key, not your personal one) |
| Secret (optional) | `VPS_KNOWN_HOSTS` | output of `ssh-keyscan 164.68.103.224`; without it the job trusts the host key on first contact |
| Variable (optional) | `MULTAI_PUBLIC_URL` | `https://multai.164-68-103-224.sslip.io` |
| Variable (optional) | `VITE_API_BASE_URL`, `VITE_APP_TITLE` | only to override the defaults above |

## Build and run locally

```sh
docker build -t multai-front --build-arg VITE_API_BASE_URL=/api .
docker run --rm -p 3000:3000 -e SERVER_URL=http://127.0.0.1:3000 -e API_PROXY_TARGET=http://host.docker.internal:8000 multai-front
curl localhost:3000/healthz
```
