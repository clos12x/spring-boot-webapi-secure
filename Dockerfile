# ==============================
# Build stage
# ==============================
FROM maven:3.9.11-eclipse-temurin-21 AS builder

WORKDIR /app

# Copiar primero el pom para aprovechar cache
COPY pom.xml .

# Descargar dependencias
RUN mvn -B dependency:go-offline

# Copiar código fuente
COPY src ./src

# Compilar aplicación
RUN mvn -B clean package -DskipTests


# ==============================
# Runtime stage
# ==============================
FROM eclipse-temurin:21-jre

WORKDIR /app

# Crear usuario no root
RUN groupadd --system spring && \
    useradd --system --gid spring spring

# Copiar únicamente el jar generado
COPY --from=builder /app/target/*.jar app.jar

# Cambiar propietario
RUN chown spring:spring /app/app.jar

USER spring:spring

EXPOSE 8080

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]