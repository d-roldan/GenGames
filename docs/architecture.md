# Arquitectura

Consulte primero el [contexto del proyecto](project-context.md) para distinguir
el alcance implementado del plan futuro.

## Componentes

GenGames es un monorepo y un monolito modular, no un sistema de microservicios:

- `mobile/`: cliente Flutter offline-first para Android y Windows, con preview
  web para desarrollo.
- `backend/`: API FastAPI versionada, SQLAlchemy y migraciones Alembic.
- `admin/`: panel Next.js separado de la experiencia infantil.
- PostgreSQL: fuente de verdad remota para instalaciones, eventos, catálogo,
  contenido, configuración, versiones y administradores.
- `infrastructure/`: Compose y Caddy separados para staging y producción.

## Flujo offline-first

```text
acción infantil
  -> respuesta inmediata de la UI
  -> persistencia y evento local
  -> sync_queue
  -> intento de registro/sincronización
       -> éxito: confirmar y retirar eventos aceptados
       -> error: conservarlos y reintentar silenciosamente
```

El estado de red sólo dispara intentos; una conexión Wi-Fi no se considera prueba
de acceso al backend. La petición HTTP real determina el éxito. Los assets
esenciales viajan con la aplicación, por lo que backend, Internet y contenido
remoto pueden fallar sin impedir jugar.

## Cliente Flutter

Los juegos se registran mediante `GameDefinition` y no dependen entre sí. Los
servicios compartidos son configuración, audio, almacenamiento, conectividad,
analítica, sincronización, contenido y acceso HTTP.

SQLite guarda datos en disco en plataformas nativas. En Chrome se usa
`sqflite_common_ffi_web` sin SharedWorker, con SQLite WebAssembly e IndexedDB;
esta decisión evita bloqueos de inicialización observados en el preview servido
por Nginx. La carga e instalación de packs usa APIs de archivo nativas y no está
habilitada en el preview web.

## Servidor y administración

La API pública vive bajo `/api/v1`. Los eventos son idempotentes mediante
`client_event_id`; primero debe registrarse la instalación anónima. La API
administrativa vive bajo `/api/v1/admin/*`, usa Bearer JWT y no comparte identidad
con el niño. Toda modificación de esquema se realiza mediante Alembic.

## Decisiones vigentes

- Repositorio `GenGames`; producto visible `KidsGame`.
- Flutter, FastAPI, PostgreSQL, Next.js, Docker Compose y Caddy.
- UUID aleatorio por instalación; sin publicidad ni SDK externo de tracking.
- Software mediante releases de la aplicación; packs y configuración mediante
  el backend propio.
- SemVer desde `0.1.0`; Git/GitHub es la fuente de verdad.
- Development, staging y production aislados por configuración y datos.
