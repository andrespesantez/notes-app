# Etapa 1: Instalación de dependencias
FROM node:18-alpine AS deps

# Directorio de trabajo
WORKDIR /app

# Instalar dependencias
COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile

# Etapa 2: Construcción
FROM node:18-alpine AS builder

# Directorio de trabajo
WORKDIR /app

# Copiar dependencias
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Compila el código
RUN yarn build

# Etapa 3: Producción
FROM node:18-alpine AS runner
# Directorio de trabajo
WORKDIR /app
# Definir variables de entorno
ENV NODE_ENV=production

# Crear usuario y grupo no-root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copiar la salida standalone
COPY --from=builder /app/.next/standalone ./
# Copiar los assets públicos
COPY --from=builder /app/public ./public
# Copiar los assets estáticos
COPY --from=builder /app/.next/static ./.next/static

# Cambiar el propietario de los archivos
RUN chown -R nextjs:nodejs .

# Usar el usuario no-root
USER nextjs
# Exponer el puerto
EXPOSE 3000

ENV PORT=3000

# El server.js se encuentra en la raíz del standalone output
CMD ["node", "server.js"]
