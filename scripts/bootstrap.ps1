$ErrorActionPreference = 'Stop'
if (-not (Test-Path .env)) { Copy-Item .env.development.example .env }
docker compose up --build -d
docker compose exec backend python -m app.scripts.seed
Write-Host 'GenGames listo: API http://localhost:8000/docs, panel http://localhost:3000'

