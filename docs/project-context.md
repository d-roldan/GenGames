# Contexto del proyecto

Este documento es la puerta de entrada para entender GenGames. Resume qué se
busca construir, qué existe hoy y qué sigue pendiente. Está escrito para
personas y asistentes de IA; no reemplaza la documentación técnica enlazada.

## Identidad y propósito

- **Repositorio:** GenGames.
- **Producto visible inicial:** KidsGame.
- **Repositorio remoto:** <https://github.com/d-roldan/GenGames>.
- **Versión publicada:** `v0.1.0` (`mobile/pubspec.yaml`: `0.1.0+1`).
- **Público principal:** niños de aproximadamente 3 años y sus adultos
  responsables.

KidsGame busca reunir múltiples minijuegos en una sola aplicación infantil. La
experiencia debe ser visual, inmediata y comprensible sin lectura: abrir la app,
ver tarjetas grandes, tocar y jugar. El proyecto no se plantea como un prototipo
descartable, sino como una base modular que pueda crecer hacia más juegos,
contenido descargable, Android, Windows, staging, producción y Google Play.

## Principios que no deben romperse

1. **Offline-first:** jugar nunca depende de que el backend esté disponible.
2. **Experiencia infantil:** no se muestran errores técnicos, publicidad, login,
   chat ni configuraciones complejas al niño.
3. **Privacidad:** no se recopilan datos personales del niño; la instalación se
   identifica con un UUID aleatorio.
4. **Modularidad útil:** cada juego es independiente y se registra mediante una
   definición común, sin microservicios ni abstracciones innecesarias.
5. **Fuente de verdad:** código, configuración de ejemplo y documentación viven
   en Git/GitHub. No se hacen cambios exclusivos en producción.
6. **Entornos separados:** development, staging y production no comparten bases,
   volúmenes ni secretos.

## Estado actual: v0.1.0

### Implementado

| Área | Estado actual |
| --- | --- |
| Aplicación Flutter | Inicio infantil, área para adultos y tres juegos registrados como módulos independientes. |
| Gatito | Reacciones visuales y sonidos originales generados localmente para interacciones y objetos. |
| Dibujar | Lienzo táctil, colores, grosores, goma y limpieza. El guardado de dibujos aún no está implementado. |
| Animales | Perro, gato, vaca, caballo, pato y oveja con animación y sonido local. |
| Persistencia | SQLite nativo; SQLite WebAssembly e IndexedDB en Chrome. Guarda instalación, ajustes, estadísticas, cola y versiones de contenido. |
| Sincronización | Registro anónimo, eventos en lote, idempotencia por UUID y reintento silencioso al abrir, recuperar red y cada 30 segundos. |
| Contenido | Manifest, descarga, SHA-256, archivo temporal e instalación atómica en plataformas nativas. |
| Backend | FastAPI bajo `/api/v1`, PostgreSQL, SQLAlchemy, Alembic y datos iniciales. |
| Administración | Next.js con login JWT, tablero, juegos, configuración, versiones y carga de contenido. |
| Infraestructura | Docker Compose local y definiciones separadas para staging y producción con Caddy. |
| Calidad | Tests de backend, Flutter, panel y flujo E2E; CI para las tres aplicaciones. |

### Validado

- Los contenedores locales de PostgreSQL, backend y panel levantan juntos.
- El flujo E2E registra una instalación, sincroniza un evento y permite verlo
  desde la API administrativa.
- El preview web abre en Chrome en `http://localhost:5173` y permite entrar a los
  juegos. Se comprobó específicamente el menú y Gatito.
- El análisis estático de Flutter y sus siete tests pasan en la versión `v0.1.0`.
- Las suites de backend y panel y el build del panel pasaron durante la
  preparación de la versión.

### Preparado pero no validado como entrega final

- Los runners de Windows y Android existen, pero falta completar la validación
  manual en Windows, Android Emulator y un teléfono físico.
- Los flavors Android development, staging y production están configurados,
  pero todavía no se validaron APK/AAB firmados para distribución.
- Los Compose de staging y producción y sus proxies existen, pero aún no se han
  desplegado en servidores reales.
- Google Play, firma de release, Internal Testing, backups operativos y monitoreo
  productivo siguen pendientes.

### Limitaciones conocidas

- El cliente todavía no tiene un `ProgressService` específico ni progreso por
  nivel; conserva estadísticas generales y eventos.
- La aplicación no descarga contenido automáticamente ni ofrece aún una UI de
  gestión de packs. La descarga implementada usa archivos nativos y no está
  habilitada para el preview web.
- Los archivos `.env` creados antes de esta revisión pueden conservar una
  `CONTENT_PUBLIC_URL` sin `/api/v1`; deben alinearse con los ejemplos actuales
  antes de probar descargas reales.
- La configuración remota y la política de versiones están expuestas por la API
  y el panel, pero aún no modifican activamente la experiencia infantil.
- La versión `0.1.0` aparece en algunos puntos del cliente además de
  `pubspec.yaml`; debe centralizarse antes de la próxima versión.
- La autenticación administrativa usa Bearer JWT en `sessionStorage`. Para
  producción se recomienda migrar a cookie HttpOnly mediante un BFF.
- El reintento actual es periódico, no un backoff exponencial persistente.

## Arquitectura en una mirada

```text
Flutter (Windows / Android / Chrome preview)
  ├─ juegos y assets esenciales locales
  ├─ SQLite / IndexedDB
  ├─ AnalyticsService -> sync_queue
  ├─ SyncService ------ HTTPS ------┐
  └─ ContentService ----------------┤
                                    v
                         FastAPI + PostgreSQL
                                    ^
                                    |
                         Panel administrativo Next.js
```

Ante una acción infantil, la UI responde y persiste localmente primero. Si la
API está disponible, `SyncService` registra la instalación y envía los eventos
pendientes. Un error conserva la cola y nunca bloquea el juego.

El backend es un monolito modular. Staging y producción usan contenedores,
PostgreSQL, contenido, redes, dominios y secretos separados. Caddy termina HTTPS
en esos entornos.

## Dirección del producto

La arquitectura debe permitir agregar minijuegos como rompecabezas, globos,
vehículos, música, colores, números, formas, memoria y plataformas con personajes
originales. Las funciones centrales se distribuirán como nuevas versiones de la
aplicación; imágenes, sonidos, niveles y packs podrán llegar desde el servidor.

Prioridades próximas sugeridas:

1. Validar y corregir la ejecución en Windows.
2. Validar Android Emulator y teléfono físico, incluida pérdida y recuperación
   de conectividad.
3. Centralizar la versión de la aplicación y completar progreso local.
4. Integrar configuración, versiones y contenido remoto en la app sin afectar el
   funcionamiento offline.
5. Validar staging real, backups y restauración.
6. Preparar firma, APK/AAB e Internal Testing de Google Play.

## Mapa documental

- [README](../README.md): instalación rápida y comandos cotidianos.
- [Arquitectura](architecture.md): componentes y decisiones técnicas.
- [Desarrollo](development.md): ejecución local y plataformas de prueba.
- [Aplicación Flutter](mobile.md): juegos, servicios y almacenamiento local.
- [API](api.md), [base de datos](database.md) y
  [panel administrativo](admin.md): plataforma del servidor.
- [Sincronización](sync-system.md) y [contenido](content-system.md): flujos
  offline-first.
- [Entornos](environments.md) y [despliegue](deployment.md): operación.
- [Seguridad](security.md) y [privacidad](privacy.md): restricciones del producto.
- [Pruebas](testing.md): cobertura existente y verificaciones pendientes.
- [Historial de versiones](../CHANGELOG.md): cambios por release.

## Regla de mantenimiento para personas e IAs

Antes de modificar el proyecto, leer este documento, el README y la documentación
del área afectada. Verificar siempre el código antes de afirmar que una función
existe. Cuando cambien alcance, arquitectura, estado validado o próximos pasos,
actualizar este archivo en el mismo commit. Cuando se publique una versión,
actualizar también `VERSION`, `mobile/pubspec.yaml`, `CHANGELOG.md` y el tag Git
según corresponda.

No registrar aquí secretos, credenciales reales, datos personales ni contenido
que sólo exista en una computadora.
