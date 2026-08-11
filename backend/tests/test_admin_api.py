from io import BytesIO
from uuid import uuid4


def auth_headers(client):
    response = client.post("/api/v1/admin/auth/login", json={"email": "admin@example.test", "password": "development-only-password"})
    assert response.status_code == 200
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


def test_admin_login_rejects_bad_password(client):
    response = client.post("/api/v1/admin/auth/login", json={"email": "admin@example.test", "password": "wrong"})
    assert response.status_code == 401


def test_dashboard_sees_synced_event(client):
    headers = auth_headers(client)
    installation = str(uuid4())
    client.post("/api/v1/installations", json={"installation_uuid": installation, "app_version": "0.1.0", "platform": "windows"})
    client.post("/api/v1/events", json={"client_event_id": str(uuid4()), "installation_uuid": installation, "game_id": "drawing_game", "event_type": "drawing_started", "created_at": "2026-01-01T12:00:00Z", "metadata": {}})
    dashboard = client.get("/api/v1/admin/dashboard", headers=headers).json()
    assert dashboard["total_installations"] == 1
    assert dashboard["events"] == 1
    assert dashboard["popular_games"][0]["game"] == "drawing_game"


def test_manage_game_config_version_and_content(client):
    headers = auth_headers(client)
    assert client.put("/api/v1/admin/games/cat_game", headers=headers, json={"name": "Gatito feliz", "enabled": True, "version": 2, "config": {"toy": True}}).status_code == 200
    assert client.put("/api/v1/admin/config/home", headers=headers, json={"value": {"animation": True}}).status_code == 200
    assert client.put("/api/v1/admin/versions/android", headers=headers, json={"version": "0.2.0", "minimum_supported_version": "0.1.0", "latest_version": "0.2.0"}).status_code == 200
    response = client.post("/api/v1/admin/content", headers=headers, data={"name": "Granja", "type": "animal_pack", "version": "1"}, files={"file": ("farm.pack", BytesIO(b"safe pack"), "application/octet-stream")})
    assert response.status_code == 200
    manifest = client.get("/api/v1/content/manifest").json()
    assert manifest[0]["name"] == "Granja"
    assert client.get(f"/api/v1/content/{manifest[0]['content_id']}").content == b"safe pack"

