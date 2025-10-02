# Imagen de desarrollo para arquitectura ARM
FROM maven:3.8-eclipse-temurin-21 AS build

# Establecer el directorio de trabajo
WORKDIR /app 

# Copia los archivos necesarios
COPY pom.xml .
COPY src ./src

# Descargar dependencias y compilar
RUN mvn clean package -DskipTests

# Imagen de produccion para arquitectura ARM
FROM --platform=linux/arm64 eclipse-temurin:21-jdk-alpine

# Establecer el directorio de trabajo
WORKDIR /app

# Instalar curl para healthcheck
RUN apk add --no-cache curl

# Copiar el JAR compilado
COPY --from=build /app/target/notes-api-*.jar app.jar

# Crear usuario no-root
RUN addgroup -g 1001 -S spring && \
    adduser -S spring -u 1001

# Cambiar al usuario no-root
USER spring:spring

# Exponer el puerto
EXPOSE 8080

# Comando de arranque
ENTRYPOINT ["java", "-jar", "/app/app.jar"]