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

## 版本说明（2026-04-18）

### P0 闭环统一落地（单次提交）

- 投诉链路补齐：新增驳回、分派、时间线能力，状态扩展 `REJECTED`。
- 权限规则收口：
  - `approve/reject/assign`：`APPROVER | ADMIN | SYSTEM_ADMIN`
  - `process/close`：`COMPLAINT_HANDLER | ADMIN | SYSTEM_ADMIN`
  - `VISITOR`：创建、查看本人、结案后评价
- 应急游客列表增加有效期过滤：仅返回 `PUBLISHED` 且处于有效窗口内的数据（`validFrom`/`validUntil` 支持空值语义）。
- 数据库增量迁移落地：
  - `V2__complaint_workflow_extensions.sql`
  - `V3__complaint_timeline.sql`
- 异常映射增强：`NoSuchElementException` 统一返回 `404/NOT_FOUND`，避免落入 500。
- 前端投诉页完成可用闭环：审批/驳回/分派动作、详情时间线、处理人/驳回信息展示、中文文案统一。
- 修复首页标签页切换问题：`Index.ets` 改为按 `tab key` 渲染，解决“点击标签未刷新页面”问题。
- 文档同步：更新 `docs/openapi-minimal.yaml` 与 `docs/testing-runbook.md`。
- 仓库卫生：未引入 `entry/.preview/**`、`oh_modules/.ohpm/**`、个人 IP/个人密码。
