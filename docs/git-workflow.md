# Flujo Git

GitHub es la fuente de verdad: <https://github.com/d-roldan/GenGames>.

- `main`: releases estables y potencialmente desplegables.
- `develop`: integración de cambios aprobados.
- `feature/<tema>`: trabajo aislado que se integra mediante pull request.

Use Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`), PR con CI verde y
tags SemVer anotados. La primera release es `v0.1.0`. Una nueva versión debe
actualizar `VERSION`, `mobile/pubspec.yaml`, `CHANGELOG.md` y
`docs/project-context.md` antes de crear el tag.

No se versionan secretos, `.env` reales, bases, volúmenes, dependencias,
artefactos de build, APK/AAB ni claves de firma. Sí se versionan migraciones,
locks, configuración de ejemplo y todo lo necesario para reconstruir el sistema.

Flujo recomendado:

```text
feature/* -> PR a develop -> CI -> staging -> validación
          -> PR/merge a main -> tag SemVer -> release deliberada
```

Ningún cambio debe existir únicamente en un servidor o computadora.
