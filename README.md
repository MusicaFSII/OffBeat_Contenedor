# OffBeat

Plataforma compuesta por varios servicios backend (Spring Boot + MySQL) levantados con Docker Compose y un frontend aparte.

Cada servicio vive en **su propio repositorio**, por lo que hay que clonarlos todos dentro de una misma carpeta contenedora.

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
└── OffBeat-Frontend/             
```

## Requisitos

- [Docker](https://www.docker.com/) y Docker Compose v2
- [Node.js](https://nodejs.org/) (LTS) y npm, para el frontend
- Puertos libres: `3307`, `8081`, `8082`, `8083`, `8084` (y el del frontend)

## 1. Clonar los repositorios

```bash
git clone <url-repo-OffBeat_Contenedor>

git clone <url-repo-usuarios>  
git clone <url-repo-productos> 
git clone <url-repo-blogs>     
git clone <url-repo-compras>   
git clone <url-repo-frontend>  
```
Asegúrate que todo esté en la misma carpeta `OffBeat_Contenedor`.

## 2. Configurar variables de entorno

Creá un archivo `.env` si es que no esta en el repositorio `OffBeat_Contenedor`:

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

## 3. Levantar los servicios backend (Docker Compose)

Desde la carpeta contenedora:

```bash
docker compose up -d --build
```

Esto levanta MySQL y los cuatro servicios. MySQL arranca primero y los demás esperan a que esté saludable (healthcheck).

| Servicio  | Contenedor                 | Puerto | Base de datos       |
|-----------|----------------------------|--------|---------------------|
| MySQL     | `offbeat-mysql`            | 3307   | —                   |
| Usuarios  | `OffBeat-Backend-Usuarios` | 8082   | `offbeat_usuarios`  |
| Productos | `OffBeat-Backend-Productos`| 8081   | `offbeat_productos` |
| Blogs     | `OffBeat-Backend-Blogs`    | 8084   | `offbeat_blogs`     |
| Compras   | `OffBeat-Backend-Compras`  | 8083   | `offbeat_compras`   |

MySQL se expone en el puerto **3307** del host (internamente es 3306) para no chocar con un MySQL local.

### Comandos útiles

```bash
docker compose ps                  # ver estado de los contenedores
docker compose logs -f             # ver logs de todos los servicios
docker compose logs -f usuarios    # logs de un servicio puntual
docker compose down                # detener y eliminar contenedores
docker compose down -v             # además borra volúmenes (¡borra la base de datos!)
docker compose up -d --build usuarios   # reconstruir un solo servicio
docker compose stop # apagar los contenedores
```

## 4. Levantar el frontend

En otra terminal:

```bash
cd OffBeat-Frontend
npm install
npm run dev
```

Por defecto se abre en la URL que indique la consola (`http://localhost:5173`).

Asegurate de que el frontend apunte a las APIs del backend:

- Usuarios: `http://localhost:8082`
- Productos: `http://localhost:8081`
- Compras: `http://localhost:8083`
- Blogs: `http://localhost:8084`

## Solución de problemas

- **Un servicio no arranca / `build` falla:** revisá que la carpeta del repo exista con el nombre exacto y que esté al lado del `docker-compose.yml`.
- **Error de conexión a la base de datos:** esperá a que MySQL esté `healthy` (`docker compose ps`) y verificá que las credenciales del `.env` sean correctas.
- **Cambiaste las credenciales de MySQL y no funcionan:** el volumen `mysql_data` conserva las credenciales originales. Ejecutá `docker compose down -v` y volvé a levantar (esto borra los datos).
- **Puerto ocupado:** cambiá el puerto del lado izquierdo en el mapeo `ports` del `docker-compose.yml` (por ejemplo `"3308:3306"`).
