# Cambiar de Alpine a Debian slim para mejor compatibilidad con LightningCSS
FROM node:18-slim AS base

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Instalar pnpm globalmente
RUN npm install -g pnpm

# -----------------
# Fase de producción
# -----------------
FROM base AS production
WORKDIR /app

# Crear usuario no-root para seguridad
RUN groupadd --gid 1001 nodejs && \
    useradd --uid 1001 --gid nodejs --shell /bin/bash --create-home nextjs

# Copia los archivos de configuración y dependencias
COPY package*.json ./

# Instala todas las dependencias incluyendo TypeScript
RUN npm install

# Instalar TypeScript globalmente como respaldo
RUN npm install -g typescript

# Copia el resto del código
COPY . .

# IMPORTANTE: Reinstalar LightningCSS para generar el binario nativo correcto
RUN npm rebuild lightningcss

# Verificar que el binario existe (para debug)
RUN ls -la /app/node_modules/lightningcss/ || true
RUN ls -la /app/node_modules/lightningcss/lightningcss.linux-x64-gnu.node || echo "Binario no encontrado"

# Limpiar cache
RUN npm cache clean --force

# Cambiar ownership de los archivos
RUN chown -R nextjs:nodejs /app

# Cambiar al usuario no-root
USER nextjs

# Establece el puerto por defecto
EXPOSE 3000

# Usar npm para ejecutar scripts
CMD ["npm", "run", "start"]
