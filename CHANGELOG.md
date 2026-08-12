# Historial de versiones

## v0.3.0 — Piano Tiles rítmico

- Biblioteca con tres canciones originales offline de pop, rock y electropop,
  cada una con identidad, BPM, dificultad y velocidad de aproximación propios.
- Mapas de notas sincronizados con los golpes musicales en lugar de una
  secuencia visual independiente del audio.
- Nuevas notas dobles `×2` para tocar con dos dedos y notas largas identificadas
  con una mano y la indicación **MANTENER**.
- Evaluación de precisión `Perfect`, `Great`, `Good` y `Miss`, combo, exactitud,
  progreso, récord por canción y puntos animados durante la interpretación.
- El audio y el reloj de juego permanecen sincronizados; errar o dejar pasar una
  nota rompe el combo pero la canción continúa hasta el final.

## v0.2.1 — Piano Tiles renovado

- Flujo continuo con varias baldosas simultáneas, tres secciones y velocidad creciente.
- Nueva pista musical original y offline que acompaña toda la partida.
- Notas de piano polifónicas en cada acierto, sin interrumpir la música de fondo.
- Modo acompañado: los errores y las baldosas perdidas rompen el combo, pero no terminan la canción.
- Barra de progreso, combo, precisión, animaciones de nivel y resumen final mejorado.

## v0.2.0 — Piano Tiles

- Nuevo juego **Piano Tiles** con cuatro carriles y controles táctiles grandes.
- Melodía original generada localmente nota por nota, disponible sin conexión.
- La partida se detiene al tocar un carril incorrecto o dejar pasar una baldosa.
- Puntaje, nivel, récord local y resumen final con opción de volver a jugar.
- Cada diez aciertos aumenta el nivel y la velocidad de las baldosas.
- Analítica anónima registra inicio y fin de partida con puntaje, nivel y motivo.

## v0.1.3 — Identidad GenGames y actualización dentro de la app

- El nombre visible del producto pasa a ser **GenGames** en Android, Flutter y
  web, conservando el identificador Android heredado para mantener los datos.
- La aplicación detecta nuevas versiones al abrir y desde el área para adultos.
- Descarga el APK ARM64 con progreso y abre el instalador oficial de Android.
- El backend publica metadata, tamaño y endpoint de descarga de la versión.
- Se documenta el procedimiento obligatorio de publicación para que toda nueva
  versión del cliente pueda instalarse desde la aplicación.

## v0.1.2 — Actualizador Android inicial

- Primera versión con `UpdateService`, permiso de instalación por fuente y
  `FileProvider` para actualizar sin USB dentro de la red local.
- Validación en emulador Android y teléfono físico mediante APK ARM64.

## v0.1.1 — Contexto y documentación operativa

Esta actualización compatible convierte la documentación en una fuente de verdad
útil para usuarios y asistentes de IA, sin cambiar el comportamiento de los
minijuegos.

### Cambios

- Nuevo `docs/project-context.md` con visión, principios, arquitectura resumida,
  estado implementado, validaciones, limitaciones y próximos pasos.
- Revisión completa del README y de la documentación de aplicación, API, panel,
  almacenamiento, sincronización, contenido, entornos, despliegue, pruebas,
  seguridad, privacidad, Git y Google Play.
- Separación explícita entre funciones implementadas, funciones validadas y
  preparación aún pendiente.
- Corrección de `CONTENT_PUBLIC_URL` en todos los ejemplos de entorno para usar
  la ruta pública real `/api/v1/content`.
- Alineación de la versión del monorepo, Flutter, backend y panel en `0.1.1`.

## v0.1.0 — Primera versión funcional

GenGames es una plataforma infantil offline-first cuyo producto inicial se
presenta como KidsGame. Esta versión reúne una aplicación jugable, una API y
un panel de administración en un monorepo preparado para desarrollo local.

### Aplicación infantil

- Tres juegos independientes y funcionales: Gatito, Dibujar y Animales.
- Interfaz visual simple, con controles grandes y navegación adecuada para
  niños pequeños.
- Funcionamiento offline con instalación anónima, estadísticas locales y cola
  de eventos pendiente de sincronización.
- Área para adultos protegida mediante pulsación prolongada y desafío.
- Soporte inicial para Android y Windows, además de preview jugable en Chrome.
- Persistencia web mediante SQLite WebAssembly e IndexedDB.

### Plataforma y contenido

- API REST desarrollada con FastAPI y almacenamiento PostgreSQL.
- Migraciones de base de datos, carga de datos iniciales y documentación
  OpenAPI.
- Sincronización de eventos offline y distribución de paquetes de contenido
  con validación de checksum e instalación atómica.
- Panel administrativo autenticado para gestionar el contenido.

### Desarrollo y calidad

- Entorno reproducible con Docker Compose para API, PostgreSQL, panel y preview
  web.
- Configuraciones separadas para desarrollo, staging y producción.
- Pruebas automatizadas de backend, panel, almacenamiento, contenido, registro
  de juegos y acceso de adultos.
- Análisis estático y flujos de integración y despliegue continuo.

### Alcance de esta entrega

Es una primera versión funcional orientada a pruebas locales. El preview web se
sirve en `http://localhost:5173`; el empaquetado y la distribución final para
Windows se abordarán en una versión posterior.
