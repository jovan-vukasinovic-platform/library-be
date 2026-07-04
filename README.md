# library-be — Library API

Spring Boot 3 (Java 17) REST API za upravljanje knjigama. PostgreSQL + Flyway migracije.

## REST endpoints

| Metoda | Putanja          | Opis                  |
|--------|------------------|-----------------------|
| GET    | /api/books       | Lista svih knjiga     |
| GET    | /api/books/{id}  | Jedna knjiga          |
| POST   | /api/books       | Kreiranje (201)       |
| PUT    | /api/books/{id}  | Izmena                |
| DELETE | /api/books/{id}  | Brisanje (204)        |
| GET    | /actuator/health | Health check (K8s probes: /actuator/health/liveness i /readiness) |

## Environment varijable

| Varijabla       | Default                | Opis                                   |
|-----------------|------------------------|----------------------------------------|
| DB_HOST         | library-db             | RDS endpoint (samo hostname, bez porta)|
| DB_PORT         | 5432                   | Port baze                              |
| DB_NAME         | library                | Naziv baze                             |
| DB_USERNAME     | postgres               | DB korisnik                            |
| DB_PASSWORD     | localdev               | DB šifra (u klasteru K8s Secret)       |
| ALLOWED_ORIGINS | http://library-fe:4200 | CORS origins (zarez-separisano)        |

## Lokalno pokretanje

```bash
# 0. Kreiranje mreže platform-network
docker network create platform-network

# 1. Lokalni PostgreSQL (ili koristi RDS endpoint direktno)
docker run -d --name library-db --network platform-network -p 5432:5432 -e POSTGRES_DB=library -e POSTGRES_PASSWORD=localdev postgres:16-alpine

# 2. Pokreni aplikaciju lokalno ili kao Docker kontejner
mvn spring-boot:run
docker run -d --name library-be --network platform-network -p 8080:8080 ${{ secrets.DOCKERHUB_USERNAME }}/jovan-vukasinovic-platform:library-be-latest

# 3. Test iz Postmana ka Docker Desktopu
curl http://host.docker.internal:8080/api/books
curl -X POST http://host.docker.internal:8080/api/books \
  -H "Content-Type: application/json" \
  -d '{"title":"Na Drini cuprija","author":"Ivo Andric","publishedYear":1945,"status":"DOSTUPNO"}'
```

Flyway automatski kreira tabelu `books` pri prvom startu — nije potrebna ručna SQL skripta.
Napomena: baza `library` mora postojati na RDS-u (Flyway kreira tabele, ne bazu).

## Testovi

```bash
mvn test
```