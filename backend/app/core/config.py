from functools import lru_cache
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_env: str = "development"
    database_url: str = "sqlite:///./gengames.sqlite3"
    jwt_secret: str = "development-only-secret-change-before-sharing"
    jwt_expire_minutes: int = 60
    admin_email: str = "admin@example.test"
    admin_password: str = "development-only-password"
    cors_origins: str = "http://localhost:3000"
    content_dir: Path = Path("/data/content")
    content_public_url: str = "http://localhost:8000/content"
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @property
    def cors_origin_list(self) -> list[str]:
        return [value.strip() for value in self.cors_origins.split(",") if value.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()

