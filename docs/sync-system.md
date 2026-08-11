# Sincronización

Cada evento se inserta primero en `sync_queue` con un UUID idempotente, fecha,
tipo, juego y metadata JSON. La acción infantil no espera al servidor.

`SyncService` ejecuta este flujo:

1. evita dos sincronizaciones simultáneas;
2. registra o actualiza la instalación anónima en `/installations`;
3. lee hasta 50 eventos pendientes;
4. envía el lote a `/events/batch`;
5. elimina únicamente los UUID informados como aceptados;
6. ante cualquier error, conserva la cola e incrementa los intentos.

La sincronización se dispara al abrir la app, cuando `connectivity_plus` informa
una interfaz disponible y cada 30 segundos. La conectividad sólo dispara el
intento: la petición a la API decide si el backend es realmente accesible.

Los fallos guardan `next_attempt_at` a 30 segundos, pero la versión actual no
implementa backoff exponencial ni filtra la cola por esa fecha; el temporizador
de 30 segundos proporciona el reintento efectivo. Ningún error se presenta en la
interfaz infantil.
