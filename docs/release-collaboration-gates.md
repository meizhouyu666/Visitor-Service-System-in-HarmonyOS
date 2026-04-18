# Release & Collaboration Gates (Zero-Config Safety)

## Release Gate (Must Pass)
1. Teammate can pull latest and run with existing steps (no local config edits).
2. Existing core flows still work:
   - login
   - complaint main path
   - emergency main path
   - existing query endpoints
3. Additive features verified and documented.
4. README version section updated in this commit.

## PR Checklist (Copy into PR Description)
- [ ] No teammate-side config change required
- [ ] Existing startup commands unchanged
- [ ] Existing API routes remain usable
- [ ] Flyway migration is additive only
- [ ] Compatibility statement included
- [ ] Rollback approach included
- [ ] README version note updated

## README Version Note Template (Required)
```md
## 版本说明（YYYY-MM-DD）

### vX.Y.Z（本次发布主题）
- 目标：
- 主要变更：
  - 后端：
  - 前端：
  - 数据库迁移：
- 接口兼容性：
  - 保留旧接口：
  - 新增接口：
  - 兼容期说明：
- 配置影响：
  - ✅ 组员拉取后无需修改任何本地配置
  - 启动步骤与端口保持不变
- 回滚说明：
  - 代码回滚：
  - 数据库回滚（如适用）：
```

## Notes for Frontend Work
- When frontend implementation starts, follow `harmonyos-app` skill constraints:
  - strict ArkTS typing
  - Stage model only
  - componentized ArkUI
  - immutable state updates
