FROM maven:3.8.4-openjdk-17 AS build

WORKDIR /app
COPY pom.xml .
COPY src ./src

# Descargar dependencias y compilar
RUN mvn clean package -DskipTests

# Imagen de producción
FROM openjdk:17-jdk-alpine

WORKDIR /app

# Instalar curl para healthcheck
RUN apk add --no-cache curl

# Copiar el JAR compilado
COPY --from=build /app/target/notes-api-*.jar app.jar

# Crear usuario no-root
RUN addgroup -g 1001 -S spring && \
    adduser -S spring -u 1001

USER spring:spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]