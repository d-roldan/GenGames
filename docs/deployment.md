# Despliegue

El flujo esperado es `feature/*` -> PR -> `develop` -> staging -> validación ->
`main` -> tag SemVer -> producción. Producción requiere una acción humana; los
workflows actuales son de CI y no despliegan.

## Staging o producción

1. Partir de un tag o commit revisado.
2. Copiar `.env.staging.example` a `.env.staging` o
   `.env.production.example` a `.env.production` fuera de Git.
3. Reemplazar secretos y dominios con valores administrados.
4. Crear y probar backups de PostgreSQL y contenido.
5. Validar la configuración resultante de Compose.
6. Levantar el Compose del entorno; el backend aplica `alembic upgrade head` al
   iniciar.
7. Verificar HTTPS, `/api/v1/health`, login administrativo y un flujo de evento.

Si el despliegue incluye una aplicación Android, publicar y verificar su APK/AAB
antes de cambiar la política de versiones. Una metadata adelantada puede hacer
que clientes descarguen el artefacto equivocado. Development usa el mecanismo
descrito en [Actualizaciones Android](android-updates.md); staging y producción
deben reproducir el mismo orden con HTTPS, almacenamiento duradero y firma de
release administrada.

Caddy publica únicamente API y panel. PostgreSQL permanece en la red interna; el
contenido utiliza un volumen separado. Staging y producción nunca comparten
volúmenes o bases.

## Recuperación

Ante una migración fallida: detener escrituras, conservar logs, restaurar el
último backup previamente probado y desplegar el tag anterior si el esquema lo
permite. Verificar salud, migración, login y lectura de eventos antes de reabrir
tráfico.

Las definiciones están preparadas, pero no se consideran producción operativa
hasta validar DNS, certificados, backups/restauración, monitoreo, límites de tasa,
rotación de secretos y un simulacro de rollback en infraestructura real.
