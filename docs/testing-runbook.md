# 游客服务系统测试与运行手册（P0 闭环版）

本手册面向负责测试与联调的组员，覆盖当前 P0 交付范围：投诉与应急主链路可演示、六角色权限可验证、数据库增量迁移可执行。

## 1. 当前版本范围

- 前端：HarmonyOS（ArkTS + ArkUI + Stage Model）
- 后端：Spring Boot 3 + Spring Security + JWT + JPA + Flyway
- 数据库：MySQL 8（Docker）
- 本轮重点：
  - 投诉：提交、审批、驳回、分派、处理、结案、评价、时间线
  - 应急：建稿、提交、审批发布、游客查询（有效期过滤）
  - 查询：保留现有接口，不破坏兼容路径

## 2. 环境初始化

### 2.1 必备软件

- Git
- JDK 17
- Maven 3.8+
- Docker Desktop
- DevEco Studio

### 2.2 拉取代码

```bash
git clone https://github.com/meizhouyu666/Visitor-Service-System-in-HarmonyOS.git
cd Visitor-Service-System-in-HarmonyOS
git checkout main
git pull origin main
```

## 3. 后端运行

### 3.1 启动 MySQL

```bash
cd backend
docker compose up -d
```

默认配置：
- 数据库：`visitor_service_system`
- 用户：`root`
- 密码：`root`
- 端口：`3306`

### 3.2 启动后端

```bash
cd backend
mvn spring-boot:run
```

默认端口：`8080`

### 3.3 迁移验证（V1 -> V3）

启动日志中应看到 Flyway 成功执行：
- `V1__create_core_tables.sql`
- `V2__complaint_workflow_extensions.sql`
- `V3__complaint_timeline.sql`

## 4. 前端运行（DevEco）

### 4.1 打开工程

在 DevEco Studio 打开：
- `frontend/harmony-app`

### 4.2 网络地址

文件：
- `frontend/harmony-app/entry/src/main/ets/common/network/ApiClient.ets`

团队默认值：
- `http://10.0.2.2:8080`

说明：
- 模拟器通常使用 `10.0.2.2` 访问宿主机后端。
- 真机调试改为本机局域网 IP，但不要提交个人 IP 到仓库。

## 5. 账号与角色

- 游客：`visitor / visitor123`
- 平台管理员：`admin / admin123`
- 投诉处理员：`handler / handler123`
- 应急发布员：`writer / writer123`
- 审批员：`approver / approver123`
- 酒店管理员：`hoteladmin / hoteladmin123`
- 系统管理员：`sysadmin / sysadmin123`

## 6. 权限矩阵（P0）

- `VISITOR`：提交投诉、查看本人投诉、结案后评价、查看游客应急
- `APPROVER | ADMIN | SYSTEM_ADMIN`：投诉审批/驳回/分派
- `COMPLAINT_HANDLER | ADMIN | SYSTEM_ADMIN`：投诉处理/结案
- `EMERGENCY_WRITER | ADMIN | SYSTEM_ADMIN`：应急建稿/编辑/提交审批
- `APPROVER | ADMIN | SYSTEM_ADMIN`：应急审批发布

## 7. 测试清单

### 7.1 投诉主链路（必测）

1. 游客提交投诉成功。
2. 审批员或管理员执行“审批通过”成功。
3. 审批员或管理员执行“分派”成功，列表可看到处理人。
4. 处理员或管理员执行“提交处理”成功。
5. 处理员或管理员执行“结案”成功。
6. 游客对该投诉提交评价成功。
7. 投诉详情时间线可看到 `CREATE/APPROVE/ASSIGN/PROCESS/CLOSE/RATE`。

### 7.2 驳回链路（必测）

1. 游客提交投诉。
2. 审批员或管理员执行“驳回”。
3. 列表/详情可看到 `REJECTED` 状态与驳回原因。
4. 时间线可看到 `REJECT` 记录。

### 7.3 应急链路（必测）

1. 发布员或管理员创建草稿。
2. 提交审批。
3. 审批员或管理员审批发布。
4. 游客接口 `/api/emergency` 仅返回状态 `PUBLISHED` 且在有效窗口内的数据：
   - `validFrom` 为空：立即生效
   - `validUntil` 为空：长期有效

### 7.4 异常映射（必测）

1. 访问不存在的详情资源（如不存在投诉 ID）。
2. 返回应为业务 `NOT_FOUND/404`，不能是 500。

### 7.5 查询模块回归（必测）

以下接口应可正常返回（包含兼容接口）：
- `/api/query/hotels`
- `/api/query/hotels/star`
- `/api/query/hotels/non-star`
- `/api/query/scenic-spots`
- `/api/query/routes`
- `/api/query/dining`
- `/api/query/entertainment`
- `/api/query/dining-entertainment`
- `/api/query/performances`
- `/api/query/weather`
- `/api/query/traffic`
- `/api/query/weather-traffic`

## 8. 仓库卫生检查

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

## 9. 常见问题排查

- 后端起不来：检查 JDK 17、8080 端口占用、MySQL 容器状态
- 连不上库：检查 `backend/src/main/resources/application.yml` 与容器账号密码
- 前端请求失败：确认后端已启动、`API_BASE_URL` 是否符合当前网络路径
- 权限报错：检查登录账号角色是否匹配当前操作

## 10. 反馈模板

```text
【环境】
操作系统：
DevEco 版本：
运行方式：模拟器/真机

【测试项】
（例如：投诉驳回链路）

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
