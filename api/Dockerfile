# =========================
# STAGE 1 — BUILD STAGE
# =========================
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom first for dependency caching
COPY pom.xml .

RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build application
RUN mvn clean package -DskipTests


# =========================
# STAGE 2 — RUNTIME STAGE
# =========================
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -S spring && adduser -S spring -G spring

# Copy built jar from builder stage
COPY --from=builder /app/target/*.jar application.jar

# Change ownership
RUN chown spring:spring application.jar

USER spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "application.jar"]
