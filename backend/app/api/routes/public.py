from datetime import datetime, timezone
from pathlib import Path
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import FileResponse
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.core.config import settings
from app.database.session import get_db
from app.models.entities import AppVersion, Content, Event, Game, Installation, RemoteConfig
from app.schemas.public import ContentManifestItem, EventBatch, EventCreate, EventReceipt, GameOut, InstallationCreate, InstallationOut, VersionOut

router = APIRouter()


@router.get("/health")
def health() -> dict:
    return {"status": "ok", "environment": settings.app_env, "time": datetime.now(timezone.utc)}


@router.post("/installations", response_model=InstallationOut)
def register_installation(payload: InstallationCreate, db: Session = Depends(get_db)):
    uuid = str(payload.installation_uuid)
    item = db.scalar(select(Installation).where(Installation.installation_uuid == uuid))
    if item:
        item.app_version = payload.app_version
        item.platform = payload.platform
        item.last_seen_at = datetime.now(timezone.utc)
    else:
        item = Installation(installation_uuid=uuid, app_version=payload.app_version, platform=payload.platform)
        db.add(item)
    db.commit()
    return InstallationOut(installation_uuid=uuid)


def store_event(payload: EventCreate, db: Session) -> str:
    event_id = str(payload.client_event_id)
    if db.scalar(select(Event).where(Event.client_event_id == event_id)):
        return event_id
    installation = db.scalar(select(Installation).where(Installation.installation_uuid == str(payload.installation_uuid)))
    if not installation:
        raise HTTPException(status_code=409, detail="Installation must be registered first")
    db.add(Event(client_event_id=event_id, installation_id=installation.id, game_id=payload.game_id, event_type=payload.event_type, created_at=payload.created_at, metadata_json=payload.metadata))
    return event_id


@router.post("/events", response_model=EventReceipt)
def create_event(payload: EventCreate, db: Session = Depends(get_db)):
    event_id = store_event(payload, db)
    db.commit()
    return EventReceipt(accepted=[event_id])


@router.post("/events/batch", response_model=EventReceipt)
def create_events(payload: EventBatch, db: Session = Depends(get_db)):
    accepted = [store_event(event, db) for event in payload.events]
    db.commit()
    return EventReceipt(accepted=accepted)


@router.get("/games", response_model=list[GameOut])
def games(db: Session = Depends(get_db)):
    return list(db.scalars(select(Game).where(Game.enabled.is_(True)).order_by(Game.id)))


@router.get("/content/manifest", response_model=list[ContentManifestItem])
def content_manifest(db: Session = Depends(get_db)):
    items = db.scalars(select(Content).where(Content.enabled.is_(True)).order_by(Content.type, Content.name)).all()
    return [ContentManifestItem(content_id=x.content_uuid, name=x.name, version=x.version, type=x.type, size=x.file_size, checksum=x.checksum, download_url=f"{settings.content_public_url}/{x.content_uuid}") for x in items]


@router.get("/content/{content_id}")
def download_content(content_id: str, db: Session = Depends(get_db)):
    item = db.scalar(select(Content).where(Content.content_uuid == content_id, Content.enabled.is_(True)))
    if not item or not Path(item.file_path).is_file():
        raise HTTPException(status_code=404, detail="Content not found")
    return FileResponse(item.file_path, filename=Path(item.file_path).name)


@router.get("/config")
def remote_config(db: Session = Depends(get_db)) -> dict:
    return {item.key: item.value for item in db.scalars(select(RemoteConfig)).all()}


@router.get("/version", response_model=VersionOut)
def version(platform: str = Query(default="android"), db: Session = Depends(get_db)):
    apk_path = settings.android_apk_path
    apk_available = platform == "android" and apk_path.is_file()
    download_fields = {
        "download_url": "/api/v1/app/android/download" if apk_available else None,
        "download_size": apk_path.stat().st_size if apk_available else None,
    }
    item = db.scalar(select(AppVersion).where(AppVersion.platform == platform))
    if not item:
        return VersionOut(platform=platform, version="0.3.1", minimum_supported_version="0.1.0", latest_version="0.3.1", **download_fields)
    return VersionOut(platform=item.platform, version=item.version, minimum_supported_version=item.minimum_supported_version, latest_version=item.latest_version, **download_fields)


@router.get("/app/android/download")
def download_android_app():
    apk_path = settings.android_apk_path
    if not apk_path.is_file():
        raise HTTPException(status_code=404, detail="Android update is not available")
    return FileResponse(
        apk_path,
        filename="GenGames-Android-ARM64.apk",
        media_type="application/vnd.android.package-archive",
    )
