# Etapa 1: dependencias
FROM node:20-alpine AS deps
WORKDIR /app

# Copiar manifestos de dependencias
COPY package.json package-lock.json ./

# Configuración para evitar errores con lockfile / peer deps
ENV NPM_CONFIG_LEGACY_PEER_DEPS=true
ENV NPM_CONFIG_FORCE=true

# Instalar dependencias
RUN npm install

# Etapa 2: build
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Generar build de producción
RUN npm run build

# Etapa 3: runtime
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Copiar archivos necesarios
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["npm", "start"]
