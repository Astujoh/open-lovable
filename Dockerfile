# Etapa 1: dependencias
FROM node:20-alpine AS deps
WORKDIR /app

# Copiar package.json
COPY package.json ./

# Instalar dependencias (sin devDependencies)
RUN npm install --omit=dev

# Etapa 2: build
FROM node:20-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# Etapa 3: runtime
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000
CMD ["npm", "start"]
