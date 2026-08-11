# GenGames / KidsGame

Monorepo de una plataforma infantil offline-first. **GenGames** es el nombre del
repositorio y **KidsGame** el nombre visible inicial del producto.

## Inicio rápido

Requisitos: Git, Docker Desktop, Node.js 22+ y Flutter estable con soporte para
Windows y Android.

```powershell
Copy-Item .env.development.example .env
docker compose up --build -d
docker compose exec backend alembic upgrade head
docker compose exec backend python -m app.scripts.seed
```

Servicios de desarrollo:

- API y documentación OpenAPI: <http://localhost:8000/docs>
- Panel administrativo: <http://localhost:3000>
- PostgreSQL: `localhost:5432` (sólo desarrollo local)

Credenciales de desarrollo: las indicadas en `.env`; cambie todos los secretos
fuera de development.

### Aplicación

```powershell
Set-Location mobile
flutter pub get
flutter run -d windows --dart-define=APP_ENV=development --dart-define=API_URL=http://localhost:8000/api/v1
flutter run --flavor development -d emulator-5554 --dart-define=APP_ENV=development --dart-define=API_URL=http://10.0.2.2:8000/api/v1
flutter devices
flutter run --flavor development -d DEVICE_ID --dart-define=APP_ENV=development --dart-define=API_URL=http://IP_DE_LA_PC:8000/api/v1
```

### Preview en Chrome

```powershell
Set-Location mobile
flutter build web --dart-define=APP_ENV=development --dart-define=API_URL=http://localhost:8000/api/v1
Set-Location ..
docker compose --profile preview up -d web-preview
```

Abra <http://localhost:5173>. Este preview usa SQLite WebAssembly y conserva la
experiencia offline en el almacenamiento del navegador.

En un teléfono físico, la PC y el teléfono deben compartir red y el firewall
debe permitir el puerto 8000. No se necesita Google Play durante desarrollo.

### Pruebas

```powershell
python -m venv .venv
.\.venv\Scripts\python -m pip install -r backend/requirements-dev.txt
Push-Location backend; ..\.venv\Scripts\python -m pytest; Pop-Location
Set-Location admin; npm ci; npm test; npm run build
Set-Location ..\mobile; flutter test; flutter analyze
```

Los archivos `.env*` reales, claves de firma, bases, artefactos y contenido
descargado no se versionan. Consulte [docs/development.md](docs/development.md),
[docs/architecture.md](docs/architecture.md) y [docs/deployment.md](docs/deployment.md).

## Flujo Git

`feature/*` -> PR a `develop` -> staging -> PR a `main` -> release etiquetada
con SemVer. Producción nunca se modifica a mano ni se despliega automáticamente.
