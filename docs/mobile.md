# Aplicación Flutter

Flutter comparte UI y lógica en Android, Windows y el preview de Chrome. Android
dispone de flavors `development`, `staging` y `production`; todas las plataformas
reciben `APP_ENV` y `API_URL` mediante `--dart-define`, sin secretos en el código.

## Experiencia infantil

La pantalla de inicio muestra tres tarjetas grandes:

- **Gatito:** figura interactiva, reacciones visuales, comida, juguete y cama,
  con efectos originales generados localmente.
- **Dibujar:** lienzo táctil, paleta de colores, grosores, goma y limpieza. No
  guarda dibujos todavía.
- **Animales:** perro, gato, vaca, caballo, pato y oveja con animación y sonido.

Cada módulo se publica en el registro común `GameDefinition`. Agregar un juego
requiere crear su pantalla y registrarlo, sin modificar la lógica interna de los
demás.

## Servicios y persistencia

- `AnalyticsService` registra eventos anónimos en la cola local.
- `SyncService` registra la instalación y envía lotes sin bloquear la UI.
- `ConnectivityService` dispara un intento cuando reaparece una interfaz de red;
  la petición HTTP confirma la disponibilidad real.
- `ContentService` consulta manifests e instala packs verificados en plataformas
  con sistema de archivos nativo.
- `AudioService` genera efectos PCM originales localmente.

SQLite conserva `installation_id`, ajustes, estadísticas, eventos pendientes y
versiones de contenido. En Chrome, SQLite WebAssembly persiste el nombre lógico
de la base en IndexedDB y se ejecuta sin SharedWorker por compatibilidad.

## Área para adultos

El candado requiere pulsación prolongada y desafío. El área muestra actividad
local, eventos pendientes, volumen, contenido instalado, versión y entorno. No
es una cuenta de usuario ni almacena datos personales del niño.

## Estado de plataformas

El preview de Chrome está validado en `http://localhost:5173`. Los runners de
Windows y Android y los flavors están versionados, pero la validación manual en
Windows, emulador, teléfono físico y los builds firmados sigue pendiente.
