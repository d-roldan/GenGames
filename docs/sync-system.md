# Sincronización

Cada evento se inserta primero en `sync_queue` con UUID idempotente. SyncService
procesa lotes, confirma sólo respuestas exitosas y conserva el resto. Los intentos
usan backoff acotado y se disparan al abrir la app, recuperar conectividad y por
temporizador. Ningún error llega a la interfaz infantil.

