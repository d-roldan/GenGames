# Google Play

Development se instala directamente con `flutter run`. Staging podrá distribuirse
como APK/AAB privado y production deberá pasar primero por Internal Testing.

Comandos previstos:

```powershell
Set-Location mobile
flutter build apk --flavor staging --dart-define=APP_ENV=staging --dart-define=API_URL=https://staging-api.example.com/api/v1
flutter build appbundle --flavor production --dart-define=APP_ENV=production --dart-define=API_URL=https://api.example.com/api/v1
```

La versión `v0.1.3` todavía no es una entrega de Google Play: la configuración
release de Android usa temporalmente la firma debug. Antes de distribuir se debe
crear un keystore seguro, configurar `key.properties` fuera de Git, proteger las
credenciales, incrementar versión/build y validar APK/AAB en dispositivos.

La actualización directa documentada para development no sustituye Google Play.
Una instalación firmada con la clave debug no puede actualizarse con una firma
de producción distinta; ambas líneas deben tratarse como distribuciones
separadas. En producción se preferirá el mecanismo de actualizaciones de Google
Play y no el permiso de instalación desde fuentes desconocidas.

La promoción pública requiere además ficha y clasificación, política Families,
Data safety, política de privacidad publicada, revisión de permisos, pruebas
offline y online, accesibilidad, Internal Testing y un plan de actualización y
rollback. Los packs de contenido no deben reemplazar código ejecutable ni eludir
la revisión de Google Play.
