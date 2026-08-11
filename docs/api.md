# API

OpenAPI está disponible en `/docs`. La API pública versionada expone health,
registro anónimo de instalaciones, eventos individuales/lotes, juegos, manifest,
configuración y versión. `/api/v1/admin/*` requiere Bearer JWT. Los eventos aceptan
`client_event_id` idempotente para que un reintento nunca duplique analítica.

