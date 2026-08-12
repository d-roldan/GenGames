# Seguridad

## Controles implementados

- contraseñas administrativas con el hash recomendado por `pwdlib`;
- JWT HS256 con tipo `admin` y vencimiento configurable, 60 minutos por defecto;
- validación Pydantic y eventos idempotentes;
- CORS configurable por entorno;
- archivos de contenido limitados a 100 MB y checksum SHA-256;
- PostgreSQL interno en staging/producción y HTTPS terminado por Caddy;
- secretos reales y datos persistentes excluidos de Git.

## Requisitos antes de producción

- generar secretos largos en un gestor y rotarlos; nunca usar ejemplos;
- migrar el token del panel desde `sessionStorage` a cookie HttpOnly mediante BFF;
- agregar límites de tasa para login, eventos y uploads;
- registrar y auditar cambios administrativos sin datos infantiles;
- restringir tipos de archivo, validar contenido y aplicar cabeceras defensivas;
- automatizar actualización y escaneo de dependencias e imágenes;
- probar backup, restauración, revocación de acceso y respuesta a incidentes;
- revisar TLS, CORS y exposición de puertos en el host real.

El desafío del área adulta es una barrera de UX, no autenticación de seguridad.
Las definiciones de infraestructura no implican que estos controles operativos ya
estén desplegados.

## Actualizador Android

La línea de development declara `REQUEST_INSTALL_PACKAGES` para abrir el
instalador oficial después de una acción del adulto. No concede instalación
silenciosa: Android conserva el permiso por fuente, Play Protect y la
confirmación final. El `applicationId`, la firma y el `versionCode` se validan en
cada publicación.

HTTP y distribución desde una IP LAN se permiten únicamente para desarrollo en
una red privada confiable. Staging y producción requieren HTTPS, almacenamiento
duradero, firma de release protegida y validación criptográfica del artefacto.
Consulte [Actualizaciones Android](android-updates.md) y
[Google Play](google-play.md).
