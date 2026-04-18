# HarmonyOS 游客服务系统

本仓库是游客服务系统课程项目的单仓代码库（Monorepo）。

## 仓库结构

- `backend/`：Spring Boot + MySQL + JWT + OpenAPI
- `frontend/harmony-app/`：HarmonyOS ArkTS 前端骨架（Stage Model）
- `docs/`：最小接口契约与测试运行文档

## 快速开始

1. 克隆仓库。
2. 创建自己的功能分支。
3. 开发对应模块并推送分支。
4. 发起合并到 `main` 的 Pull Request。

## 分支命名规范

- 功能分支：`feature/<module>-<task>`
- 修复分支：`fix/<module>-<issue>`

## 后端启动

```bash
cd backend
docker compose up -d
mvn spring-boot:run
```

Swagger 页面：

- `http://localhost:8080/swagger-ui.html`

## 前端说明

- 在 DevEco Studio 中打开 `frontend/harmony-app`。
- 默认演示账号：
  - 游客：`visitor / visitor123`
  - 管理员：`admin / admin123`

## 版本说明（2026-04-17）

### v0.2.0（阶段二前后端统一版）

本版本合并了本日两次推送，目标是将项目从“骨架阶段”推进到“可联调演示阶段”，并完成前后端角色与接口统一。

1. 前端更新（提交：`0ac6c40`）
- 完成六角色导航与入口分离（含 `ADMIN` 兼容）。
- 落地投诉主链路页面能力：提交、列表、详情展示、审批、处理、结案、评价。
- 落地应急主链路页面能力：建稿、编辑、提交审批、审批发布、游客查询。
- 查询模块切换至新接口调用（酒店/景区线路/餐饮娱乐演出/天气路况）。
- 加强仓库卫生：忽略 `entry/.preview/` 与 `oh_modules/`，避免产物污染。

2. 后端更新（提交：`2dd4b12`）
- 角色体系扩展为：`VISITOR`、`COMPLAINT_HANDLER`、`EMERGENCY_WRITER`、`APPROVER`、`HOTEL_MANAGER`、`SYSTEM_ADMIN`、`ADMIN`。
- 统一投诉与应急模块权限边界（方法级鉴权，管理员兜底）。
- 新增并开放查询新路由：
  - `/api/query/hotels`
  - `/api/query/scenic-spots`
  - `/api/query/routes`
  - `/api/query/dining`
  - `/api/query/entertainment`
  - `/api/query/performances`
  - `/api/query/weather`
  - `/api/query/traffic`
- 保留旧查询路由兼容，避免旧前端调用立即中断。
- 增加多角色演示账号初始化（`handler/writer/approver/hoteladmin/sysadmin`）。

3. 已知事项
- 本版本按协作约定未执行本地 build/模拟器验证，需由测试同学在 DevEco 与后端环境中回归。
- 需持续避免提交本机产物与个人环境配置（如 `.preview`、`oh_modules`、个人 IP、个人密码）。


## 版本说明（2026-04-18）

### v0.2.1（需求差距交付包）

- 目标：先交付“需求文档 vs 现有代码”的可审阅差距结果，明确已实现/部分实现/未实现与冲突项。
- 新增文档：
  - `docs/requirements-gap-delivery.md`
  - `docs/requirements-traceability-matrix.md`
  - `docs/gap-backlog.md`
  - `docs/api-compatibility-diff.md`
  - `docs/db-migration-incremental-plan.md`
  - `docs/release-collaboration-gates.md`
- 兼容性承诺：保持现有项目架构边界，组员拉取最新代码后无需新增本地配置即可启动。
- 接口策略：旧接口保持可用（兼容层优先），新增能力通过增量方式落地。
- 发布要求：后续每次提交按模板补充 README 版本说明与验证结果。
