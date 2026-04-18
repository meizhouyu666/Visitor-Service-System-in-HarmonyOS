# Requirements-Code Traceability Matrix (VSS)

## Scope and Baseline
- Requirement sources:
  - `0鸿蒙系统游客服务AP2调研报告.docx`
  - `6.游客服务系统.docx`
  - `2.软件需求规约.docx` (tourist-service body only)
- Conflict rule:
  - SRS catalog entries like "实验室管理/仿真设备管理/课程管理" are treated as template leftovers.
  - Status for those entries is `文档冲突待确认`.

## Status Definitions
- `已实现`: behavior exists in current backend + frontend flow.
- `部分实现`: core behavior exists, but key sub-capabilities are missing.
- `未实现`: no usable implementation in current repository.
- `文档冲突待确认`: requirement statement conflicts with confirmed project scope.

## Matrix
| Req ID | Requirement | Code Evidence | Status | Gap Summary | Priority |
|---|---|---|---|---|---|
| R-AUTH-01 | Login + role-based access | `backend/src/main/java/com/visitor/service/auth/AuthController.java`, `backend/src/main/java/com/visitor/service/config/SecurityConfig.java`, `frontend/harmony-app/entry/src/main/ets/pages/Index.ets` | 已实现 | None for base login | P0 |
| R-AUTH-02 | Register account | No register endpoint/page | 未实现 | Need register API + validation + UI | P1 |
| R-AUTH-03 | Forgot password with verification code | No reset-code APIs/page | 未实现 | Need request-code + reset flow | P1 |
| R-AUTH-04 | Admin delete user | No user-management controller | 未实现 | Need admin user management API | P1 |
| R-COMP-01 | Visitor submit complaint (text + attachments) | `ComplaintController#create`, `ComplaintService#create`, `ComplaintPage.submitComplaint()` | 已实现 | Attachment currently URL string only | P0 |
| R-COMP-02 | Visitor list/detail complaint and progress | `ComplaintController#list/detail`, `ComplaintPage.ListPanel()` | 部分实现 | No full timeline/history model | P0 |
| R-COMP-03 | Complaint approval | `ComplaintController#approve`, `ComplaintService#approve` | 已实现 | Workflow granularity can be improved | P0 |
| R-COMP-04 | Complaint processing by handler | `ComplaintController#process`, `ComplaintService#process` | 已实现 | Missing structured process records | P0 |
| R-COMP-05 | Complaint closure | `ComplaintController#close`, `ComplaintService#close` | 已实现 | No close checklist/audit fields | P0 |
| R-COMP-06 | Visitor rating after closure | `ComplaintController#rate`, `ComplaintService#rate` | 已实现 | No rating text/comment field | P1 |
| R-COMP-07 | Complaint reject action | No reject endpoint/status | 未实现 | Add REJECTED status + action | P0 |
| R-COMP-08 | Complaint assignment action | No explicit assign API | 未实现 | Add assign endpoint + assignee field | P0 |
| R-COMP-09 | Complaint process trace/replies | No timeline/reply entity or API | 未实现 | Add complaint timeline table + APIs | P0 |
| R-COMP-10 | Multi-condition complaint query | `list` supports role scope only | 未实现 | Add filter params (id/type/status/time/handler) | P1 |
| R-COMP-11 | Complaint export (Excel/CSV) | No export API | 未实现 | Add export endpoint + format | P2 |
| R-EMER-01 | Emergency draft-create/update/delete | `EmergencyController#create/update/delete`, `EmergencyService` | 已实现 | Base lifecycle exists | P0 |
| R-EMER-02 | Submit for approval + approve publish | `EmergencyController#submit/approve`, `EmergencyService` | 已实现 | Base approval chain exists | P0 |
| R-EMER-03 | Visitor view published emergency info | `EmergencyController#listPublished`, `EmergencyPage` | 已实现 | Need explicit validity-window filtering | P0 |
| R-EMER-04 | Push scope/real-time delivery | No push service abstraction or channel config | 未实现 | Add push strategy (optional phase) | P2 |
| R-HOTEL-01 | Visitor hotel search/detail | `/api/query/hotels`, `HotelPage` | 部分实现 | Data is in-memory sample, no persistent source | P1 |
| R-HOTEL-02 | Hotel room-state management | No CRUD endpoints for room-state | 未实现 | Add admin/hotel-manager data model + APIs | P1 |
| R-HOTEL-03 | Hotel marketing recommendation management | No management APIs/UI | 未实现 | Add recommendation config endpoints + UI | P2 |
| R-SCENIC-01 | Scenic spot query/detail | `/api/query/scenic-spots`, `ScenicRoutePage` | 部分实现 | Query exists, no management-side CRUD | P1 |
| R-SCENIC-02 | Route recommendation query | `/api/query/routes`, `ScenicRoutePage` | 部分实现 | No route management/admin workflow | P1 |
| R-DINE-01 | Dining/entertainment/performance query | `/api/query/dining`, `/api/query/entertainment`, `/api/query/performances`, `DiningShowPage` | 部分实现 | No merchant management workflow | P1 |
| R-TRAVEL-01 | Weather/traffic query | `/api/query/weather`, `/api/query/traffic`, `WeatherTrafficPage` | 部分实现 | No external sync/realtime source | P1 |
| R-PLAT-01 | Role/permission management | Role enum + method security exists | 部分实现 | No dedicated role-admin UI/API | P1 |
| R-PLAT-02 | Operation audit logs | No dedicated audit log module surfaced to UI/API | 未实现 | Add audit table + query API | P2 |
| R-PLAT-03 | Operations/content management | No dedicated operations module | 未实现 | Add content ops APIs and admin views | P2 |
| R-CONFLICT-01 | SRS catalog "实验室/仿真设备..." | `2.软件需求规约.docx` catalog only | 文档冲突待确认 | Out of confirmed VSS scope | N/A |

## Findings Summary
- Implemented baseline: auth login, complaint core path, emergency approval path, query module shell.
- Main gaps: account expansion, complaint workflow completeness, admin-side CRUD/operations, persistent data sources.
- Scope conflict handled by rule: only tourist-service body requirements are authoritative.
