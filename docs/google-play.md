# Google Play

Development se instala con `flutter run`; staging mediante APK/AAB privado;
production pasa primero por Internal Testing. Generación:

```sh
flutter build apk --flavor staging --dart-define=APP_ENV=staging --dart-define=API_URL=https://staging-api.example.com/api/v1
flutter build appbundle --flavor production --dart-define=APP_ENV=production --dart-define=API_URL=https://api.example.com/api/v1
```

La clave de firma y `key.properties` viven fuera de Git. Incrementar SemVer/build,
probar offline y validar política Families antes de promoción pública.

