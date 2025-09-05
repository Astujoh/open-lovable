# ---------- deps ----------
FROM node:20-alpine AS deps
WORKDIR /app
ENV NPM_CONFIG_UPDATE_NOTIFIER=false
COPY package.json package-lock.json ./
RUN npm ci

# ---------- builder ----------
FROM node:20-alpine AS builder
WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED=1
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# ---------- runner ----------
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
# usuario no-root
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
# copiar artefactos
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY package.json ./
COPY --from=deps /app/node_modules ./node_modules
USER nextjs
EXPOSE 3000
# "next start" está en los scripts del proyecto típico Next.js
CMD ["npm", "run", "start", "--", "-p", "3000"]
