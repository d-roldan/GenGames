# Desarrollo

Instale Flutter estable con los workloads Android y Windows, Docker Desktop y
Node 22. Copie `.env.development.example` a `.env`, inicie Docker Desktop y ejecute
`docker compose up --build`. Para probar pérdida de red, detenga `backend` o
desactive red: los juegos y SQLite siguen disponibles. Al reanudar el contenedor,
SyncService reintenta.

En Windows active **Configuración > Privacidad y seguridad > Para desarrolladores
> Modo de desarrollador** para que Flutter cree symlinks de plugins. Instale
Android Studio con Android SDK/emulador y Visual Studio con "Desarrollo de
escritorio con C++", CMake y Windows SDK. Verifique todo con `flutter doctor -v`.

En Android físico habilite opciones de desarrollador y depuración USB, compruebe
`flutter devices` y use la IP LAN de la PC. Autorice Python/Docker en el firewall
sólo para red privada.
