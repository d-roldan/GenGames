from datetime import datetime
from typing import Any
from uuid import UUID
from pydantic import BaseModel, ConfigDict, Field


class InstallationCreate(BaseModel):
    installation_uuid: UUID
    app_version: str = Field(max_length=32)
    platform: str = Field(max_length=32)


class InstallationOut(BaseModel):
    installation_uuid: str
    registered: bool = True


class EventCreate(BaseModel):
    client_event_id: UUID
    installation_uuid: UUID
    game_id: str | None = Field(default=None, max_length=80)
    event_type: str = Field(min_length=1, max_length=80)
    created_at: datetime
    metadata: dict[str, Any] = Field(default_factory=dict)


class EventBatch(BaseModel):
    events: list[EventCreate] = Field(min_length=1, max_length=100)


class EventReceipt(BaseModel):
    accepted: list[str]


class GameOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    slug: str
    name: str
    enabled: bool
    version: int
    config: dict[str, Any]


class ContentManifestItem(BaseModel):
    content_id: str
    name: str
    version: int
    type: str
    size: int
    checksum: str
    download_url: str


class VersionOut(BaseModel):
    platform: str
    version: str
    minimum_supported_version: str
    latest_version: str

