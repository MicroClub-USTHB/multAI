# multAI

MultiAi: Micro Club's event photo management. A member sees their photos only in the events they took part in. One repository, three apps.

| Folder | What it is | Stack | Read this first |
|---|---|---|---|
| [`backend/`](backend/) | API, workers, migrations | Python, FastAPI, PostgreSQL, Redis, NATS, MinIO | [`backend/README.md`](backend/README.md) |
| [`frontend/`](frontend/) | Web app (staff and member site) | TypeScript, React, TanStack Start, Vite | [`frontend/README.md`](frontend/README.md) |
| [`mobile/`](mobile/) | Mobile app | Flutter | [`mobile/README.md`](mobile/README.md) |
| [`deploy/`](deploy/) | Production stack for the VPS: compose file, Caddy site, `deploy.sh` | Docker Compose | [`deploy/README.md`](deploy/README.md) |

Each app keeps its own tooling, lockfile and README; run its commands from inside its folder.

## CI and CD (`.github/workflows/`)

- `backend-ci.yml`: lint, type check, tests and a Docker build, when `backend/` changes.
- `frontend-ci.yml`: build, lint, type check and tests, when `frontend/` changes.
- `cd.yml`: on every push to `main` or `develop` it builds both images, tagged `sha-<commit>` plus `latest` (main) or the branch name:
  `ghcr.io/microclub-usthb/multai-back` and `ghcr.io/microclub-usthb/multai-front`. It does not deploy: the Watchtower on the VPS pulls the new images and
  recreates the containers (see [`deploy/README.md`](deploy/README.md)). The image names are fixed, so renaming this repository does not move them.

The mobile app has no CI yet.

## History

This repository was assembled from three repositories, with their full commit history kept (paths rewritten into the folders above):
`multAI-back` (this repo, from `develop`), `multAI-front` (`develop`) and `multAI-mobile` (`main`).
