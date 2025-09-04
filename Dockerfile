# Usa una imagen base optimizada para Node.js
FROM node:18-alpine AS base

# Instalar dependencias necesarias para LightningCSS y pnpm
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    libc6-compat \
    libstdc++ \
    linux-headers

# Instalar pnpm globalmente
RUN npm install -g pnpm

# -----------------
# Fase de producción
# -----------------
FROM base AS production
WORKDIR /app

# Crear usuario no-root para seguridad
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copia los archivos de configuración y dependencias
COPY package*.json ./

# Instala las dependencias
RUN npm install --omit=dev && npm cache clean --force

# Copia el resto del código
COPY . .

# Cambiar ownership de los archivos
RUN chown -R nextjs:nodejs /app

# Cambiar al usuario no-root
USER nextjs

# Establece el puerto por defecto
EXPOSE 3000

# El comando start ya incluye build y start
CMD ["npm", "run", "start"]
