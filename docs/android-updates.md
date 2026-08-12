# Actualizaciones Android dentro de GenGames

Este documento define el procedimiento canónico para publicar cambios de la
aplicación Android durante el desarrollo. Desde `0.1.2`, GenGames puede detectar,
descargar e iniciar la instalación de una versión nueva sin cable USB. La
versión `0.1.3` es la primera publicada con el nombre visible definitivo.

## Comportamiento implementado

- Al abrirse, la aplicación consulta `GET /api/v1/version?platform=android`.
- También permite buscar manualmente desde **Área para adultos > Buscar
  actualizaciones**.
- Si `latest_version` es mayor que la versión instalada y existe
  `download_url`, muestra **Nueva actualización**.
- El APK se descarga con progreso al almacenamiento temporal de la aplicación.
- Android solicita, una sola vez por fuente, permiso para que GenGames pueda
  abrir paquetes descargados.
- La aplicación abre el instalador oficial; la confirmación final **Actualizar**
  es obligatoria y no debe intentarse evitar.
- Un error de red se ignora de forma segura: nunca impide jugar offline.

El backend sirve el APK desde `GET /api/v1/app/android/download`. El archivo
local esperado es `releases/GenGames-Android-ARM64.apk`, montado en el contenedor
como `/data/releases/GenGames-Android-ARM64.apk`. Los APK son artefactos locales
y están ignorados por Git.

## Cuándo publicar una versión de la aplicación

| Cambio | ¿Nueva versión Android? |
| --- | --- |
| Dart, UI, juegos, assets incluidos o código nativo Android | Sí |
| Contrato de API requerido por el cliente | Sí |
| Backend compatible, panel administrativo o documentación | No necesariamente |
| Pack descargable de imágenes, sonidos o niveles | No; incrementar la versión del contenido |

No existe hot reload hacia un teléfono que usa una instalación normal. Todo
cambio del cliente que deba verse en ese teléfono requiere un APK con versión y
`versionCode` superiores.

## Fuentes de versión que deben mantenerse alineadas

Para una publicación `X.Y.Z`:

1. `mobile/pubspec.yaml`: `version: X.Y.Z+BUILD`, incrementando siempre `BUILD`.
2. `currentAppVersion` en
   `mobile/lib/core/config/app_version.dart`.
3. Valor inicial y fallback de Android en el backend.
4. Registro `android` de `app_versions`, preferentemente desde el panel
   administrativo o `PUT /api/v1/admin/versions/android`.
5. `VERSION`, `CHANGELOG.md` y `docs/project-context.md` cuando corresponda a
   una release del repositorio.

La metadata del backend se actualiza **al final**, después de publicar y
verificar el APK. Si se anuncia primero, los teléfonos podrían descargar un
artefacto anterior bajo una versión nueva.

## Procedimiento de publicación en development

1. Ejecutar análisis y pruebas:

   ```powershell
   Push-Location mobile
   flutter analyze
   flutter test
   Pop-Location
   Push-Location backend
   ..\.venv\Scripts\python -m pytest
   Pop-Location
   ```

2. Incrementar SemVer y build en las fuentes indicadas arriba.
3. Detectar la IP LAN de la PC y compilar para ARM64:

   ```powershell
   Push-Location mobile
   flutter build apk --debug --flavor development --target-platform android-arm64 `
     --dart-define=APP_ENV=development `
     --dart-define=API_URL=http://IP_LAN_DE_LA_PC:8000/api/v1
   Pop-Location
   ```

4. Verificar antes de publicar:

   - nombre visible `GenGames`;
   - `versionName` y `versionCode` esperados;
   - arquitectura ARM64;
   - misma huella de firma que el APK instalado;
   - permiso `REQUEST_INSTALL_PACKAGES` y `FileProvider` presentes.

5. Copiar el APK completamente construido a
   `releases/GenGames-Android-ARM64.apk`. Para evitar descargas parciales,
   copiar primero con nombre temporal y renombrar al terminar.
6. Actualizar `app_versions` para Android únicamente después de comprobar que
   `GET /api/v1/app/android/download` responde `200`/`206` y sirve el tamaño
   correcto.
7. Verificar `GET /api/v1/version?platform=android` desde la IP LAN.
8. Abrir la versión anterior en el teléfono, instalar desde el aviso y confirmar
   que la versión mostrada en el área de adultos cambió.

## Reglas que no deben romperse

- No cambiar `applicationId` (`com.kidsgame.app.dev`) en la línea de desarrollo:
  es un identificador técnico heredado y no es visible; cambiarlo crea otra app.
- Firmar todas las actualizaciones de una línea con la misma clave. Android
  rechaza una actualización firmada por una clave diferente.
- Nunca publicar una clave de firma, `.env`, APK o AAB en Git.
- No disminuir `versionCode` ni reutilizarlo para otro artefacto.
- Mantener PC y teléfono en la misma red durante development y permitir el
  puerto `8000` solamente en una red privada confiable.
- Play Protect y el instalador pueden pedir confirmación en cada actualización.

La firma debug actual sirve sólo para esta línea local de desarrollo. Antes de
Google Play se debe crear una clave de release administrada y una línea de
distribución separada. Un APK de producción no podrá actualizar encima de una
instalación debug si las firmas son diferentes.

## Recuperación y diagnóstico

- Si no aparece el aviso, comparar la versión del área de adultos con
  `latest_version` del endpoint.
- Si no hay `download_url`, confirmar el montaje `./releases:/data/releases:ro`
  y la existencia del APK.
- Si Android muestra **App no instalada**, comprobar firma, `applicationId`,
  `versionCode` y arquitectura.
- Si no descarga, abrir el endpoint desde el navegador del teléfono y revisar
  que la IP LAN no haya cambiado.
- Las instalaciones anteriores a `0.1.2` no tienen actualizador y requieren una
  última instalación manual mediante el enlace local al APK.
