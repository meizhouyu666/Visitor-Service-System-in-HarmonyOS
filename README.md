# Visitor Service System in HarmonyOS

Monorepo for the Visitor Service System course project.

## Repository Structure

- `backend/`: Spring Boot + MySQL + JWT + OpenAPI
- `frontend/harmony-app/`: HarmonyOS ArkTS skeleton (Stage Model)
- `docs/`: minimal API contract references

## Quick Start

1. Clone the repository.
2. Create your own feature branch.
3. Implement your module and push branch.
4. Open a Pull Request to `main`.

## Branching Convention

- Feature branch: `feature/<module>-<task>`
- Fix branch: `fix/<module>-<issue>`

## Backend Start

```bash
cd backend
docker compose up -d
mvn spring-boot:run
```

Swagger UI:

- `http://localhost:8080/swagger-ui.html`

## Frontend Notes

- Open `frontend/harmony-app` in DevEco Studio.
- Default login demo:
  - visitor / visitor123
  - admin / admin123
