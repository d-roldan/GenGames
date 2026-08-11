# Base de datos

PostgreSQL almacena installations, events, games, content, remote_config,
app_versions y admin_users. Alembic es la única vía de cambio de esquema.

```sh
alembic revision --autogenerate -m "descripcion"
alembic upgrade head
alembic downgrade -1
```

