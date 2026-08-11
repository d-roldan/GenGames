import os
from pathlib import Path

os.environ["DATABASE_URL"] = "sqlite:///./test_gengames.sqlite3"
os.environ["CONTENT_DIR"] = "./test_content"
os.environ["JWT_SECRET"] = "test-secret-with-more-than-thirty-two-characters"

import pytest
from fastapi.testclient import TestClient
from app.database.base import Base
from app.database.session import SessionLocal, engine
from app.main import app
from app.models import entities  # noqa: F401
from app.scripts.seed import seed


@pytest.fixture(autouse=True)
def clean_database():
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    seed()
    yield
    Base.metadata.drop_all(engine)
    path = Path("test_content")
    if path.exists():
        for item in path.iterdir():
            item.unlink()
        path.rmdir()


@pytest.fixture
def client():
    with TestClient(app) as value:
        yield value


@pytest.fixture
def db():
    with SessionLocal() as value:
        yield value

