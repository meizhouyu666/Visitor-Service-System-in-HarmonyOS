# API Compatibility Diff (Current -> Target)

## Compatibility Policy
- Existing APIs remain available during upgrade (no forced frontend break).
- New capabilities are introduced as additive endpoints first.
- Internal refactor may happen behind compatibility adapters.

## A. Keep-As-Is APIs (Retained)
| API | Current Status | Keep Policy |
|---|---|---|
| `POST /api/auth/login` | Implemented | Keep unchanged |
| `GET /api/auth/me` | Implemented | Keep unchanged |
| `GET /api/complaints` | Implemented | Keep path; additive query params only |
| `POST /api/complaints` | Implemented | Keep unchanged |
| `GET /api/complaints/{id}` | Implemented | Keep unchanged |
| `POST /api/complaints/{id}/rating` | Implemented | Keep unchanged |
| `POST /api/complaints/admin/{id}/approve` | Implemented | Keep unchanged |
| `POST /api/complaints/admin/{id}/process` | Implemented | Keep unchanged |
| `POST /api/complaints/admin/{id}/close` | Implemented | Keep unchanged |
| `GET /api/emergency` | Implemented | Keep path; tighten active-window logic |
| `GET /api/emergency/admin` | Implemented | Keep unchanged |
| `POST /api/emergency/admin` | Implemented | Keep unchanged |
| `PUT /api/emergency/admin/{id}` | Implemented | Keep unchanged |
| `DELETE /api/emergency/admin/{id}` | Implemented | Keep unchanged |
| `POST /api/emergency/admin/{id}/submit` | Implemented | Keep unchanged |
| `POST /api/emergency/admin/{id}/approve` | Implemented | Keep unchanged |
| `GET /api/query/*` current paths | Implemented | Keep current route contracts |

## B. Additive APIs (Planned)
| New API | Purpose | Frontend Impact | Compatibility Note |
|---|---|---|---|
| `POST /api/auth/register` | User registration | Optional new page entry | No impact on existing login flow |
| `POST /api/auth/forgot-password/request-code` | Request verification code | New flow only | Additive |
| `POST /api/auth/forgot-password/reset` | Reset password with code | New flow only | Additive |
| `DELETE /api/admin/users/{id}` | Admin user deletion | Admin page only | Additive |
| `POST /api/complaints/admin/{id}/reject` | Reject complaint | Admin/approver page action | Additive |
| `POST /api/complaints/admin/{id}/assign` | Assign complaint handler | Admin page action | Additive |
| `GET /api/complaints/{id}/timeline` | Complaint process trace | Complaint detail enhancement | Additive |
| `GET /api/complaints/export` | Complaint export | Admin utility | Additive |

## C. Compatibility Window Rules
- Deprecated APIs (if any) must be marked in docs before removal.
- Any removal requires:
  1. one release cycle with compatibility adapter,
  2. README version-note warning,
  3. migration guide with concrete replacement calls.

## D. Frontend Change Requirement
- Goal: "no forced frontend update for already working flows."
- Existing pages should continue to work without endpoint remap.
- New frontend features can consume only new additive APIs.
