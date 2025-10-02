# Imagen de desarrollo para arquitectura ARM
FROM maven:3.8-eclipse-temurin-21 AS build

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar solo el pom.xml para cachear las dependencias
COPY pom.xml .

# Descargar las dependencias
RUN mvn dependency:go-offline

# Copiar el resto del código fuente
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

# Crear un grupo y usuario no-root para ejecutar
RUN addgroup -S spring && adduser -S spring -G spring

# Cambiar al usuario no-root
USER spring:spring

# Exponer el puerto en el que corre
EXPOSE 8080

# Comando para ejecutar
ENTRYPOINT ["java","-jar","/app/app.jar"]
