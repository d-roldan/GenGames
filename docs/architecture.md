# Arquitectura

GenGames es un monolito modular: cliente Flutter offline-first, API FastAPI,
PostgreSQL y panel Next.js. No hay repositorios ni servicios independientes.

La acción infantil siempre termina primero localmente. La aplicación persiste el
evento en SQLite, actualiza la interfaz y, en segundo plano, intenta enviar la
cola. Una confirmación HTTP elimina el elemento; un timeout conserva datos y
aplica backoff. La disponibilidad real se determina por la petición a la API, no
sólo por Wi-Fi.

Los juegos implementan un registro común, pero no dependen entre sí. Los assets
incluidos garantizan juego offline; los packs descargados se escriben a un archivo
temporal, se validan con SHA-256 y se reemplazan atómicamente.

El backend mantiene módulos de instalaciones, eventos, catálogo, contenido,
configuración, versiones y administración. Toda modificación de esquema pasa por
Alembic. La API pública vive bajo `/api/v1`; la API administrativa usa JWT y no
comparte identidad con el niño.

Decisiones: repositorio `GenGames`, producto `KidsGame`; UUID aleatorio por
instalación; sin publicidad ni SDK de tracking; SQLite local y PostgreSQL remoto;
Next.js para el panel; SemVer compartido desde `0.1.0`.

