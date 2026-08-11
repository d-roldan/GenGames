# Seguridad

Administración usa hash Argon2 y tokens JWT de corta duración. Producción exige
HTTPS, secretos externos, CORS explícito, límites de carga, logs sin datos
personales, validación Pydantic y PostgreSQL no publicado. Rotar credenciales,
actualizar imágenes y dependencias, limitar intentos en el proxy y auditar altas
administrativas.

