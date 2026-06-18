# ---------- Build stage ----------
# https://hub.docker.com/layers/library/maven/3.9-eclipse-temurin-17/images/sha256-9f43af45b81b1505b907768c55da4e3df34064267c89354d0707c827e79de949
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app/

# Instaliranje prvo zavisnosti (bolji layer caching)
COPY pom.xml /app/
RUN mvn -B dependency:go-offline
# Kopiranje ostatka koda i pravljenje JAR-a (testovi se vrte u CI-ju)
COPY ./src /app/src
RUN mvn -B clean package -DskipTests

# ---------- Runtime stage ----------
# https://hub.docker.com/layers/library/eclipse-temurin/17.0.13_11-jre-alpine/images/sha256-1dbece501e138146372e2a0b3f5d7545df8415b2caab1e9ef77e0f66e2aabe57
FROM eclipse-temurin:17.0.13_11-jre-alpine AS runtime
WORKDIR /app/

# Pokretanje kao non-root korisnik (security best practice)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Spring Boot Maven plugin pravi izvrsni JAR u target/
COPY --from=build /app/target/library-be-*.jar /app/library-be.jar
EXPOSE 8080

# ---------- Docker Commands ----------
# docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/jovan-vukasinovic-platform:library-be-latest -f Dockerfile .
# docker push ${{ secrets.DOCKERHUB_USERNAME }}/jovan-vukasinovic-platform:library-be-latest
# docker run -d --name library-be --network platform-network -p 8080:8080 ${{ secrets.DOCKERHUB_USERNAME }}/jovan-vukasinovic-platform:library-be-latest
