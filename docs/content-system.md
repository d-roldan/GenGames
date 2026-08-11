# Sistema de contenido

El manifest publica UUID, tipo, versión, tamaño, SHA-256 y URL. El cliente compara
versiones, descarga sin bloquear, valida a archivo temporal y sólo entonces hace
reemplazo atómico. Fallos conservan el pack anterior y quedan reintentables.
Código y funciones centrales se distribuyen por Google Play; packs y configuración,
por el servidor propio.

