# tesloshop-app
# Laboratorio — Contenerización de TesloShop con Docker y Docker Compose
 
**Estudiante:** Jhonatan David  
**Programa:** SENA  
**Proyecto:** TesloShop — Angular 19 + NestJS + PostgreSQL  
 
---
 
## ¿Qué hice en este laboratorio?
 
El objetivo fue contenerizar una aplicación completa (base de datos + backend + frontend) usando Docker y Docker Compose. A continuación describo cada paso que realicé.
 
---
 
## Paso 1 — Dockerfile del backend (NestJS)
 
**Archivo:** `teslo-shop/Dockerfile`
 
Creé un Dockerfile con **multi-stage builds** (múltiples etapas en un solo archivo). Esto permite usar el mismo archivo tanto para desarrollo como para producción.
 
Las 5 etapas que configuré son:
 
- **dev** — usada en desarrollo local. Instala dependencias y arranca el servidor con hot-reload (`yarn start:dev`). El código fuente se monta desde el computador como volumen, lo que permite ver cambios al instante al guardar en VS Code.
- **dev-deps** — instala todas las dependencias con versiones exactas del lockfile (`--frozen-lockfile`). La usa la etapa siguiente como base.
- **builder** — compila el código TypeScript a JavaScript (carpeta `dist/`). Reutiliza los node_modules de la etapa anterior para no repetir la instalación.
- **prod-deps** — instala solo las dependencias de producción, sin las de desarrollo. Reduce el tamaño de la imagen final.
- **prod** — imagen final para producción. Solo contiene el código compilado (`dist/`) y las dependencias mínimas. Es mucho más pequeña y segura que la imagen de desarrollo.
 
**¿Por qué multi-stage?** Porque la imagen de producción no necesita TypeScript, herramientas de compilación ni código fuente. Solo necesita el resultado compilado. Esto reduce el tamaño de la imagen de ~800 MB a ~150 MB.
 
---
 
## Paso 2 — Dockerfile del frontend (Angular + Nginx)
 
**Archivo:** `angular-tesloshop/Dockerfile`
 
Creé un Dockerfile con 2 etapas:
 
- **build** — usa Node 20 para instalar dependencias (`npm ci`) y compilar la aplicación Angular. El resultado son archivos estáticos HTML, CSS y JS en la carpeta `dist/`.
- **runtime** — usa Nginx (servidor web ligero) para servir los archivos compilados. Node no está incluido en esta imagen final, lo que la hace mucho más pequeña.
 
La clave es copiar primero `package.json` antes del código fuente. Esto aprovecha el caché de Docker: si el código cambia pero las dependencias no, Docker reutiliza la capa de `npm ci` y la construcción es más rápida.
 
---
 
## Paso 3 — Configuración de Nginx
 
**Archivo:** `angular-tesloshop/nginx.conf`
 
Configuré Nginx con tres bloques principales:
 
- **SPA Routing** — cuando el usuario navega a una ruta como `/productos/123`, el archivo físico no existe en el servidor. Nginx intenta encontrarlo y si no existe sirve `index.html` para que Angular maneje la ruta internamente.
- **Caché de estáticos** — los archivos JS, CSS e imágenes se cachean 1 año en el navegador porque Angular les añade un hash único en cada build.
- **Proxy hacia la API** — las peticiones a `/api/*` y `/socket.io` se redirigen al contenedor `backend:3000`. Esto resuelve el problema de CORS: el navegador cree que todo viene del mismo origen.
 
---
 
## Paso 4 — Variables de entorno (.env)
 
**Archivo:** `.env` en la raíz del proyecto
 
Creé el archivo `.env` con todas las variables necesarias para los tres servicios. Las reglas más importantes que aprendí:
 
- `DB_HOST` debe ser `db` (el nombre del servicio en Compose), nunca `localhost`.
- `DB_PASSWORD` debe ser idéntica a `POSTGRES_PASSWORD`.
- `STAGE=dev` activa la etapa de desarrollo en el Dockerfile del backend.
- El archivo `.env` nunca debe subirse al repositorio porque contiene contraseñas.
 
---
 
## Paso 5 — docker-compose.yml
 
**Archivo:** `docker-compose.yml` en la raíz del proyecto
 
Definí los tres servicios que componen la aplicación:
 
- **db** — contenedor PostgreSQL 14.3. Tiene un healthcheck con `pg_isready` que verifica cada 10 segundos si la base de datos está lista para aceptar conexiones.
- **backend** — contenedor NestJS. Espera a que `db` esté `healthy` antes de arrancar (`depends_on: condition: service_healthy`). Monta el código fuente como volumen para el hot-reload.
- **frontend** — contenedor Nginx con Angular compilado. Arranca después del backend.
 
También configuré una red interna `teslo-network` que conecta los tres servicios, y un volumen `postgres-data` para que los datos de la base de datos persistan aunque se reinicien los contenedores.
 
---
 
## Paso 6 — Scripts de arranque y parada
 
**Archivos:** `start.sh` y `stop.sh` en la raíz del proyecto
 
Creé dos scripts para automatizar los comandos más comunes:
 
- `start.sh` — verifica que Docker esté corriendo, construye las imágenes y levanta los contenedores en segundo plano.
- `stop.sh` — detiene y elimina los contenedores. Los datos de la base de datos se conservan en el volumen.
 
---
 
## Paso 7 — Ejecutar la aplicación
 
Con todo configurado, ejecuté:
 
```bash
docker compose up --build -d
```
 
La primera vez tardó varios minutos porque Docker descargó las imágenes base de Node, PostgreSQL y Nginx, y compiló el frontend de Angular.
 
Para poblar la base de datos con datos de prueba, ejecuté el endpoint seed:
 
```
http://localhost:3000/api/seed
```
 
### URLs de acceso
 
| Servicio | URL |
|---|---|
| Frontend (Angular) | http://localhost |
| Backend API (NestJS) | http://localhost:3000/api |
| Documentación Swagger | http://localhost:3000/api/docs |
 
---
 
## Estructura final del proyecto
 
```
tesloshop-app/
├── docker-compose.yml
├── .env
├── start.sh
├── stop.sh
├── teslo-shop/
│   ├── Dockerfile
│   ├── package.json
│   └── src/
└── angular-tesloshop/
    ├── Dockerfile
    ├── nginx.conf
    └── src/
```
 
---
 
## Lo que aprendí
 
- Qué es una imagen Docker y un contenedor, y la diferencia entre los dos.
- Cómo funcionan los multi-stage builds y por qué reducen el tamaño de las imágenes.
- Qué hace el hot-reload y por qué el código vive en el computador y no dentro del contenedor.
- Cómo se comunican los servicios dentro de Docker usando nombres de servicio en lugar de localhost.
- Por qué el proxy de Nginx resuelve el problema de CORS.
- La diferencia entre un proyecto de práctica y un proyecto real en producción.
 