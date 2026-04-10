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
