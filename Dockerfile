# syntax=docker/dockerfile:1.7

# ---------------------------------------------------------------------------
# builder: resolves and compiles the locked dependencies into /app/.venv.
# Build tools (gcc) live ONLY here; insightface ships as an sdist and needs
# them. Nothing from this stage except the finished virtualenv is copied on.
# ---------------------------------------------------------------------------
FROM python:3.12-slim AS builder

COPY --from=ghcr.io/astral-sh/uv:0.9.28 /uv /usr/local/bin/uv

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=never \
    UV_PROJECT_ENVIRONMENT=/app/.venv

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-dev --no-install-project

# Drop what the interpreter never loads at runtime (package test suites, C
# sources, headers). NOT *.pyi: skimage's lazy loader reads its stub at import.
# Bytecode was already compiled above.
RUN find /app/.venv -type d \( -name tests -o -name test \) -prune -exec rm -rf {} + \
    && find /app/.venv -name '*.c' -delete \
    && find /app/.venv -name '*.h' -path '*/include/*' -delete

# ---------------------------------------------------------------------------
# runtime: slim Python + the few shared libraries onnxruntime/opencv load.
# No compiler, no uv, no pip cache, non-root.
# ---------------------------------------------------------------------------
FROM python:3.12-slim AS runtime

# libgomp1: onnxruntime/OpenMP. libglib2.0-0: opencv-python-headless.
RUN apt-get update \
    && apt-get install -y --no-install-recommends libgomp1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
    && useradd --uid 10001 --create-home --home-dir /home/app --shell /usr/sbin/nologin app \
    && mkdir -p /home/app/.insightface \
    && chown -R app:app /home/app

ENV PATH="/app/.venv/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    HOME=/home/app \
    OMP_NUM_THREADS=2

WORKDIR /app

COPY --from=builder --chown=app:app /app/.venv /app/.venv
COPY --chown=app:app alembic.ini ./
COPY --chown=app:app app ./app
COPY --chown=app:app db ./db
COPY --chown=app:app migrations ./migrations

USER app

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1", "--proxy-headers", "--forwarded-allow-ips", "*"]
