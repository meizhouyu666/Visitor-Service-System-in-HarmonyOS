# Gap Backlog (Actionable, Team-Ready)

## Prioritization Rule
- `P0`: Core business closure and compatibility safety.
- `P1`: Important functional expansion that should follow P0.
- `P2`: Optimization/governance features after core rollout.

## P0
| Gap ID | Current State | Target Behavior | Impact | Compatibility Risk | Recommended Implementation | Acceptance Criteria |
|---|---|---|---|---|---|---|
| G-P0-01 | Complaint lacks reject action | Add explicit reject workflow | Complaint admin flow | Low (additive) | Add `REJECTED` status + `POST /api/complaints/admin/{id}/reject` | Approver/Admin can reject; visitor can see rejected status; old approve/process/close still works |
| G-P0-02 | No explicit assignment endpoint | Add assign-to-handler action | Complaint triage | Low (additive) | Add assignee field + `POST /api/complaints/admin/{id}/assign` | Assigned handler visible in detail/list; old flow unaffected |
| G-P0-03 | No complaint timeline/replies model | Full process trace for one complaint | Complaint transparency | Medium (new table) | Add complaint timeline entity/table + read/write APIs | Each action creates trace record; timeline query returns ordered records |
| G-P0-04 | Emergency visitor list ignores explicit active-window rule | Show only published + in-valid-window records | Emergency trust | Low | Apply validity filter in service layer while keeping endpoint path | Expired or not-yet-active items hidden from visitor API |
| G-P0-05 | No release gate enforcing zero-config startup | Prevent teammate config regressions | Whole project | Low | Add explicit release checklist (docs + CI gate note) | New release verified by "pull and run without config changes" |

## P1
| Gap ID | Current State | Target Behavior | Impact | Compatibility Risk | Recommended Implementation | Acceptance Criteria |
|---|---|---|---|---|---|---|
| G-P1-01 | Auth only has login/me | Add registration | User onboarding | Medium | Add `/api/auth/register` + UI entry | New user can register and login; existing login unchanged |
| G-P1-02 | No forgot-password flow | Add reset via verification code | Account recovery | Medium | Add request-code/reset APIs and flow | Reset works with valid code; invalid/expired code blocked |
| G-P1-03 | No admin delete user API | Add controlled user deletion | Platform ops | Medium | Add admin user-management endpoint | Admin can disable/delete by policy; unauthorized role blocked |
| G-P1-04 | Complaint list lacks multi-filter query | Add filter params | Admin efficiency | Low | Add optional query params; keep default behavior | Existing no-param call unchanged; filtered call returns narrowed set |
| G-P1-05 | Query data is in-memory sample | Persistent source for hotel/scenic/route/dining/weather traffic | Data reliability | Medium | Add repository-backed read path under existing endpoints | Existing endpoint paths preserved; data from DB source |
| G-P1-06 | No management CRUD for hotel/scenic/content | Add management-side data maintenance | Operations | Medium | Add admin/hotel manager CRUD APIs + pages | Managers can CRUD entities; visitor query reflects updates |

## P2
| Gap ID | Current State | Target Behavior | Impact | Compatibility Risk | Recommended Implementation | Acceptance Criteria |
|---|---|---|---|---|---|---|
| G-P2-01 | No complaint export | Export list/detail for operations | Reporting | Low | Add export endpoint (CSV/XLSX) | Admin export downloads valid file with selected filters |
| G-P2-02 | No push scope/real-time channel abstraction | Emergency push strategy by scope | Timeliness | Medium | Add push adapter and scope model | Push can target configured scope; visitor receives notifications |
| G-P2-03 | Audit logs not surfaced as module | Queryable operation audit | Governance | Medium | Add audit table + admin query API/page | Critical actions captured and queryable |
| G-P2-04 | No operations content management module | Manage homepage recommendations and hot services | Product operations | Medium | Add content ops APIs + admin UI | Ops updates visible on visitor home/content areas |

## Execution Notes
- Internal refactor is allowed, but all external compatibility constraints remain mandatory:
  - old startup steps unchanged
  - old API routes remain usable in compatibility window
  - no teammate-side config edits required after pulling latest
