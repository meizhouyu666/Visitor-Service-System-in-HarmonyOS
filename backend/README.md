# Tourist Service Backend

Spring Boot backend for the Visitor Service System.

## Stack

- Java 17
- Spring Boot 3
- Spring Security + JWT
- Spring Data JPA
- Flyway
- MySQL
- OpenAPI (Swagger UI)

## Quick Start

1. Start database:
   - `docker compose up -d` (inside `backend/`)
2. Run app:
   - `mvn spring-boot:run`
3. Open Swagger:
   - `http://localhost:8080/swagger-ui.html`

## Default Accounts

- Visitor:
  - username: `visitor`
  - password: `visitor123`
- Admin:
  - username: `admin`
  - password: `admin123`

## Auth Header

- `Authorization: Bearer <token>`
