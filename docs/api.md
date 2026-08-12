# API

FastAPI publica la API bajo `/api/v1`; en development la documentación OpenAPI
está en `http://localhost:8000/docs`.

## API pública

| Método y ruta | Función |
| --- | --- |
| `GET /health` | Estado, entorno y hora UTC. |
| `POST /installations` | Registra o actualiza una instalación UUID anónima. |
| `POST /events` | Recibe un evento. |
| `POST /events/batch` | Recibe un lote de eventos. |
| `GET /games` | Lista juegos habilitados. |
| `GET /content/manifest` | Lista packs habilitados y sus checksums. |
| `GET /content/{id}` | Descarga el archivo de un pack. |
| `GET /config` | Devuelve configuración remota por clave. |
| `GET /version?platform=android` | Devuelve versión actual, mínima, última, URL y tamaño del APK cuando está publicado. |
| `GET /app/android/download` | Sirve el APK ARM64 actual para la actualización dentro de la app. |

Los eventos requieren una instalación previamente registrada. Cada
`client_event_id` es único: reenviar el mismo UUID devuelve aceptación sin crear
un duplicado.

## API administrativa

`POST /admin/auth/login` entrega un Bearer JWT. Las demás rutas
`/admin/dashboard`, `/admin/games`, `/admin/config`, `/admin/versions` y
`/admin/content` requieren ese token. Los contratos se validan con Pydantic.

Los errores usan respuestas HTTP; el cliente infantil los captura y conserva su
estado local sin mostrarlos al niño.

La versión anunciada debe actualizarse únicamente después de publicar y
verificar el APK correspondiente. El procedimiento está definido en
[Actualizaciones Android](android-updates.md).
