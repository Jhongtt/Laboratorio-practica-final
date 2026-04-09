# ─────────────────────────────────────────────
# ETAPA 1: build
# Usa Node para compilar la aplicación Angular.
# Resultado: archivos estáticos en dist/.
# ─────────────────────────────────────────────
FROM node:20-alpine as build

WORKDIR /app

# Copiar solo los archivos de dependencias primero.
# Esto aprovecha el caché de Docker: si package.json
# no cambia, Docker reutiliza la capa de npm ci.
COPY package*.json ./

# npm ci es más estricto que npm install:
# usa exactamente las versiones del package-lock.json.
RUN npm ci

# Copiar el resto del código fuente.
COPY . .

# Compilar Angular para producción.
# El output queda en dist/teslo-shop/browser/
RUN npm run build


# ─────────────────────────────────────────────
# ETAPA 2: runtime
# Imagen final: solo Nginx + archivos estáticos.
# Node no está incluido → imagen mucho más pequeña.
# ─────────────────────────────────────────────
FROM nginx:alpine

# Copiar los archivos del build al directorio
# que Nginx sirve por defecto.
COPY --from=build /app/dist/teslo-shop/browser /usr/share/nginx/html

# Reemplazar la configuración por defecto de Nginx
# con la nuestra (proxy al backend, SPA routing, etc.).
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]