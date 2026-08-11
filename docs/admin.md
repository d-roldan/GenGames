# Panel administrativo

El panel Next.js se ejecuta en development en `http://localhost:3000` y consume
`NEXT_PUBLIC_API_URL`. Está completamente separado de la UI y la identidad
infantil.

Funciones actuales:

- login con email y contraseña contra `/api/v1/admin/auth/login`;
- tablero con instalaciones, eventos, sesiones, juegos populares y actividad
  reciente;
- listado y edición de nombre, estado, versión y configuración de juegos;
- lectura y edición de configuración remota;
- lectura y edición de versiones por plataforma;
- listado y carga de packs de hasta 100 MB; el backend calcula SHA-256.

El Bearer JWT dura 60 minutos por defecto y el navegador lo conserva en
`sessionStorage`. Las contraseñas se almacenan con el algoritmo recomendado por
`pwdlib` y el usuario inicial se crea desde variables de entorno.

Para producción, el diseño actual necesita endurecimiento: cookie HttpOnly
mediante BFF, protección CSRF si corresponde, límites de intentos en el proxy,
auditoría de cambios administrativos y rotación operativa de credenciales.
