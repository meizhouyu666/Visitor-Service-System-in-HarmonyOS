# Requirements Gap Delivery Package

This package implements the "需求对比交付计划（明确缺什么 + 交付什么）".

## Deliverables
1. Requirement-Code Traceability Matrix  
   - File: `docs/requirements-traceability-matrix.md`
2. Actionable Gap Backlog (P0/P1/P2)  
   - File: `docs/gap-backlog.md`
3. API Compatibility Diff (old -> new)  
   - File: `docs/api-compatibility-diff.md`
4. Incremental DB Migration Plan (Flyway V2+)  
   - File: `docs/db-migration-incremental-plan.md`
5. Release & Collaboration Gates + README template  
   - File: `docs/release-collaboration-gates.md`

## Scope Decision
- `2.软件需求规约.docx` is used with "tourist-service body first".
- Catalog entries unrelated to VSS (lab/simulation modules) are marked as conflict items and excluded from implementation scope unless re-confirmed.

## Usage
- Product/PM review: start from traceability matrix.
- Team planning: consume `gap-backlog.md` directly for task splitting.
- Backend/API delivery: follow `api-compatibility-diff.md`.
- DB delivery: follow `db-migration-incremental-plan.md`.
- Merge/release: enforce `release-collaboration-gates.md`.
