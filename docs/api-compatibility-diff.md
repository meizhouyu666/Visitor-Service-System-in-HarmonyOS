# 接口兼容差异清单（当前 -> 目标）

## 兼容策略
- 升级期间，现有接口持续可用（不强制前端立即改造）。
- 新能力优先通过“新增接口”增量交付。
- 允许内部重构，但必须放在兼容适配层之后。

## A. 保持不变的接口（继续保留）
| 接口 | 当前状态 | 保留策略 |
|---|---|---|
| `POST /api/auth/login` | 已实现 | 保持不变 |
| `GET /api/auth/me` | 已实现 | 保持不变 |
| `GET /api/complaints` | 已实现 | 路径保留，仅新增可选查询参数 |
| `POST /api/complaints` | 已实现 | 保持不变 |
| `GET /api/complaints/{id}` | 已实现 | 保持不变 |
| `POST /api/complaints/{id}/rating` | 已实现 | 保持不变 |
| `POST /api/complaints/admin/{id}/approve` | 已实现 | 保持不变 |
| `POST /api/complaints/admin/{id}/process` | 已实现 | 保持不变 |
| `POST /api/complaints/admin/{id}/close` | 已实现 | 保持不变 |
| `GET /api/emergency` | 已实现 | 保持路径，增强有效期过滤逻辑 |
| `GET /api/emergency/admin` | 已实现 | 保持不变 |
| `POST /api/emergency/admin` | 已实现 | 保持不变 |
| `PUT /api/emergency/admin/{id}` | 已实现 | 保持不变 |
| `DELETE /api/emergency/admin/{id}` | 已实现 | 保持不变 |
| `POST /api/emergency/admin/{id}/submit` | 已实现 | 保持不变 |
| `POST /api/emergency/admin/{id}/approve` | 已实现 | 保持不变 |
| `GET /api/query/*` 现有路径 | 已实现 | 保持现有路由契约 |

## B. 计划新增接口（增量）
| 新接口 | 目的 | 前端影响 | 兼容说明 |
|---|---|---|---|
| `POST /api/auth/register` | 用户注册 | 可选新增页面入口 | 不影响现有登录流程 |
| `POST /api/auth/forgot-password/request-code` | 申请验证码 | 仅新流程使用 | 增量新增 |
| `POST /api/auth/forgot-password/reset` | 验证码重置密码 | 仅新流程使用 | 增量新增 |
| `DELETE /api/admin/users/{id}` | 管理员删除用户 | 仅管理端页面使用 | 增量新增 |
| `POST /api/complaints/admin/{id}/reject` | 驳回投诉 | 管理员/审批人页面新增动作 | 增量新增 |
| `POST /api/complaints/admin/{id}/assign` | 分派投诉处理人 | 管理端页面新增动作 | 增量新增 |
| `GET /api/complaints/{id}/timeline` | 投诉过程跟踪 | 投诉详情增强 | 增量新增 |
| `GET /api/complaints/export` | 投诉导出 | 管理工具能力 | 增量新增 |

## C. 兼容期规则
- 废弃接口（如有）必须先在文档中标记，再进入移除流程。
- 任一接口移除必须满足：
  1. 至少一个发布周期保留兼容适配层；
  2. 在 README 版本说明中给出变更预警；
  3. 提供明确可执行的迁移指引与替代调用。

## D. 前端改造要求
- 目标：已上线可用流程“不被强制改造”。
- 现有页面应在不改路由映射的情况下继续可用。
- 新功能页面优先消费新增接口，不破坏旧链路。