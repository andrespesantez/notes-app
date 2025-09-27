FROM nginx:alpine

# Copiar configuración personalizada
COPY nginx.conf /etc/nginx/nginx.conf

# Crear directorios para logs
RUN mkdir -p /var/log/nginx

# Crear usuario no-root
RUN addgroup -g 1001 -S nginx && \
    adduser -S nginx -u 1001

# Ajustar permisos
RUN chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d

# Cambiar el puerto por defecto para usuario no-root
RUN sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]