# Pruebas

Backend usa pytest con SQLite aislado; Flutter incluye unit/widget tests para
almacenamiento, cola, contenido y navegación; admin usa Vitest. CI ejecuta análisis,
tests y builds en cada PR y push a `develop` o `main`.

La matriz offline cubre inicio sin red, persistencia tras reinicio, backend caído,
timeout no bloqueante, reintento, confirmación y descarga atómica con checksum.

