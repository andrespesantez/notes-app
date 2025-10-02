# Etapa de dependencias
FROM node:18-alpine AS deps

# Directorio de trabajo
WORKDIR /app

# Instalar dependencias
COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile

# Etapa de construcción
FROM node:18-alpine AS builder

# Directorio de trabajo
WORKDIR /app

# Copiar dependencias
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Compila el código
RUN yarn build

# Etapa de producción
FROM node:18-alpine AS runner
# Directorio de trabajo
WORKDIR /app
# Definir variables de entorno
ENV NODE_ENV=production

# Copiar archivos necesarios
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Exponer el puerto
EXPOSE 3000

# Comando de inicio
CMD ["yarn", "start"]