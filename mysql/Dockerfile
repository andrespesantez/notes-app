# Imagen base
FROM mysql:8.0

# Copia el archivo de inicialización
COPY init.sql /docker-entrypoint-initdb.d/

# Expose the MySQL port
EXPOSE 3306
