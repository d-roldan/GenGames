from sqlalchemy import select
from app.core.config import settings
from app.core.security import hash_password
from app.database.session import SessionLocal
from app.models.entities import AdminUser, AppVersion, Game, RemoteConfig


def seed() -> None:
    with SessionLocal() as db:
        if not db.scalar(select(AdminUser).where(AdminUser.email == settings.admin_email.lower())):
            db.add(AdminUser(email=settings.admin_email.lower(), password_hash=hash_password(settings.admin_password)))
        for slug, name in [("cat_game", "Gatito"), ("drawing_game", "Dibujar"), ("animals_game", "Animales")]:
            if not db.scalar(select(Game).where(Game.slug == slug)):
                db.add(Game(slug=slug, name=name, enabled=True, version=1, config={}))
        for platform in ("android", "windows"):
            if not db.scalar(select(AppVersion).where(AppVersion.platform == platform)):
                db.add(AppVersion(platform=platform, version="0.1.3", minimum_supported_version="0.1.0", latest_version="0.1.3"))
        if not db.scalar(select(RemoteConfig).where(RemoteConfig.key == "sync")):
            db.add(RemoteConfig(key="sync", value={"batch_size": 50, "interval_seconds": 30}))
        db.commit()


if __name__ == "__main__":
    seed()
