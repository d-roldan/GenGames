# Entornos

| Entorno | Aplicación Android | Backend/panel | Datos |
| --- | --- | --- | --- |
| Development | `GenGames`, `com.kidsgame.app.dev` | Compose raíz; `localhost:8000` y `localhost:3000` | Volúmenes `gengames_*_dev` y credenciales locales. |
| Staging | `GenGames STAGING`, `com.kidsgame.app.staging` | `infrastructure/staging`, dominios `STAGING_*` y Caddy | PostgreSQL, contenido, red y volumen exclusivos. |
| Production | `GenGames`, `com.kidsgame.app` | `infrastructure/production`, dominios `PRODUCTION_*` y Caddy | PostgreSQL, contenido, red y volumen exclusivos. |

Las URLs se inyectan con `API_URL`; el backend, panel y proxy se configuran con
archivos `.env` ignorados por Git. Los `.env.*.example` contienen únicamente
valores seguros o marcadores.

En development, Android Emulator usa `10.0.2.2` para llegar a la PC y un teléfono
físico usa su IP LAN. Chrome y Windows usan `localhost`.

Las actualizaciones Android de development se publican en
`releases/GenGames-Android-ARM64.apk` y el backend las sirve por el puerto
`8000`. El APK debe compilarse con una `API_URL` alcanzable desde el teléfono.
Staging y producción deben usar sus propios artefactos, URLs, metadata y claves
de firma; nunca deben consumir el APK de development. Consulte
[Actualizaciones Android](android-updates.md).

Las definiciones de staging y producción existen, pero todavía no fueron
desplegadas ni validadas en servidores reales. Nunca deben compartir PostgreSQL,
volúmenes, redes, credenciales o contenido.
