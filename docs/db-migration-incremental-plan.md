# Database Migration Plan (Flyway V2+ / Docker MySQL)

## Hard Constraints
- DB runtime remains Docker MySQL (existing `backend/docker-compose.yml` flow).
- Only additive Flyway migrations (`V2__...` and above).
- No destructive migration that can break existing teammate environments.

## Planned Migrations
| Script | Purpose | Change Type | Existing Data Impact | Rollback Strategy | Compatibility |
|---|---|---|---|---|---|
| `V2__complaint_workflow_extensions.sql` | Add complaint reject/assign fields and indexes | Add columns/indexes | Existing rows remain valid (nullable defaults) | Forward rollback via compensating migration (`Vx__revert_*`) if needed | Old APIs continue to read existing fields |
| `V3__complaint_timeline.sql` | Add complaint timeline table for process trace | New table | No impact on existing tables | Drop newly added table in compensating migration | Fully additive |
| `V4__query_domain_tables.sql` | Add persistent domain tables for hotel/scenic/route/dining/performance/weather/traffic | New tables | No impact on existing data | Compensating migration to drop new tables | Existing `/api/query/*` paths preserved |
| `V5__auth_extension_tables.sql` | Add verification-code and password-reset support tables | New table(s) | No impact on existing users | Compensating migration to drop new table(s) | Existing login unchanged |
| `V6__audit_log.sql` | Add operation audit log storage | New table | No impact | Compensating migration | Additive governance feature |

## Execution Checklist
1. Validate migration on clean DB (fresh Docker volume).
2. Validate migration on existing DB with V1 data.
3. Run app startup and smoke test old flows:
   - auth login/me
   - complaint create/list/detail/rate/admin actions
   - emergency publish flow
   - existing query endpoints
4. Verify no config changes required by teammates.

## Delivery Rule
- Every migration PR must include:
  - purpose
  - compatibility statement
  - rollback approach
  - clean DB + existing DB verification result
