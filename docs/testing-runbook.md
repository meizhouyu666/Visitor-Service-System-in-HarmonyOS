# 游客服务系统测试与运行手册（P5 后端全链路补齐版）

本手册面向测试与联调组员，覆盖当前交付范围：
- 五角色 RBAC：游客、平台管理员、投诉处理员、酒店管理员、系统管理员
- 投诉主链路：提交、审批、驳回、分派、处理、结案、评价、时间线
- 应急主链路：草稿、提交审批、审批发布、驳回修改、游客侧有效期过滤
- 酒店隔离：酒店管理员一账号一酒店
- 旅游资源库：平台管理员四类资源内容管理
- 系统管理：账号管理、审计日志、系统参数

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
git checkout meizhouyu666-p1-core-package
git pull origin meizhouyu666-p1-core-package
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
- `V10__system_resource_backend_extensions.sql`

## 3. 前端运行（DevEco）

### 3.1 打开工程
在 DevEco Studio 打开：
- `frontend/harmony-app`

### 3.2 后端地址
文件：
- `frontend/harmony-app/entry/src/main/ets/common/network/ApiClient.ets`

团队默认值：
- `http://10.0.2.2:8081`

## 4. 演示账号
- 游客：`visitor / visitor123`
- 平台管理员：`admin / admin123`
- 投诉处理员：`handler / handler123`
- 酒店管理员：`hoteladmin / hoteladmin123`
- 系统管理员：`sysadmin / sysadmin123`
- 兼容账号：`writer / writer123`、`approver / approver123` 仍可登录，但角色已并入平台管理员 `ADMIN`

## 5. 五角色权限路径
1. `VISITOR`：查询游客服务、查看应急、提交投诉、查看本人投诉、结案后评价。
2. `ADMIN`：平台运营后台，负责投诉审批/驳回/分派/结案、应急发布审批、导流营销、旅游资源库管理。
3. `COMPLAINT_HANDLER`：一线处理人员，只查看和处理分派给自己的投诉任务。
4. `HOTEL_ADMIN`：酒店管理员，只能查看并维护自己绑定酒店的资料与房态。
5. `SYSTEM_ADMIN`：系统管理员，负责账号、审计日志、系统参数，不参与投诉/应急/导流营销业务操作。

## 6. 核心测试清单

### 6.1 认证与账号
1. 注册：新用户名注册成功，角色默认为 `VISITOR`。
2. 重复用户名注册：被拦截并返回业务错误。
3. 忘记密码申请验证码：返回 `debugCode`，有效期取系统参数 `PASSWORD_RESET_CODE_EXPIRE_SECONDS`。
4. 使用错误验证码重置：失败。
5. 使用正确验证码重置：成功，新密码可登录、旧密码失效。
6. 系统管理员可新增平台管理员、投诉处理员、酒店管理员、系统管理员账号。
7. 系统管理员可停用账号；被停用账号登录应失败。

### 6.2 投诉链路
1. 游客提交投诉成功。
2. 管理员审批通过/驳回成功。
3. 管理员分派处理人成功。
4. 处理员只能处理分派给自己的投诉。
5. 管理员结案成功。
6. 游客只能评价自己且已结案的投诉。
7. 时间线包含 `CREATE / APPROVE / REJECT / ASSIGN / PROCESS / CLOSE / RATE`。
8. 审计日志中可以看到投诉相关关键动作。

### 6.3 应急链路
1. 平台管理员创建草稿成功。
2. 提交审批成功。
3. 审批发布成功。
4. 驳回修改成功，状态回到 `REJECTED`。
5. 驳回后的应急信息可再次编辑并重新提交审批。
6. 游客侧 `/api/emergency` 仅返回 `PUBLISHED` 且在有效期窗口内的数据。

### 6.4 旅游资源库链路
1. 平台管理员可管理四类资源：
   - 景区景点
   - 游览线路
   - 餐饮
   - 演出
2. 支持列表、详情、新增、编辑、上架、下架、删除。
3. 下架后游客侧 `/api/query/scenic-spots`、`/routes`、`/dining`、`/performances` 不再返回该资源。
4. 重新上架后游客侧再次可见。
5. 资源管理动作写入审计日志。

### 6.5 酒店链路
1. `hoteladmin` 登录后调用 `/api/hotels/admin` 仅返回自己绑定酒店。
2. `hoteladmin` 仅可更新自己绑定酒店，不可越权更新其他酒店。
3. `hoteladmin` 不可新增/删除酒店。
4. `sysadmin` 可新增/删除酒店，并可为酒店管理员绑定酒店。
5. `admin` 不可调用酒店管理写接口。

### 6.6 系统管理链路
1. 系统管理员可查询账号列表。
2. 系统管理员可创建账号、修改角色、重置密码、启停账号。
3. 系统管理员可查询审计日志，并按时间、操作者、模块、动作过滤。
4. 系统管理员可查询和更新系统参数。
5. 固定五角色权限展示需与实际权限保持一致。

## 7. 仓库卫生检查
合并前请确认：
- 不提交 `frontend/harmony-app/entry/.preview/**`
- 不提交 `frontend/harmony-app/oh_modules/.ohpm/**`
- 不提交个人 IP、个人数据库密码

Windows PowerShell：

```powershell
git ls-files | Select-String "entry/.preview|oh_modules/.ohpm"
```

## 8. 常见问题排查
- 后端启动失败：检查 JDK 17、8081 端口占用、MySQL 容器状态。
- 数据库连接失败：先执行 `docker compose up -d`，再检查 `backend/src/main/resources/application.yml` 与 Docker 账号密码是否一致。
- 酒店管理员看不到数据：确认 `users.managed_hotel_id` 已正确绑定酒店。
- 游客看不到资源：检查对应资源是否处于上架状态。
- 审计日志为空：确认实际发生了登录、投诉、应急、资源或系统管理操作。

## 9. 反馈模板

```text
【环境】
操作系统：
DevEco 版本：
运行方式：模拟器/真机

【测试项】

【步骤】
1.
2.
3.

【期望结果】

【实际结果】

【日志/报错】

【截图】
```
