# ─────────────────────────────────────────────
# ETAPA: dev
# Usada en desarrollo local con Docker Compose.
# Monta el código fuente desde el host vía volumen
# y ejecuta el servidor con recarga automática.
# ─────────────────────────────────────────────
FROM node:19-alpine3.15 as dev
WORKDIR /app
COPY package.json ./
RUN yarn install
CMD [ "yarn","start:dev" ]

# ─────────────────────────────────────────────
# ETAPA: dev-deps
# Instala TODAS las dependencias (dev + prod)
# con versiones exactas del lockfile.
# Usada como base por la etapa "builder".
# ─────────────────────────────────────────────
FROM node:19-alpine3.15 as dev-deps
WORKDIR /app
COPY package.json package.json
RUN yarn install --frozen-lockfile

# ─────────────────────────────────────────────
# ETAPA: builder
# Compila TypeScript a JavaScript (dist/).
# Copia node_modules de dev-deps para no
# repetir la instalación.
# ─────────────────────────────────────────────
FROM node:19-alpine3.15 as builder
WORKDIR /app
COPY --from=dev-deps /app/node_modules ./node_modules
COPY . .
# RUN yarn test
RUN yarn build

# ─────────────────────────────────────────────
# ETAPA: prod-deps
# Instala SOLO dependencias de producción
# (sin devDependencies) para una imagen ligera.
# ─────────────────────────────────────────────
FROM node:19-alpine3.15 as prod-deps
WORKDIR /app
COPY package.json package.json
RUN yarn install --prod --frozen-lockfile

# ─────────────────────────────────────────────
# ETAPA: prod
# Imagen final de producción.
# Solo contiene node_modules de prod y el dist.
# ─────────────────────────────────────────────
FROM node:19-alpine3.15 as prod
EXPOSE 3000
WORKDIR /app
ENV APP_VERSION=${APP_VERSION}
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

CMD [ "node","dist/main.js"]