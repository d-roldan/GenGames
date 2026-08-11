# Bases de datos

## Servidor

PostgreSQL contiene:

- `installations`: UUID anónimo, versión, plataforma y actividad;
- `events`: UUID idempotente, instalación, juego, tipo, fechas y metadata JSON;
- `games`: slug, nombre, estado, versión y configuración;
- `content`: UUID, tipo, versión, archivo, tamaño, checksum y estado;
- `remote_config`: valores JSON por clave;
- `app_versions`: versión actual, mínima y última por plataforma;
- `admin_users`: email, hash de contraseña y estado.

Alembic es la única vía de modificación del esquema:

```powershell
Push-Location backend
alembic revision --autogenerate -m "descripcion"
alembic upgrade head
alembic downgrade -1
Pop-Location
```

Development, staging y production usan instancias y volúmenes separados. Antes
de migrar staging o producción debe existir un backup restaurable.

## Cliente

SQLite local contiene `settings`, `stats`, `sync_queue` y `content_versions`. En
Android y Windows la base se ubica en el directorio de soporte de la aplicación;
en Chrome el nombre lógico `gengames.sqlite3` persiste mediante IndexedDB.

No se almacena un perfil del niño. `installation_id` es un UUID aleatorio creado
en el primer arranque.
