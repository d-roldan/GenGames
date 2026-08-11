# Desarrollo

## Requisitos

Instale Git, Docker Desktop, Node.js 22+, Chrome y Flutter estable. Para Windows
se necesita Visual Studio con “Desarrollo de escritorio con C++”, CMake y Windows
SDK. Para Android se necesita Android Studio, Android SDK y un emulador o teléfono
con depuración USB. Compruebe el entorno con `flutter doctor -v`.

En Windows active **Configuración > Privacidad y seguridad > Para desarrolladores
> Modo de desarrollador** para permitir los symlinks de plugins.

## Plataforma local

Desde la raíz:

```powershell
Copy-Item .env.development.example .env
docker compose up --build -d
docker compose ps
```

La API queda en `http://localhost:8000`, OpenAPI en `/docs`, el panel en
`http://localhost:3000` y PostgreSQL en el puerto local `5432`. El backend aplica
migraciones y carga datos de desarrollo al iniciar.

## Chrome

```powershell
Set-Location mobile
flutter pub get
flutter build web --dart-define=APP_ENV=development --dart-define=API_URL=http://localhost:8000/api/v1
Set-Location ..
docker compose --profile preview up -d web-preview
```

Abra `http://localhost:5173`. El directorio `mobile/build/web` está montado en
Nginx, por lo que cada nueva compilación se sirve sin reconstruir el contenedor.
Si Chrome muestra una compilación vieja o una pantalla en blanco después de una
corrección, use `Ctrl+Shift+R`, cierre la pestaña o pruebe temporalmente
`http://127.0.0.1:5173` para usar un origen limpio. Para que ese origen también
sincronice con la API, agréguelo a `CORS_ORIGINS` en el `.env` local y reinicie el
backend; el ejemplo habilita `localhost:5173` por defecto.

## Windows y Android

```powershell
Set-Location mobile
flutter run -d windows --dart-define=APP_ENV=development --dart-define=API_URL=http://localhost:8000/api/v1
flutter run --flavor development -d emulator-5554 --dart-define=APP_ENV=development --dart-define=API_URL=http://10.0.2.2:8000/api/v1
flutter devices
flutter run --flavor development -d DEVICE_ID --dart-define=APP_ENV=development --dart-define=API_URL=http://IP_LAN_DE_LA_PC:8000/api/v1
```

El emulador Android accede al host mediante `10.0.2.2`. Un teléfono físico y la
PC deben compartir red; autorice el puerto `8000` únicamente en redes privadas.
No se necesita Google Play para instalar una compilación de desarrollo.

## Prueba offline

Abra y use los juegos, detenga `backend` con
`docker compose stop backend` y continúe jugando. Los eventos deben permanecer en
la cola local. Al ejecutar `docker compose start backend`, la app reintenta al
recuperar red o en el ciclo periódico de 30 segundos. El niño no debe ver el
fallo técnico.
