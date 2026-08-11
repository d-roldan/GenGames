from datetime import datetime, timezone
from hashlib import sha256
from pathlib import Path
from uuid import uuid4
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from pydantic import BaseModel, Field
from sqlalchemy import desc, func, select
from sqlalchemy.orm import Session
from app.api.dependencies import current_admin
from app.core.config import settings
from app.core.security import create_access_token, verify_password
from app.database.session import get_db
from app.models.entities import AdminUser, AppVersion, Content, Event, Game, Installation, RemoteConfig

router = APIRouter()


class Login(BaseModel):
    email: str
    password: str


class GameUpdate(BaseModel):
    name: str = Field(max_length=120)
    enabled: bool
    version: int = Field(ge=1)
    config: dict = Field(default_factory=dict)


class ConfigUpdate(BaseModel):
    value: dict


class VersionUpdate(BaseModel):
    version: str
    minimum_supported_version: str
    latest_version: str


@router.post("/auth/login")
def login(payload: Login, db: Session = Depends(get_db)):
    user = db.scalar(select(AdminUser).where(AdminUser.email == payload.email.lower(), AdminUser.active.is_(True)))
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return {"access_token": create_access_token(user.email), "token_type": "bearer"}


@router.get("/dashboard")
def dashboard(_: AdminUser = Depends(current_admin), db: Session = Depends(get_db)):
    total = db.scalar(select(func.count(Installation.id))) or 0
    events = db.scalar(select(func.count(Event.id))) or 0
    popular = db.execute(select(Event.game_id, func.count(Event.id).label("count")).where(Event.game_id.is_not(None)).group_by(Event.game_id).order_by(desc("count")).limit(5)).all()
    recent = db.scalars(select(Event).order_by(Event.received_at.desc()).limit(10)).all()
    return {"total_installations": total, "active_installations": total, "events": events, "sessions": db.scalar(select(func.count(Event.id)).where(Event.event_type == "app_opened")) or 0, "popular_games": [{"game": row.game_id, "count": row.count} for row in popular], "recent_activity": [{"event": x.event_type, "game": x.game_id, "at": x.received_at} for x in recent]}


@router.get("/games")
def list_games(_: AdminUser = Depends(current_admin), db: Session = Depends(get_db)):
    return db.scalars(select(Game).order_by(Game.id)).all()


@router.put("/games/{slug}")
def update_game(slug: str, payload: GameUpdate, _: AdminUser = Depends(current_admin), db: Session = Depends(get_db)):
    item = db.scalar(select(Game).where(Game.slug == slug))
    if not item:
        raise HTTPException(404, "Game not found")
    item.name, item.enabled, item.version, item.config = payload.name, payload.enabled, payload.version, payload.config
    db.commit()
    db.refresh(item)
    return item


@router.get("/config")
def list_config(_: AdminUser = Depends(current_admin), db: Session = Depends(get_db)):
    return db.scalars(select(RemoteConfig).order_by(RemoteConfig.key)).all()


@router.put("/config/{key}")
def update_config(key: str, payload: ConfigUpdate, _: AdminUser = Depends(current_admin), db: Session = Depends(get_db)):
    item = db.scalar(select(RemoteConfig).where(RemoteConfig.key == key))
    if item:
        item.value, item.updated_at = payload.value, datetime.now(timezone.utc)
    else:
        item = RemoteConfig(key=key, value=payload.value)
        db.add(item)
    db.commit()
    db.refresh(item)
    return item


@router.get("/versions")
def list_versions(_: AdminUser = Depends(current_admin), db: Session = Depends(get_db)):
    return db.scalars(select(AppVersion).order_by(AppVersion.platform)).all()


@router.put("/versions/{platform}")
def update_version(platform: str, payload: VersionUpdate, _: AdminUser = Depends(current_admin), db: Session = Depends(get_db)):
    item = db.scalar(select(AppVersion).where(AppVersion.platform == platform))
    if item:
        item.version = payload.version
        item.minimum_supported_version = payload.minimum_supported_version
        item.latest_version = payload.latest_version
    else:
        item = AppVersion(platform=platform, **payload.model_dump())
        db.add(item)
    db.commit()
    db.refresh(item)
    return item


@router.get("/content")
def list_content(_: AdminUser = Depends(current_admin), db: Session = Depends(get_db)):
    return db.scalars(select(Content).order_by(Content.created_at.desc())).all()


@router.post("/content")
async def upload_content(name: str = Form(...), type: str = Form(...), version: int = Form(...), file: UploadFile = File(...), _: AdminUser = Depends(current_admin), db: Session = Depends(get_db)):
    data = await file.read()
    if not data or len(data) > 100 * 1024 * 1024:
        raise HTTPException(400, "File must contain 1 byte to 100 MB")
    content_id = str(uuid4())
    settings.content_dir.mkdir(parents=True, exist_ok=True)
    suffix = Path(file.filename or "pack.bin").suffix[:12]
    target = settings.content_dir / f"{content_id}{suffix}"
    target.write_bytes(data)
    item = Content(content_uuid=content_id, name=name, type=type, version=version, file_path=str(target), file_size=len(data), checksum=sha256(data).hexdigest(), enabled=True)
    db.add(item)
    db.commit()
    db.refresh(item)
    return item
