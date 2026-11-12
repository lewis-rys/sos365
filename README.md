# SOS365

Aplicación Flutter de emergencia con botón de pánico y contactos rápidos.

## Configuración segura

No guardes credenciales, claves API, contraseñas ni cadenas de conexión en el
repositorio ni dentro de una aplicación distribuida.

La conexión de desarrollo puede recibir `MONGO_URI` mediante
`--dart-define=MONGO_URI=...`. No incluyas ese valor en builds públicos:
MongoDB y el envío de correo deben ejecutarse detrás de un backend autenticado.

Las contraseñas nuevas se almacenan como hash con salt; las cuentas antiguas
que todavía usen el campo `contrasena` deben migrarse mediante un backend antes
de volver a habilitarse.
