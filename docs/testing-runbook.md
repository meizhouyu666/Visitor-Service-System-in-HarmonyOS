# 游客服务系统测试与运行手册（当前版本）

本手册面向负责测试与联调的组员，基于当前仓库代码结构整理。  
适用提交：`c22d51b`（及之后兼容版本）

---

## 1. 当前架构概览

### 1.1 仓库结构

- `backend/`：Java Spring Boot 后端
- `frontend/harmony-app/`：HarmonyOS 前端（ArkTS + ArkUI + Stage Model）
- `docs/openapi-minimal.yaml`：最小接口契约

### 1.2 技术栈

- 前端：ArkTS、ArkUI、UIAbility（Stage Model）
- 后端：Spring Boot 3、Spring Security、JWT、JPA、Flyway
- 数据库：MySQL 8
- 接口文档：Swagger UI

### 1.3 当前实现范围

- 登录与鉴权：`/api/auth/login`、`/api/auth/me`
- 投诉主链路：提交、列表、详情、审批、处理、结案、评价
- 应急信息：创建、审批发布、查询、修改、删除
- 查询模块骨架：酒店、景区线路、餐饮演出、天气路况

---

## 2. 环境初始化

## 2.1 必备软件

- Git
- JDK 17
- Maven 3.8+
- Docker Desktop（用于 MySQL）
- DevEco Studio（用于 Harmony 前端）

## 2.2 拉取代码

```bash
git clone https://github.com/meizhouyu666/Visitor-Service-System-in-HarmonyOS.git
cd Visitor-Service-System-in-HarmonyOS
git checkout main
git pull origin main
```

---

## 3. 后端运行与验证

## 3.1 启动数据库（MySQL）

```bash
cd backend
docker compose up -d
```

说明：

- 默认数据库：`visitor_service_system`
- 默认 root 密码：`root`
- 端口：`3306`

## 3.2 启动后端服务

```bash
cd backend
mvn spring-boot:run
```

默认端口：`8080`

## 3.3 打开 Swagger

- [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)

## 3.4 默认测试账号

- 游客：
  - 用户名：`visitor`
  - 密码：`visitor123`
- 管理员：
  - 用户名：`admin`
  - 密码：`admin123`

---

## 4. 前端（DevEco）运行说明

## 4.1 打开工程

在 DevEco Studio 中打开目录：

`frontend/harmony-app`

## 4.2 网络地址配置

前端 API 地址在：

`frontend/harmony-app/entry/src/main/ets/common/network/ApiClient.ets`

当前默认值：

`http://10.0.2.2:8080`

说明：

- 若使用模拟器，通常 `10.0.2.2` 可访问宿主机 localhost。
- 若使用真机，请改为电脑局域网 IP（例如 `http://192.168.x.x:8080`）。

## 4.3 前端基本验证

- 启动应用后出现登录页
- 用 `visitor/visitor123` 登录进入游客视图
- 用 `admin/admin123` 登录进入管理角色视图（用于后台接口测试）
- Tab 页面可切换：投诉、应急、酒店、景区、餐饮、天气

---

## 5. 测试清单（建议按顺序）

## 5.1 鉴权与角色

1. 游客登录成功，能调用普通接口。
2. 游客访问管理员接口（`/api/complaints/admin/*`、`/api/emergency/admin/*`）应被拒绝。
3. 管理员登录后可访问管理员接口。

## 5.2 投诉主链路（核心）

1. 游客提交投诉成功。
2. 管理员可在列表看到投诉并执行审批。
3. 管理员执行处理、结案。
4. 游客对已结案投诉可评分。
5. 未结案投诉评分应失败（业务限制）。

## 5.3 应急信息链路

1. 管理员创建草稿成功。
2. 提交审批成功。
3. 审批发布成功。
4. 游客侧接口可查询到已发布信息。
5. 管理员可修改、删除应急信息。

## 5.4 查询模块骨架

检查以下接口均可返回列表或结构化结果：

- `/api/query/hotels/star`
- `/api/query/hotels/non-star`
- `/api/query/scenic-spots`
- `/api/query/routes`
- `/api/query/dining-entertainment`
- `/api/query/performances`
- `/api/query/weather-traffic`

---

## 6. 常见问题排查

## 6.1 后端启动失败

- 检查 JDK 是否为 17
- 检查 8080 端口是否被占用
- 检查 MySQL 是否已启动并可连接

## 6.2 数据库连接失败

- 查看 `backend/src/main/resources/application.yml` 中数据库配置
- 确认 Docker MySQL 容器是否正常运行

## 6.3 前端请求失败

- 确认后端已启动
- 检查 `ApiClient.ets` 中 `API_BASE_URL` 是否符合当前设备网络路径
- 检查是否有防火墙拦截 8080 端口

---

## 7. 测试反馈模板（请直接回传）

请按以下模板反馈，便于快速定位：

```text
【环境】
操作系统：
DevEco版本：
运行方式：模拟器/真机

【步骤】
1.
2.
3.

【期望结果】

【实际结果】

【日志/报错】
（粘贴完整报错，包含时间与接口路径）

【截图】
（可选）
```

---

## 8. 备注

- 当前版本重点是“架构完整 + 可联调”，不是最终业务深度版本。
- 若发现接口字段不一致，请优先以 Swagger 实际返回为准并反馈。
