from uuid import uuid4


def test_health_and_defaults(client):
    assert client.get("/api/v1/health").json()["status"] == "ok"
    assert len(client.get("/api/v1/games").json()) == 3
    assert client.get("/api/v1/version?platform=android").json()["latest_version"] == "0.1.0"


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

