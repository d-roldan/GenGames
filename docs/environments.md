# Entornos

Development, staging y production usan variables, dominios, redes, bases y
volúmenes separados. Los flavors Android tienen applicationId
`com.kidsgame.app.dev`, `com.kidsgame.app.staging` y `com.kidsgame.app`.

Development usa localhost (emulador Android: `10.0.2.2`; teléfono: IP LAN de la
PC). Staging y producción se levantan con sus Compose dedicados y secretos fuera
de Git. Nunca se reutiliza una base o volumen entre ambos.

