"""Real-MinIO proof that browser-facing presigned URLs work behind a reverse proxy.

Starts the same MinIO image as deploy/compose.prod.yml (and Caddy for the proxy
case) with `docker run`. Skipped when docker is unavailable, so CI without docker
does not fail. Override the images with MINIO_TEST_IMAGE / CADDY_TEST_IMAGE.
"""

import os
import shutil
import socket
import subprocess
import time
import uuid
from datetime import timedelta
from urllib.parse import urlsplit, urlunsplit

import httpx
import pytest

from app.infra.minio import Bucket, init_minio_client

MINIO_IMAGE = os.getenv("MINIO_TEST_IMAGE", "cgr.dev/chainguard/minio:latest")
CADDY_IMAGE = os.getenv("CADDY_TEST_IMAGE", "caddy:2-alpine")
ROOT_USER = "testroot"
ROOT_PASSWORD = "testpassword123"
BROWSER_ORIGIN = "https://app.test"

pytestmark = pytest.mark.docker


def _docker_ok() -> bool:
    if shutil.which("docker") is None:
        return False
    try:
        return (
            subprocess.run(
                ["docker", "info"], capture_output=True, timeout=20
            ).returncode
            == 0
        )
    except Exception:
        return False


if not _docker_ok():
    pytest.skip("docker is not available", allow_module_level=True)


def _free_port() -> int:
    with socket.socket() as s:
        s.bind(("127.0.0.1", 0))
        return int(s.getsockname()[1])


def _run(args: list[str]) -> str:
    out = subprocess.run(args, capture_output=True, text=True, timeout=120)
    if out.returncode != 0:
        pytest.skip(f"docker run failed ({out.stderr.strip()[:200]})")
    return out.stdout.strip()


def _wait_ready(url: str, seconds: int = 40) -> None:
    deadline = time.time() + seconds
    while time.time() < deadline:
        try:
            if httpx.get(url, timeout=2).status_code < 500:
                return
        except httpx.HTTPError:
            pass
        time.sleep(0.5)
    raise AssertionError(f"{url} did not become ready")


@pytest.fixture(scope="module")
def docker_net():
    """A private network so Caddy reaches MinIO by name on any host (Linux CI and Docker Desktop)."""
    name = f"multai-test-net-{uuid.uuid4().hex[:8]}"
    _run(["docker", "network", "create", name])
    try:
        yield name
    finally:
        subprocess.run(["docker", "network", "rm", name], capture_output=True)


@pytest.fixture(scope="module")
def minio_port(docker_net):
    port = _free_port()
    name = f"multai-minio-test-{uuid.uuid4().hex[:8]}"
    _run(
        [
            "docker", "run", "-d", "--rm", "--name", name,
            "--network", docker_net, "--network-alias", "minio",
            "-p", f"127.0.0.1:{port}:9000",
            "-e", f"MINIO_ROOT_USER={ROOT_USER}",
            "-e", f"MINIO_ROOT_PASSWORD={ROOT_PASSWORD}",
            "-e", f"MINIO_API_CORS_ALLOW_ORIGIN={BROWSER_ORIGIN}",
            MINIO_IMAGE, "server", "/data",
        ]
    )  # fmt: skip
    try:
        _wait_ready(f"http://127.0.0.1:{port}/minio/health/ready")
        yield port
    finally:
        subprocess.run(["docker", "rm", "-f", name], capture_output=True)


@pytest.fixture
def caddy_port(minio_port, docker_net, tmp_path):
    """Caddy on a different host:port than MinIO; Host header passes through."""
    port = _free_port()
    caddyfile = tmp_path / "Caddyfile"
    caddyfile.write_text(
        "{\n  auto_https off\n  admin off\n}\n"
        f":{port} {{\n  reverse_proxy minio:9000\n}}\n"
    )
    name = f"multai-caddy-test-{uuid.uuid4().hex[:8]}"
    _run(
        [
            "docker", "run", "-d", "--rm", "--name", name,
            "--network", docker_net,
            "-p", f"127.0.0.1:{port}:{port}",
            "-v", f"{caddyfile}:/etc/caddy/Caddyfile:ro",
            CADDY_IMAGE,
        ]
    )  # fmt: skip
    try:
        deadline = time.time() + 20
        while time.time() < deadline:
            try:
                httpx.get(f"http://127.0.0.1:{port}/", timeout=2)
                break
            except httpx.HTTPError:
                time.sleep(0.3)
        yield port
    finally:
        subprocess.run(["docker", "rm", "-f", name], capture_output=True)


async def _init(minio_port: int, public_endpoint: str) -> None:
    await init_minio_client(
        "127.0.0.1",
        minio_port,
        ROOT_USER,
        ROOT_PASSWORD,
        public_endpoint=public_endpoint,
        public_secure=False,
    )


def _via(url: str, port: int) -> tuple[str, dict[str, str]]:
    """Send a URL signed for s3.test:<port> to 127.0.0.1:<port> with that Host.

    Same as `curl --resolve s3.test:<port>:127.0.0.1`.
    """
    parts = urlsplit(url)
    host = parts.netloc
    return urlunsplit(parts._replace(netloc=f"127.0.0.1:{port}")), {"Host": host}


@pytest.mark.asyncio
async def test_presigned_put_and_get_roundtrip_on_public_endpoint(minio_port):
    await _init(minio_port, f"127.0.0.1:{minio_port}")
    bucket = Bucket("images", "staging")
    payload = os.urandom(2048)

    put_url = await bucket.presigned_put_url("req/p.bin", expires_seconds=120)
    assert put_url.startswith(f"http://127.0.0.1:{minio_port}/images/staging/req/p.bin?")
    async with httpx.AsyncClient() as http:
        put = await http.put(put_url, content=payload)
        assert put.status_code == 200, put.text
        assert (await bucket.get("req/p.bin"))[0] == payload  # server-side read

        assert Bucket.signing_client is not None
        get_url = await Bucket.signing_client.presigned_get_object(
            "images", "staging/req/p.bin", expires=timedelta(seconds=120)
        )
        got = await http.get(get_url)
    assert got.status_code == 200 and got.content == payload


@pytest.mark.asyncio
async def test_presigned_put_works_through_a_reverse_proxy_on_another_host(
    minio_port, caddy_port
):
    public = f"s3.test:{caddy_port}"
    await _init(minio_port, public)
    bucket = Bucket("images", "staging")
    payload = os.urandom(4096)

    url = await bucket.presigned_put_url("req/proxied.bin", expires_seconds=120)
    assert url.startswith(f"http://{public}/images/staging/req/proxied.bin?")
    target, headers = _via(url, caddy_port)
    async with httpx.AsyncClient() as http:
        put = await http.put(target, headers=headers, content=payload)
    assert put.status_code == 200, put.text
    assert (await bucket.get("req/proxied.bin"))[0] == payload


@pytest.mark.asyncio
async def test_url_signed_for_the_internal_host_is_rejected_by_the_proxy(
    minio_port, caddy_port
):
    """Negative control: this is the production bug the public client fixes."""
    await _init(minio_port, "")  # no public endpoint: URLs keep the internal host
    assert Bucket.signing_client is None
    url = await Bucket("images", "staging").presigned_put_url(
        "req/bad.bin", expires_seconds=120
    )
    assert url.startswith(f"http://127.0.0.1:{minio_port}/")
    target, _ = _via(url, caddy_port)
    async with httpx.AsyncClient() as http:
        put = await http.put(
            target, headers={"Host": f"s3.test:{caddy_port}"}, content=b"x"
        )
    assert put.status_code == 403
    assert "SignatureDoesNotMatch" in put.text


@pytest.mark.asyncio
async def test_cors_preflight_and_response_headers_come_from_minio_only(
    minio_port, caddy_port
):
    public = f"s3.test:{caddy_port}"
    await _init(minio_port, public)
    url = await Bucket("images", "staging").presigned_put_url(
        "req/cors.bin", expires_seconds=120
    )
    target, host = _via(url, caddy_port)
    async with httpx.AsyncClient() as http:
        pre = await http.options(
            target,
            headers={
                **host,
                "Origin": BROWSER_ORIGIN,
                "Access-Control-Request-Method": "PUT",
                "Access-Control-Request-Headers": "content-type",
            },
        )
        assert pre.status_code in (200, 204), pre.text
        assert pre.headers["access-control-allow-origin"] == BROWSER_ORIGIN
        assert "PUT" in pre.headers["access-control-allow-methods"]
        # exactly one value: no duplicated/conflicting headers from the proxy
        assert len(pre.headers.get_list("access-control-allow-origin")) == 1

        put = await http.put(
            target, headers={**host, "Origin": BROWSER_ORIGIN}, content=b"ok"
        )
        assert put.status_code == 200
        assert put.headers["access-control-allow-origin"] == BROWSER_ORIGIN

        other = await http.options(
            target,
            headers={
                **host,
                "Origin": "https://evil.test",
                "Access-Control-Request-Method": "PUT",
            },
        )
    assert other.headers.get("access-control-allow-origin") != "https://evil.test"
