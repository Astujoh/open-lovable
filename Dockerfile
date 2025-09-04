FROM node:18-slim AS base

# Instalar solo dependencias esenciales
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

FROM base AS production
WORKDIR /app

# Copia package*.json
COPY package*.json ./

# Instala dependencias (solo producción para ahorrar espacio)
RUN npm install --only=production && npm cache clean --force

# Copia código fuente
COPY . .

# Build de la aplicación
RUN npm run build

# Crear usuario no-root
RUN groupadd --gid 1001 nodejs && \
    useradd --uid 1001 --gid nodejs nextjs

# Cambiar ownership solo de archivos necesarios
RUN chown -R nextjs:nodejs .next

USER nextjs

EXPOSE 3000

CMD ["npm", "run", "start"]
