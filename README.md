# OffBeat

Plataforma compuesta por varios servicios backend (Spring Boot + MySQL) levantados con Docker Compose, un **API Gateway** que es el punto de entrada único al backend, y un frontend aparte.

Cada servicio vive en **su propio repositorio**, por lo que hay que clonarlos todos dentro de una misma carpeta contenedora.

## Arquitectura

```
Frontend (5173) ──► Gateway (8080) ──┬──► Usuarios  (8082)  [usuarios, comentarios]
                                     ├──► Productos (8081)  [productos, categorías]
                                     ├──► Compras   (8083)
                                     └──► Blogs     (8084)
```

El **Gateway** (Spring Cloud Gateway + Spring Security) se encarga de:

- **Enrutar** las peticiones `/api/v1/**` al microservicio correspondiente.
- **Validar el JWT** (firmado con `JWT_SECRET`) y aplicar los permisos por rol (`admin`, `vendedor`, `cliente`).
- **CORS**: permite el origen `http://localhost:5173` (frontend).

## Estructura de carpetas requerida

Todos los repos deben estar en la misma carpeta (al mismo nivel), junto con el `docker-compose.yml`, el `.env` y la carpeta `mysql-init`:

```
OffBeat_Contenedor/
├── docker-compose.yml
├── .env
├── mysql-init/
├── OffBeat-Backend-Usuarios/
├── OffBeat-Backend-Productos/
├── OffBeat-Backend-Blogs/
├── OffBeat-Backend-Compras/
├── OffBeat-Gateway/
└── OffBeat-Frontend/
```

## Requisitos

- [Docker](https://www.docker.com/) y Docker Compose v2
- [Node.js](https://nodejs.org/) (LTS) y npm, para el frontend
- Puertos libres: `3307`, `8080`, `8081`, `8082`, `8083`, `8084` (y el del frontend)

## 1. Clonar los repositorios

```bash
git clone <url-repo-OffBeat_Contenedor>

git clone <url-repo-usuarios>
git clone <url-repo-productos>
git clone <url-repo-blogs>
git clone <url-repo-compras>
git clone <url-repo-gateway>
git clone <url-repo-frontend>
```

Asegurate de que todo esté en la misma carpeta `OffBeat_Contenedor` y que cada carpeta tenga el nombre exacto indicado arriba.

## 2. Configurar variables de entorno

Creá un archivo `.env` (si no está en el repositorio `OffBeat_Contenedor`):

```env
MYSQL_ROOT_PASSWORD=<password-root>
MYSQL_USER=offbeat
MYSQL_PASSWORD=<password-usuario>
JWT_SECRET=<secreto-jwt-en-base64>
```

Para generar un `JWT_SECRET` seguro:

```bash
openssl rand -base64 32
```

> ⚠️ El `JWT_SECRET` debe estar en **Base64** y ser **el mismo** para el servicio de Usuarios (que firma los tokens) y para el Gateway (que los valida). Si difieren, el Gateway rechazará todos los tokens con `401`.

## 3. Levantar los servicios backend (Docker Compose)

Desde la carpeta contenedora:

```bash
docker compose up -d --build
```

Esto levanta MySQL, los cuatro microservicios y el Gateway. MySQL arranca primero y los demás esperan a que esté saludable (healthcheck).

| Servicio  | Contenedor                  | Puerto | Base de datos       |
|-----------|-----------------------------|--------|---------------------|
| MySQL     | `offbeat-mysql`             | 3307   | —                   |
| Usuarios  | `OffBeat-Backend-Usuarios`  | 8082   | `offbeat_usuarios`  |
| Productos | `OffBeat-Backend-Productos` | 8081   | `offbeat_productos` |
| Blogs     | `OffBeat-Backend-Blogs`     | 8084   | `offbeat_blogs`     |
| Compras   | `OffBeat-Backend-Compras`   | 8083   | `offbeat_compras`   |
| Gateway   | `OffBeat-Gateway`           | 8080   | —                   |

MySQL se expone en el puerto **3307** del host (internamente es 3306) para no chocar con un MySQL local.


### Comandos útiles

```bash
docker compose ps                       # ver estado de los contenedores
docker compose logs -f                  # ver logs de todos los servicios
docker compose logs -f usuarios         # logs de un servicio puntual
docker compose logs -f gateway          # logs del gateway
docker compose down                     # detener y eliminar contenedores
docker compose down -v                  # además borra volúmenes (¡borra la base de datos!)
docker compose up -d --build usuarios   # reconstruir un solo servicio
docker compose up -d --build gateway    # reconstruir solo el gateway
docker compose stop                     # apagar los contenedores
```

## 4. Levantar el frontend

En otra terminal:

```bash
cd OffBeat-Frontend
npm install
npm run dev
```

Por defecto se abre en `http://localhost:5173` (o la URL que indique la consola).

**El frontend debe apuntar únicamente al Gateway**, no a cada microservicio:

- API base: `http://localhost:8080`

Ejemplos: `http://localhost:8080/api/v1/productos`, `http://localhost:8080/api/v1/usuarios/login`, etc.

> Si el frontend corre en un puerto distinto a `5173`, hay que agregarlo a `allowed-origins` en el `application.properties` del Gateway; de lo contrario el navegador bloqueará las peticiones por CORS.
