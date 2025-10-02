# Imagen base
FROM nginx:alpine

# Copiar configuración personalizada
COPY nginx.conf /etc/nginx/nginx.conf

# Crear directorios para logs
RUN mkdir -p /var/log/nginx

# El usuario no-root 'nginx' ya existe en la imagen base

# Ajustar permisos
RUN chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d

# El puerto de escucha se configura en nginx.conf
EXPOSE 80 443

# Comando para iniciar Nginx
CMD ["nginx", "-g", "daemon off;"]