from uuid import uuid4
from app.core.config import settings


def test_health_and_defaults(client):
    assert client.get("/api/v1/health").json()["status"] == "ok"
    assert len(client.get("/api/v1/games").json()) == 4
    assert client.get("/api/v1/version?platform=android").json()["latest_version"] == "0.2.0"


def test_android_download_is_absent_when_no_release_is_published(client, tmp_path):
    previous = settings.android_apk_path
    settings.android_apk_path = tmp_path / "missing.apk"
    try:
        response = client.get("/api/v1/app/android/download")
        assert response.status_code == 404
    finally:
        settings.android_apk_path = previous


def test_android_release_metadata_and_download(client, tmp_path):
    previous = settings.android_apk_path
    apk = tmp_path / "GenGames.apk"
    apk.write_bytes(b"development apk")
    settings.android_apk_path = apk
    try:
        metadata = client.get("/api/v1/version?platform=android").json()
        assert metadata["download_url"] == "/api/v1/app/android/download"
        assert metadata["download_size"] == len(b"development apk")
        download = client.get(metadata["download_url"])
        assert download.status_code == 200
        assert download.content == b"development apk"
        assert download.headers["content-type"] == "application/vnd.android.package-archive"
    finally:
        settings.android_apk_path = previous


def test_register_and_idempotent_event_batch(client):
    installation = str(uuid4())
    event = str(uuid4())
    response = client.post("/api/v1/installations", json={"installation_uuid": installation, "app_version": "0.1.0", "platform": "android"})
    assert response.status_code == 200
    payload = {"events": [{"client_event_id": event, "installation_uuid": installation, "game_id": "cat_game", "event_type": "cat_interaction", "created_at": "2026-01-01T12:00:00Z", "metadata": {"interaction": "head"}}]}
    assert client.post("/api/v1/events/batch", json=payload).json() == {"accepted": [event]}
    assert client.post("/api/v1/events/batch", json=payload).json() == {"accepted": [event]}


def test_event_requires_registered_installation(client):
    response = client.post("/api/v1/events", json={"client_event_id": str(uuid4()), "installation_uuid": str(uuid4()), "event_type": "app_opened", "created_at": "2026-01-01T12:00:00Z"})
    assert response.status_code == 409
