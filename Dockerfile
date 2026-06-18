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
# Alpine 3.23 je imao 3x HIGH (libcrypto3/libssl3/openssl) -> presli smo na UBI10-minimal (0 ranjivosti)
# Before: https://hub.docker.com/layers/library/eclipse-temurin/17.0.19_10-jre-alpine-3.23/images/sha256-268ed4534cb05c6ebbec22c750c2435183692d399757bf78e103e980ec5208ae
# After: https://hub.docker.com/layers/library/eclipse-temurin/17.0.19_10-jre-ubi10-minimal/images/sha256-6aa4e8f84d5e5ed9547d3d506c3260adf82429cadf8856f521b98c77b4676fc3
FROM eclipse-temurin:17.0.19_10-jre-ubi10-minimal AS runtime
WORKDIR /app/

# Spring Boot Maven plugin pravi izvrsni JAR u target/
COPY --from=build /app/target/library-be-*.jar /app/library-be.jar

# Novi UBI image koji nije Alpine (nema busybox addgroup/adduser)
# Koristi se numericki UID za non-root korisnike (OpenShift-friendly)
USER 1001
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/library-be.jar"]

# ---------- Docker Commands ----------
# docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/jovan-vukasinovic-platform:library-be-latest -f Dockerfile .
# docker push ${{ secrets.DOCKERHUB_USERNAME }}/jovan-vukasinovic-platform:library-be-latest
# docker run -d --name library-be --network platform-network -p 8080:8080 ${{ secrets.DOCKERHUB_USERNAME }}/jovan-vukasinovic-platform:library-be-latest
