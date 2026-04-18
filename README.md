# HarmonyOS 游客服务系统

本仓库是《游客服务系统》课程项目单仓代码库（Monorepo）。

## 仓库结构

- `backend/`：Spring Boot + MySQL + JWT + Flyway
- `frontend/harmony-app/`：HarmonyOS ArkTS 前端（Stage Model）
- `docs/`：接口契约与联调测试文档

## 快速开始

1. 克隆仓库并切换到 `main`。
2. 启动后端依赖（MySQL Docker）。
3. 启动后端服务。
4. 使用 DevEco 打开 `frontend/harmony-app` 运行前端。

## 后端启动

```bash
cd backend
docker compose up -d
mvn spring-boot:run
```

Swagger：
- http://localhost:8080/swagger-ui.html

## 前端说明

- 在 DevEco Studio 打开 `frontend/harmony-app`。
- 默认后端地址：`http://10.0.2.2:8080`（模拟器访问宿主机）。
- 真机联调可本地改为局域网地址，但禁止提交个人 IP。

## 演示账号

- 游客：`visitor / visitor123`
- 平台管理员：`admin / admin123`
- 投诉处理员：`handler / handler123`
- 应急发布员：`writer / writer123`
- 审批员：`approver / approver123`
- 酒店管理员：`hoteladmin / hoteladmin123`
- 系统管理员：`sysadmin / sysadmin123`

## 分支协作规范

- 主分支：`main`（建议启用保护规则）
- 开发分支命名：
  - 功能：`feature/<module>-<task>`
  - 修复：`fix/<module>-<issue>`
- 建议流程：分支开发 -> PR 审查 -> 合并 `main`

## 版本说明

### 2026-04-18（P0 闭环统一落地）

- 投诉链路补齐：新增驳回、分派、时间线，状态扩展 `REJECTED`。
- 权限收口：
  - `approve/reject/assign`：`APPROVER | ADMIN | SYSTEM_ADMIN`
  - `process/close`：`COMPLAINT_HANDLER | ADMIN | SYSTEM_ADMIN`
  - `VISITOR`：创建、查看本人、结案后评分
- 应急游客列表加入有效期过滤（仅返回有效窗口内 `PUBLISHED`）。
- Flyway 增量迁移落地：`V2`、`V3`。
- 异常映射增强：`NoSuchElementException -> 404/NOT_FOUND`。

### 2026-04-18（P1 核心包：认证 + 筛选 + 查询持久化）

- 认证扩展：
  - 新增 `POST /api/auth/register`
  - 新增 `POST /api/auth/forgot-password/request-code`
  - 新增 `POST /api/auth/forgot-password/reset`
  - 验证码规则：6 位数字、10 分钟有效、单次使用、仅最新有效
- 投诉筛选：`GET /api/complaints` 支持 `status/createdBy/assignee/keyword/from/to`。
- 查询持久化：`/api/query/*` 改为 MySQL 表读取，保留兼容接口。
- Flyway 新增：
  - `V4__query_domain_tables.sql`
  - `V5__auth_extension_tables.sql`
- 前端落地：登录页支持登录/注册/忘记密码三态；投诉页新增筛选区与重置动作。
- 角色规则加强：应急管理接口加入方法级权限控制，避免普通角色误调用。

#### P1 回滚说明

如需回滚 P1，请按以下顺序执行：
1. 代码回滚到 P0 对应提交（通过 Git tag 或提交号）。
2. 数据库仅做向后兼容读取，不执行破坏性删除（`V4/V5` 表可保留）。
3. 前端恢复到不依赖注册/忘记密码与投诉筛选参数的版本。

> 说明：课程环境建议“代码回滚、数据保留”，避免影响已有联调数据。

### 2026-04-18（P2 游客端 UI 大改：四栏导航 + 视觉重构）

- 游客端重构为底部四栏：`首页 / 服务 / 投诉 / 应急`，替换原顶部多标签导航。
- 新增游客首页 Dashboard：天气摘要、服务金刚区、今日推荐景点卡、投诉进度摘要卡。
- 服务页整合酒店/景区/线路，并支持房态标签与景区客流热度展示。
- 游客投诉页重排为“提交表单 + 附件占位 + 时间轴进度 + 历史记录”结构。
- 游客应急页重排为“预警卡 + 路况示意地图卡 + 实时提醒列表”结构（静态示意地图方案）。
- 前端新增可复用 UI 组件库：悬浮卡片、主按钮、状态徽标、分组标题、空态卡、时间轴节点、筛选芯片。
- 新增数据库增量脚本：`V6__ui_enhancement_fields.sql`，扩展可选字段：
  - 酒店：`availability_status`、`cover_image_url`
  - 景区：`crowd_heat`、`cover_image_url`
  - 应急：`alert_level`、`alert_type`
  - 路况：`severity_level`
- 接口兼容策略：旧路径与旧字段保持可用，新字段按“可选”返回，旧前端不受影响。
