# Backend runtime (Docker image only)

This folder lets you run the backend from the published Docker image (no backend source needed).

## 1) Create your env file

- Copy `.env.example` → `.env`
- Fill missing secrets (at minimum: `jwt_secret`, `encryption_key`, `FACE_ENCRYPTION_KEY`)
- Optional: set `BACKEND_IMAGE` to a known-good tag/digest if `:latest` is broken

## 2) Start the stack

```bash
docker compose pull
docker compose up -d
```

## 3) Verify

- `http://localhost:8000/health`
- `http://localhost:8000/docs`

## Troubleshooting

- If you see `Conflict. The container name "/multi_*" is already in use`:
  - `docker compose down` (from this folder), then retry
  - or remove old stopped containers: `docker rm -f multi_postgres multi_redis multi_nats multi_minio multi_fastapi multi_migrate`

## 4) Stop

```bash
docker compose down
```

