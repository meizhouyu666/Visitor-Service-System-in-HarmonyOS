# 需求差距交付包

本交付包用于落实“需求对比交付计划（明确缺什么 + 交付什么）”。

## 交付物清单
1. 需求-代码追踪矩阵  
   - 文件：`docs/requirements-traceability-matrix.md`
2. 可开发缺口清单（P0/P1/P2）  
   - 文件：`docs/gap-backlog.md`
3. 接口兼容差异清单（旧 -> 新）  
   - 文件：`docs/api-compatibility-diff.md`
4. 数据库增量迁移计划（Flyway V2+）  
   - 文件：`docs/db-migration-incremental-plan.md`
5. 发布与协作门禁 + README 模板  
   - 文件：`docs/release-collaboration-gates.md`

## 范围判定
- `2.软件需求规约.docx` 采用“游客系统正文优先”原则。
- 与游客服务系统无关的目录项（如实验室/仿真模块）标记为冲突项，默认不进入实施范围，除非后续再次确认。

## 使用方式
- 产品/需求评审：先看追踪矩阵。
- 团队排期拆分：直接使用 `gap-backlog.md`。
- 后端与接口交付：遵循 `api-compatibility-diff.md`。
- 数据库交付：遵循 `db-migration-incremental-plan.md`。
- 合并与发布：执行 `release-collaboration-gates.md`。