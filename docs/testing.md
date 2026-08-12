# Pruebas

## Suites actuales

- Backend: pytest con SQLite aislado para API pública y administrativa.
- Flutter: trece unit/widget tests para almacenamiento, sincronización, contenido,
  registro de juegos, acceso al área adulta y reglas de Piano Tiles.
- Panel: Vitest para login y componentes funcionales.
- E2E: `tests/e2e/test_sync_flow.py` verifica instalación, lote de eventos y
  consulta administrativa contra los contenedores reales.

## Ejecución local

```powershell
python -m venv .venv
.\.venv\Scripts\python -m pip install -r backend/requirements-dev.txt
Push-Location backend; ..\.venv\Scripts\python -m pytest; Pop-Location
Push-Location admin; npm ci; npm audit --audit-level=high; npm test; npm run build; Pop-Location
Push-Location mobile; flutter pub get; flutter analyze; flutter test; Pop-Location
$env:ADMIN_EMAIL='admin@example.test'
$env:ADMIN_PASSWORD='development-only-password'
python -m pytest tests/e2e/test_sync_flow.py
```

El E2E requiere el Compose de development en ejecución, datos iniciales cargados
y credenciales que coincidan con el `.env` local; las anteriores corresponden al
archivo de ejemplo de development.

## Integración continua

Los workflows se ejecutan en pull requests y pushes a `develop` o `main`:

- Backend: Ruff, pytest con cobertura y migraciones Alembic.
- Flutter: análisis, tests y APK debug del flavor development.
- Actualización Android: comparar SemVer, comprobar metadata/descarga, validar
  nombre, `versionCode`, arquitectura y huella de firma del APK, e instalar
  desde una versión anterior en teléfono físico.
- Panel: auditoría npm, tests y build.

El preview web y los builds release de Windows, APK y AAB todavía no forman parte
de CI. La pérdida/recuperación de red y la ejecución en dispositivos reales deben
validarse manualmente antes de una entrega móvil.
