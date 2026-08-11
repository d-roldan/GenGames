# Panel administrativo

Next.js consume la API administrativa. Incluye login, métricas, juegos, contenido,
configuración y versiones. El token se mantiene en memoria/sessionStorage y nunca
se integra con la experiencia infantil. En producción se recomienda cookie HttpOnly
mediante BFF y controles de tasa en el reverse proxy.

