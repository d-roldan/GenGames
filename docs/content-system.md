# Sistema de contenido

La API administrativa acepta un archivo de 1 byte a 100 MB, genera un UUID,
calcula SHA-256 y registra tipo, versión, ruta y tamaño. La API pública publica
los packs habilitados mediante el manifest con UUID, nombre, tipo, versión,
tamaño, checksum y URL de descarga.

`CONTENT_PUBLIC_URL` debe terminar en `/api/v1/content`, como muestran los
archivos `.env.*.example`, porque el manifest concatena allí el UUID del pack.

En plataformas con sistema de archivos nativo, `ContentService`:

1. consulta el manifest;
2. descarga con timeout de 30 segundos a un archivo `.download`;
3. calcula SHA-256 y compara el checksum;
4. conserva el pack anterior si falla la descarga o validación;
5. renombra el temporal al archivo definitivo;
6. registra la versión instalada en SQLite.

Esta versión no descarga automáticamente ni expone una UI de instalación. El
preview web puede consultar la API, pero la instalación de archivos usa
`dart:io` y queda limitada a Android/Windows hasta implementar almacenamiento web
específico.

El código, nuevas funciones y correcciones se distribuirán como software. Las
imágenes, sonidos, animales, escenarios y niveles podrán distribuirse como packs
desde el servidor propio sin comprometer los assets esenciales offline.
