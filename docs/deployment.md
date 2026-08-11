# Despliegue

Flujo obligatorio: feature -> development -> PR -> develop -> staging -> validación
-> main -> release. Copie el ejemplo de entorno correspondiente en el host,
inyecte secretos desde su gestor y ejecute el Compose del entorno. Aplique
`alembic upgrade head` antes de cambiar tráfico. PostgreSQL permanece en red
interna; el reverse proxy termina HTTPS.

Respaldar base y contenido antes de migrar. Para recuperar: detener escrituras,
restaurar el último backup validado, desplegar el tag anterior si corresponde y
verificar `/api/v1/health`. Producción requiere acción humana deliberada.

