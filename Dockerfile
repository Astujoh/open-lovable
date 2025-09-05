# Etapa 1: dependencias
FROM node:20-alpine AS deps
WORKDIR /app

# Copiar solo package.json
COPY package.json ./

# Instalar dependencias (sin devDependencies)
RUN npm install --omit=dev

# Etapa 2: build
FROM node:20-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Importante: solo compila, no mete variables sensibles
RUN npm run build

# Etapa 3: runtime
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Copiar lo necesario
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

# Dejar que EasyPanel inyecte las variables al contenedor
# (ejemplo: API_KEY, DATABASE_URL, NEXTAUTH_SECRET, etc.)

EXPOSE 3000
CMD ["npm", "start"]
