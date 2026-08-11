"""Initial production schema."""
from alembic import op
import sqlalchemy as sa

revision = "0001_initial"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table("installations", sa.Column("id", sa.Integer(), primary_key=True), sa.Column("installation_uuid", sa.String(36), nullable=False, unique=True), sa.Column("app_version", sa.String(32), nullable=False), sa.Column("platform", sa.String(32), nullable=False), sa.Column("created_at", sa.DateTime(timezone=True), nullable=False), sa.Column("last_seen_at", sa.DateTime(timezone=True), nullable=False))
    op.create_table("games", sa.Column("id", sa.Integer(), primary_key=True), sa.Column("slug", sa.String(80), nullable=False, unique=True), sa.Column("name", sa.String(120), nullable=False), sa.Column("enabled", sa.Boolean(), nullable=False, server_default=sa.true()), sa.Column("version", sa.Integer(), nullable=False, server_default="1"), sa.Column("config", sa.JSON(), nullable=False))
    op.create_table("content", sa.Column("id", sa.Integer(), primary_key=True), sa.Column("content_uuid", sa.String(36), nullable=False, unique=True), sa.Column("name", sa.String(160), nullable=False), sa.Column("type", sa.String(80), nullable=False), sa.Column("version", sa.Integer(), nullable=False), sa.Column("file_path", sa.String(500), nullable=False), sa.Column("file_size", sa.BigInteger(), nullable=False), sa.Column("checksum", sa.String(64), nullable=False), sa.Column("enabled", sa.Boolean(), nullable=False, server_default=sa.true()), sa.Column("created_at", sa.DateTime(timezone=True), nullable=False))
    op.create_table("remote_config", sa.Column("id", sa.Integer(), primary_key=True), sa.Column("key", sa.String(120), nullable=False, unique=True), sa.Column("value", sa.JSON(), nullable=False), sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False))
    op.create_table("app_versions", sa.Column("id", sa.Integer(), primary_key=True), sa.Column("platform", sa.String(32), nullable=False, unique=True), sa.Column("version", sa.String(32), nullable=False), sa.Column("minimum_supported_version", sa.String(32), nullable=False), sa.Column("latest_version", sa.String(32), nullable=False), sa.Column("created_at", sa.DateTime(timezone=True), nullable=False))
    op.create_table("admin_users", sa.Column("id", sa.Integer(), primary_key=True), sa.Column("email", sa.String(320), nullable=False, unique=True), sa.Column("password_hash", sa.String(255), nullable=False), sa.Column("active", sa.Boolean(), nullable=False, server_default=sa.true()), sa.Column("created_at", sa.DateTime(timezone=True), nullable=False))
    op.create_table("events", sa.Column("id", sa.Integer(), primary_key=True), sa.Column("client_event_id", sa.String(36), nullable=False, unique=True), sa.Column("installation_id", sa.Integer(), sa.ForeignKey("installations.id", ondelete="CASCADE"), nullable=False), sa.Column("game_id", sa.String(80), nullable=True), sa.Column("event_type", sa.String(80), nullable=False), sa.Column("created_at", sa.DateTime(timezone=True), nullable=False), sa.Column("received_at", sa.DateTime(timezone=True), nullable=False), sa.Column("metadata", sa.JSON(), nullable=False))
    op.create_index("ix_events_installation_id", "events", ["installation_id"])
    op.create_index("ix_events_event_type", "events", ["event_type"])


def downgrade() -> None:
    op.drop_table("events")
    op.drop_table("admin_users")
    op.drop_table("app_versions")
    op.drop_table("remote_config")
    op.drop_table("content")
    op.drop_table("games")
    op.drop_table("installations")

