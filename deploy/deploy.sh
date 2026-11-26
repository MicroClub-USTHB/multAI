#!/usr/bin/env bash
# Deploy (or roll back) the MultiAI stack on the VPS. Two forms:
#
#   /opt/multai/deploy.sh <backend-tag>        e.g. sha-<fullsha> (a bare sha works too)
#   /opt/multai/deploy.sh web <web-tag>        e.g. sha-<fullsha>, the frontend/ image
#
# Routine deploys are done by Watchtower (see deploy/README.md); this script is the manual,
# guarded path: a first start, or pinning/rolling back to a tag with migrations and health
# checks. Copy it and compose.prod.yml (as compose.yml) to /opt/multai by hand.
# Both forms are idempotent: re-running the same tag is a no-op rollout.
#
# Backend order (a failure at 4 aborts BEFORE the running app is touched):
#   1. pull the new image         2. start the data services (postgres/redis/nats/minio)
#   3. fetch the face model once  4. run migrations as a one-shot
#   5. roll the app + workers     6. verify /health on the loopback
# A failure at 5 or 6 restarts the previous good tag. Migrations are NOT rolled
# back: keep them backward compatible (add columns first, drop them later).
#
# Web: set MULTAI_FRONT_TAG in .env, pull, `up -d --no-deps --wait web`, verify
# /healthz, and restore the previous web tag on failure.
#
# State files in /opt/multai: .last_tag / .prev_tag (backend, full tag),
# .last_web_tag / .prev_web_tag (web), .last_sha (backend sha, informational).
set -Eeuo pipefail

APP_DIR="${APP_DIR:-/opt/multai}"
API_PORT="${MULTAI_API_PORT:-18000}"
WEB_PORT="${MULTAI_WEB_PORT:-13000}"
BACKEND_IMAGE="ghcr.io/microclub-usthb/multai-back"
WEB_IMAGE="ghcr.io/microclub-usthb/multai-front"
cd "$APP_DIR"

mode="backend"
if [[ "${1:-}" == "web" ]]; then
  mode="web"
  shift
fi
ref="${1:?usage: deploy.sh <backend-tag|sha>  |  deploy.sh web <tag>}"

if [[ "$mode" == "backend" && "$ref" =~ ^[0-9a-f]{7,40}$ ]]; then
  tag="sha-${ref}"
elif [[ "$ref" =~ ^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}$ ]]; then
  tag="$ref"
else
  echo "invalid sha or tag: $ref" >&2
  exit 2
fi

[[ -f .env ]] || { echo ".env missing in $APP_DIR (see deploy/.env.production.example)" >&2; exit 1; }
[[ -f compose.yml ]] || { echo "compose.yml missing in $APP_DIR" >&2; exit 1; }

# Never run two deploys at once (backend and web share the lock).
exec 9>"$APP_DIR/.deploy.lock"
flock -n 9 || { echo "another deploy is running" >&2; exit 1; }

log() { printf '[deploy %s] %s\n' "$(date -u +%H:%M:%S)" "$*"; }
read_state() { [[ -s "$1" ]] && cat "$1" || true; }

# Set KEY=VALUE in .env (replace or append), keeping the file's mode.
set_env() {
  local key="$1" value="$2" tmp
  tmp="$(mktemp "$APP_DIR/.env.XXXXXX")"
  cp -p .env "$tmp"
  grep -v "^${key}=" .env > "$tmp" || true
  printf '%s=%s\n' "$key" "$value" >> "$tmp"
  mv "$tmp" .env
}

wait_http() { # url
  local _
  for _ in $(seq 1 30); do
    if curl -fsS --max-time 4 "$1" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  return 1
}

# Remove old images of one repo, keeping the listed tags.
prune_images() { # repo keep...
  local repo="$1" img k skip
  shift
  while read -r img; do
    skip=0
    for k in "$@"; do
      if [[ -n "$k" && "$img" == "${repo}:${k}" ]]; then skip=1; fi
    done
    if [[ "$skip" -eq 0 ]]; then docker image rm "$img" >/dev/null 2>&1 || true; fi
  done < <(docker image ls --format '{{.Repository}}:{{.Tag}}' "$repo")
  docker image prune -f >/dev/null
}

prev_backend="$(read_state .last_tag)"
prev_web="$(read_state .last_web_tag)"

# ---------------------------------------------------------------------------
if [[ "$mode" == "web" ]]; then
  backend_tag="${prev_backend:-latest}"
  compose() { IMAGE_TAG="$backend_tag" docker compose --project-name multai -f compose.yml --env-file .env "$@"; }

  log "web target tag: $tag (previous good: ${prev_web:-none}; backend: $backend_tag)"
  set_env MULTAI_FRONT_TAG "$tag"
  compose config --quiet

  # shellcheck disable=SC2329  # invoked through the ERR trap
  rollback_web() {
    local code=$?
    trap - ERR
    log "web deploy of $tag FAILED (exit $code)"
    if [[ -n "$prev_web" && "$prev_web" != "$tag" ]]; then
      log "rolling web back to $prev_web"
      set_env MULTAI_FRONT_TAG "$prev_web"
      compose up -d --no-deps --wait --wait-timeout 90 web || log "web rollback ALSO failed: intervene manually"
    else
      log "no previous web tag; stopping web"
      compose stop web || true
    fi
    exit "$code"
  }
  trap rollback_web ERR

  log "pulling $WEB_IMAGE:$tag"
  compose pull --quiet web
  log "starting web"
  compose up -d --no-deps --wait --wait-timeout 90 web
  log "verifying http://127.0.0.1:${WEB_PORT}/healthz"
  wait_http "http://127.0.0.1:${WEB_PORT}/healthz"

  trap - ERR
  if [[ "$prev_web" != "$tag" ]]; then
    [[ -n "$prev_web" ]] && echo "$prev_web" > .prev_web_tag
    echo "$tag" > .last_web_tag
  fi
  prune_images "$WEB_IMAGE" "$tag" "$prev_web"
  log "deployed web $tag"
  exit 0
fi

# ---------------------------------------------------------------------------
web_tag="$(read_state .last_web_tag)"
compose() { IMAGE_TAG="$tag" docker compose --project-name multai -f compose.yml --env-file .env "$@"; }

log "target tag: $tag (previous good: ${prev_backend:-none})"
compose config --quiet

# Every default-profile service, except web until the first front deploy ran.
mapfile -t services < <(compose config --services)
if [[ -z "$web_tag" ]]; then
  mapfile -t services < <(printf '%s\n' "${services[@]}" | grep -vx web)
fi

# shellcheck disable=SC2329  # invoked through the ERR trap
rollback() {
  local code=$?
  trap - ERR
  log "deploy of $tag FAILED (exit $code)"
  if [[ -n "$prev_backend" && "$prev_backend" != "$tag" ]]; then
    log "rolling back to $prev_backend"
    IMAGE_TAG="$prev_backend" docker compose --project-name multai -f compose.yml --env-file .env \
      up -d --remove-orphans --wait --wait-timeout 180 "${services[@]}" || log "rollback ALSO failed: intervene manually"
  else
    log "no previous good tag to roll back to"
  fi
  exit "$code"
}

log "pulling images"
compose pull --quiet "${services[@]}"

log "starting data services"
compose up -d --wait --wait-timeout 120 postgres redis nats minio

log "ensuring the face model is present"
compose run --rm --no-deps models-init

log "running migrations"
compose run --rm migrate

trap rollback ERR

log "rolling the application"
compose up -d --remove-orphans --wait --wait-timeout 180 "${services[@]}"

log "verifying http://127.0.0.1:${API_PORT}/health"
wait_http "http://127.0.0.1:${API_PORT}/health"

trap - ERR
if [[ "$prev_backend" != "$tag" ]]; then
  [[ -n "$prev_backend" ]] && echo "$prev_backend" > .prev_tag
  echo "$tag" > .last_tag
fi
echo "${tag#sha-}" > .last_sha

prune_images "$BACKEND_IMAGE" "$tag" "$prev_backend"
log "deployed $tag"
