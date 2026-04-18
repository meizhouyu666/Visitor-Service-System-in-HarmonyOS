# 需求-代码追踪矩阵（VSS）

## 范围与基线
- 需求来源：
  - `0鸿蒙系统游客服务AP2调研报告.docx`
  - `6.游客服务系统.docx`
  - `2.软件需求规约.docx`（仅采用游客系统正文）
- 冲突判定规则：
  - SRS 目录中的“实验室管理/仿真设备管理/课程管理”等条目视为模板残留。
  - 该类条目状态统一标记为 `文档冲突待确认`。

## 状态定义
- `已实现`：当前后端 + 前端流程中已具备对应行为。
- `部分实现`：主干能力存在，但关键子能力缺失。
- `未实现`：当前仓库中没有可用实现。
- `文档冲突待确认`：需求描述与已确认项目范围冲突。

## 追踪矩阵
| 需求 ID | 需求描述 | 代码证据 | 实现状态 | 缺口摘要 | 优先级 |
|---|---|---|---|---|---|
| R-AUTH-01 | 登录 + 基于角色的访问控制 | `backend/src/main/java/com/visitor/service/auth/AuthController.java`, `backend/src/main/java/com/visitor/service/config/SecurityConfig.java`, `frontend/harmony-app/entry/src/main/ets/pages/Index.ets` | 已实现 | 基础登录能力已具备 | P0 |
| R-AUTH-02 | 用户注册 | 无注册接口/页面 | 未实现 | 需要注册 API + 参数校验 + 前端入口 | P1 |
| R-AUTH-03 | 忘记密码（验证码） | 无重置验证码相关接口/页面 | 未实现 | 需要“申请验证码 + 重置密码”流程 | P1 |
| R-AUTH-04 | 管理员删除用户 | 无用户管理控制器 | 未实现 | 需要管理端用户管理接口 | P1 |
| R-COMP-01 | 游客提交投诉（文本 + 附件） | `ComplaintController#create`, `ComplaintService#create`, `ComplaintPage.submitComplaint()` | 已实现 | 附件目前仅支持 URL 字符串 | P0 |
| R-COMP-02 | 游客查看投诉列表/详情/进度 | `ComplaintController#list/detail`, `ComplaintPage.ListPanel()` | 部分实现 | 缺少完整时间线/历史模型 | P0 |
| R-COMP-03 | 投诉审批 | `ComplaintController#approve`, `ComplaintService#approve` | 已实现 | 流程粒度可进一步细化 | P0 |
| R-COMP-04 | 处理人员办理投诉 | `ComplaintController#process`, `ComplaintService#process` | 已实现 | 缺少结构化处理记录 | P0 |
| R-COMP-05 | 投诉结案 | `ComplaintController#close`, `ComplaintService#close` | 已实现 | 缺少结案清单/审计字段 | P0 |
| R-COMP-06 | 结案后游客评价 | `ComplaintController#rate`, `ComplaintService#rate` | 已实现 | 缺少评价文字/评论字段 | P1 |
| R-COMP-07 | 投诉驳回 | 无驳回接口/状态 | 未实现 | 新增 `REJECTED` 状态 + 驳回动作 | P0 |
| R-COMP-08 | 投诉分派 | 无显式分派接口 | 未实现 | 新增分派接口 + 处理人字段 | P0 |
| R-COMP-09 | 投诉过程跟踪/回复 | 无时间线/回复实体与接口 | 未实现 | 新增投诉过程记录表 + 相关接口 | P0 |
| R-COMP-10 | 投诉多条件查询 | `list` 仅支持角色范围 | 未实现 | 新增筛选参数（编号/类型/状态/时间/处理人） | P1 |
| R-COMP-11 | 投诉导出（Excel/CSV） | 无导出接口 | 未实现 | 新增导出接口 + 导出格式 | P2 |
| R-EMER-01 | 应急信息草稿增删改 | `EmergencyController#create/update/delete`, `EmergencyService` | 已实现 | 基础生命周期已具备 | P0 |
| R-EMER-02 | 提审 + 审批发布 | `EmergencyController#submit/approve`, `EmergencyService` | 已实现 | 基础审批链路已具备 | P0 |
| R-EMER-03 | 游客查看已发布应急信息 | `EmergencyController#listPublished`, `EmergencyPage` | 已实现 | 需显式加强有效期窗口过滤 | P0 |
| R-EMER-04 | 推送范围/实时推送 | 无推送服务抽象与通道配置 | 未实现 | 增加推送策略（可分阶段落地） | P2 |
| R-HOTEL-01 | 游客酒店查询/详情 | `/api/query/hotels`, `HotelPage` | 部分实现 | 目前为内存样例数据，缺少持久化来源 | P1 |
| R-HOTEL-02 | 酒店房态管理 | 无房态 CRUD 接口 | 未实现 | 新增管理端/酒店方数据模型与接口 | P1 |
| R-HOTEL-03 | 酒店营销推荐管理 | 无管理接口/页面 | 未实现 | 新增推荐配置接口与页面 | P2 |
| R-SCENIC-01 | 景区查询/详情 | `/api/query/scenic-spots`, `ScenicRoutePage` | 部分实现 | 已有查询，缺少管理侧 CRUD | P1 |
| R-SCENIC-02 | 线路推荐查询 | `/api/query/routes`, `ScenicRoutePage` | 部分实现 | 缺少线路管理/后台流程 | P1 |
| R-DINE-01 | 餐饮/娱乐/演出查询 | `/api/query/dining`, `/api/query/entertainment`, `/api/query/performances`, `DiningShowPage` | 部分实现 | 缺少商家管理流程 | P1 |
| R-TRAVEL-01 | 天气/路况查询 | `/api/query/weather`, `/api/query/traffic`, `WeatherTrafficPage` | 部分实现 | 缺少外部同步/实时数据源 | P1 |
| R-PLAT-01 | 角色与权限管理 | 角色枚举 + 方法级鉴权已存在 | 部分实现 | 缺少独立角色管理页面/API | P1 |
| R-PLAT-02 | 操作审计日志 | 无独立审计日志模块对外暴露 | 未实现 | 新增审计表 + 查询接口 | P2 |
| R-PLAT-03 | 运营/内容管理 | 无独立运营模块 | 未实现 | 新增内容运营 API 与后台页面 | P2 |
| R-CONFLICT-01 | SRS 目录“实验室/仿真设备...” | 仅见于 `2.软件需求规约.docx` 目录 | 文档冲突待确认 | 不在已确认 VSS 范围内 | N/A |

## 结论摘要
- 已落地主干：登录鉴权、投诉核心链路、应急审批链路、查询模块骨架。
- 主要缺口：账号体系扩展、投诉流程完整化、管理侧 CRUD/运营能力、持久化数据来源。
- 范围冲突处理：仅以游客系统正文需求作为权威依据。