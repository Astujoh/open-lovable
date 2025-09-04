# Usa una imagen base optimizada para Node.js
FROM node:18-alpine AS base

# -----------------
# Fase 1: Build
# -----------------
FROM base AS build

WORKDIR /app

# Copia los archivos de configuración y dependencias
COPY package*.json ./

# Instala las dependencias, incluyendo las de desarrollo
RUN npm install

# Copia el resto del código
COPY . .

# Genera la versión de producción de la aplicación
RUN npm run build

# -----------------
# Fase 2: Producción
# -----------------
FROM base AS production

WORKDIR /app

# Copia solo los archivos necesarios para la producción desde la fase de "build"
COPY --from=build /app/.next ./.next
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json

# Establece el puerto por defecto
EXPOSE 3000

# Comando para iniciar el servidor de producción
CMD ["npm", "run", "start"]
