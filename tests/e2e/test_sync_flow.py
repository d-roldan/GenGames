"""Run against a live development stack: pytest tests/e2e -m e2e."""
import os
from uuid import uuid4
import httpx
import pytest

pytestmark = pytest.mark.e2e


def test_mobile_event_reaches_admin_dashboard():
    base = os.getenv("E2E_API_URL", "http://localhost:8000/api/v1")
    installation, event = str(uuid4()), str(uuid4())
    with httpx.Client(base_url=base, timeout=10) as client:
        assert client.post("/installations", json={"installation_uuid": installation, "app_version": "0.1.0", "platform": "e2e"}).is_success
        assert client.post("/events/batch", json={"events": [{"client_event_id": event, "installation_uuid": installation, "game_id": "cat_game", "event_type": "cat_interaction", "created_at": "2026-01-01T00:00:00Z", "metadata": {"interaction": "head"}}]}).json()["accepted"] == [event]
        token = client.post("/admin/auth/login", json={"email": os.environ["ADMIN_EMAIL"], "password": os.environ["ADMIN_PASSWORD"]}).json()["access_token"]
        dashboard = client.get("/admin/dashboard", headers={"Authorization": f"Bearer {token}"}).json()
        assert dashboard["events"] >= 1
        assert any(item["game"] == "cat_game" for item in dashboard["popular_games"])

