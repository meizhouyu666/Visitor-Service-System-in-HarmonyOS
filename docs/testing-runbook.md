# 游客服务系统测试与运行手册（P4 五角色 RBAC 收敛）

本手册面向测试与联调组员，覆盖当前交付范围：
- 认证扩展：注册、忘记密码（站内验证码）
- 投诉筛选：多条件筛选与权限边界
- 查询持久化：`/api/query/*` 改为 MySQL 数据源（保留兼容路由）
- 五角色 RBAC 收敛：游客、平台管理员、投诉处理员、酒店管理员、系统管理员

补充 P2（游客端 UI 大改）：
- 游客端导航重构为：首页 / 服务 / 投诉 / 应急
- 查询/应急新增可选展示字段：房态、封面图、客流热度、预警等级/类型、路况告警级别

## 1. 环境准备

### 1.1 必备软件

- Git
- JDK 17
- Maven 3.8+
- Docker Desktop
- DevEco Studio

### 1.2 拉取代码

```bash
git clone https://github.com/meizhouyu666/Visitor-Service-System-in-HarmonyOS.git
cd Visitor-Service-System-in-HarmonyOS
git checkout main
git pull origin main
```

## 2. 后端运行

### 2.1 启动 MySQL（Docker）

```bash
cd backend
docker compose up -d
```

默认配置：
- 数据库：`visitor_service_system`
- 用户：`root`
- 密码：`root`
- 端口：`3306`

### 2.2 启动后端

推荐（含 MySQL 连通性前置检查）：

```powershell
cd backend
./scripts/start-backend.ps1
```

或直接启动：

```bash
cd backend
mvn spring-boot:run
```

默认端口：`8081`

### 2.3 Flyway 迁移验证

启动日志应看到以下脚本依次执行成功：
- `V1__create_core_tables.sql`
- `V2__complaint_workflow_extensions.sql`
- `V3__complaint_timeline.sql`
- `V4__query_domain_tables.sql`
- `V5__auth_extension_tables.sql`
- `V6__ui_enhancement_fields.sql`
- `V7__dining_performance_extensions.sql`
- `V8__merge_system_admin_role.sql`
- `V9__normalize_five_roles.sql`

## 3. 前端运行（DevEco）

### 3.1 打开工程

在 DevEco Studio 打开：
- `frontend/harmony-app`

### 3.2 后端地址

文件：
- `frontend/harmony-app/entry/src/main/ets/common/network/ApiClient.ets`

团队默认值：
- `http://10.0.2.2:8081`

说明：
- 模拟器通常使用 `10.0.2.2` 访问宿主机后端。
- 真机调试可临时改本机局域网 IP，但禁止提交个人 IP 到仓库。

## 4. 演示账号

- 游客：`visitor / visitor123`
- 平台管理员：`admin / admin123`
- 投诉处理员：`handler / handler123`
- 酒店管理员：`hoteladmin / hoteladmin123`
- 系统管理员：`sysadmin / sysadmin123`
- 兼容账号：`writer / writer123`、`approver / approver123` 仍可登录，但角色已并入平台管理员 `ADMIN`。

## 4.1 五角色权限路径

1. `VISITOR`：查询游客服务、查看应急、提交投诉、查看本人投诉、结案后评价。
2. `ADMIN`：平台运营后台，负责投诉审批/驳回/分派/结案、应急发布审批、导流营销、旅游资源库入口。
3. `COMPLAINT_HANDLER`：一线处理人员，只查看和处理分派给自己的投诉任务。
4. `HOTEL_ADMIN`：酒店管理员，只进入酒店房态/酒店信息维护页面。
5. `SYSTEM_ADMIN`：系统管理员，只进入用户、角色、权限、日志类系统管理入口；本轮为占位入口。

## 5. P4 测试清单

### 5.1 认证扩展（必测）

1. 注册：新用户名注册成功，角色默认为 `VISITOR`。
2. 重复用户名注册：被拦截并返回业务错误。
3. 忘记密码申请验证码：返回 `debugCode`，有效期 10 分钟。
4. 同账号重复申请验证码：仅最新验证码可用。
5. 使用错误验证码重置：失败。
6. 使用过期验证码重置：失败。
7. 使用正确验证码重置：成功，新密码可登录、旧密码失效。

### 5.2 投诉筛选（必测）

1. 游客登录请求 `/api/complaints`：仅返回本人数据。
2. 管理侧按 `status` 筛选：结果正确。
3. 管理侧按 `createdBy`、`assignee` 筛选：结果正确。
4. 按 `keyword`、`from`、`to` 组合筛选：结果正确。
5. 空参请求：行为与旧版本一致（返回当前角色可见列表）。

### 5.3 投诉主链路回归（必测）

1. 提交投诉。
2. 审批通过/驳回。
3. 分派处理人。
4. 处理并结案。
5. 游客评价。
6. 时间线包含 `CREATE/APPROVE/REJECT/ASSIGN/PROCESS/CLOSE/RATE`。

### 5.4 查询持久化（必测）

以下接口均应返回数据，且不依赖内存硬编码：
- `/api/query/hotels`
- `/api/query/scenic-spots`
- `/api/query/routes`
- `/api/query/dining`
- `/api/query/entertainment`
- `/api/query/performances`
- `/api/query/weather`
- `/api/query/traffic`

兼容接口也需可用：
- `/api/query/hotels/star`
- `/api/query/hotels/non-star`
- `/api/query/dining-entertainment`
- `/api/query/weather-traffic`

### 5.5 应急链路回归（必测）

1. 平台管理员创建草稿并提交审批。
2. 平台管理员审批发布。
3. 游客侧 `/api/emergency` 仅返回 `PUBLISHED` 且在有效期窗口内的数据。

### 5.5.1 五角色回归（必测）

1. `admin` 登录后进入平台工作台，可进入投诉管理、应急信息、导流营销、旅游资源库入口。
2. `writer/approver` 登录后也进入平台工作台，不再出现独立发布员/审批员首页。
3. `handler` 登录后只进入投诉处理页，不能进入应急、酒店、导流营销后台。
4. `hoteladmin` 登录后只进入酒店管理页，可调用 `/api/hotels/admin`。
5. `admin` 调用 `/api/hotels/admin` 新增/编辑/删除应返回无权限。
6. `sysadmin` 登录后进入系统管理中心，不参与投诉、应急、酒店、营销业务操作。

### 5.6 异常映射（必测）

1. 查询不存在资源（如不存在的投诉 ID）。
2. 返回 `404/NOT_FOUND`，不应返回 `500`。

## 6. 仓库卫生检查

合并前请确认：
- 不提交 `frontend/harmony-app/entry/.preview/**`
- 不提交 `frontend/harmony-app/oh_modules/.ohpm/**`
- 不提交个人 IP、个人数据库密码

可使用：

```bash
git ls-files | grep -E "entry/.preview|oh_modules/.ohpm"
```

Windows PowerShell：

```powershell
git ls-files | Select-String "entry/.preview|oh_modules/.ohpm"
```

## 7. 常见问题排查

- 后端启动失败：检查 JDK 17、8081 端口占用、MySQL 容器状态。
- 数据库连接失败：先执行 `docker compose up -d`，再检查 `backend/src/main/resources/application.yml` 与 Docker 账号密码是否一致。
- 前端请求失败：确认后端已启动，`API_BASE_URL` 与当前运行环境一致。
- 权限报错：确认登录账号角色与目标操作匹配。

## 8. 反馈模板

```text
【环境】
操作系统：
DevEco 版本：
运行方式：模拟器/真机

【测试项】
（例如：投诉筛选 by status + keyword）

【步骤】
1.
2.
3.

【期望结果】

【实际结果】

【日志/报错】
（包含接口路径与时间）

【截图】
（可选）
```
