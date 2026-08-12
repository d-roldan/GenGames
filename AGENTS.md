# Instrucciones para agentes y nuevas sesiones

Este archivo es el punto de entrada obligatorio para cualquier persona o agente
que trabaje en GenGames.

## Contexto que debe leerse antes de actuar

1. `README.md`
2. `docs/project-context.md`
3. La documentación del área afectada.
4. Para cualquier cambio del cliente Android: `docs/android-updates.md`.
5. Para commits, ramas, tags o releases: `docs/git-workflow.md` y
   `CHANGELOG.md`.

No asumir que una conversación anterior está disponible. Verificar siempre el
estado real del código, `VERSION`, Git y los servicios locales.

## Identidad y repositorio

- Producto visible: **GenGames**.
- Repositorio oficial: `https://github.com/d-roldan/GenGames`.
- Remoto esperado: `origin`.
- Ramas: `feature/*` -> `develop` -> `main`.
- Tags de release: SemVer anotado con prefijo `v`, por ejemplo `v0.1.3`.
- Las notas de GitHub Release se basan en la sección correspondiente de
  `CHANGELOG.md`.

El identificador Android heredado `com.kidsgame.app.dev` no es marca visible y
no debe cambiarse: Android lo usa, junto con la firma, para reconocer las
actualizaciones y conservar los datos.

## Regla obligatoria para actualizaciones Android

Todo cambio de Dart, UI, juegos, assets incluidos o código nativo que deba llegar
al teléfono se publica como una versión Android superior mediante el actualizador
interno. Seguir de principio a fin `docs/android-updates.md`.

En particular:

- incrementar SemVer y `versionCode`/build;
- alinear todas las fuentes de versión documentadas, incluida
  `currentAppVersion`;
- mantener `applicationId` y firma;
- ejecutar pruebas antes de compilar;
- compilar y verificar el APK ARM64;
- publicar el APK antes de cambiar `latest_version`;
- probar la instalación desde la versión anterior;
- actualizar `VERSION`, `CHANGELOG.md` y contexto cuando corresponda.

No anunciar una versión cuyo APK todavía no esté publicado y verificado.

## Validación mínima

- Flutter: `flutter analyze` y `flutter test` desde `mobile/`.
- Backend: pytest con `backend/requirements-dev.txt`.
- Panel: tests y build cuando cambie `admin/`.
- Documentación: enlaces locales válidos y `git diff --check`.
- Release Android: metadata, nombre GenGames, versión/build, arquitectura y
  huella de firma verificadas.

## Seguridad y archivos locales

Nunca versionar ni publicar:

- `.env` reales, tokens, contraseñas o claves de firma;
- APK/AAB, bases de datos, volúmenes o cachés;
- `.codex-remote-attachments/`;
- artefactos generados o archivos personales.

No ejecutar `git add -A` sin revisar primero los archivos no rastreados. No
crear commits, pushes, tags, releases ni despliegues salvo solicitud explícita
del usuario.
