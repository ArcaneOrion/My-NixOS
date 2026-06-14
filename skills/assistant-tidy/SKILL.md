---
name: assistant-tidy
description: 静态审计用户记忆系统，检查 signals/portrait/working/learning 等文件是否符合结构、证据链和写入边界；只做最小修正。
---

# 记忆系统静态审计

## 定位

审计已落盘的记忆文件是否符合新系统边界。执行格式修正、重复提示、证据链检查和疑问标记；不要生成画像，不要替代 `assistant-portrait`。

## 读取范围

读取：

- `/home/arcaneorion/user-memory/signals/schema.md`
- `/home/arcaneorion/user-memory/signals/quality-criteria.md`
- `/home/arcaneorion/user-memory/journal/schema.md`
- `/home/arcaneorion/user-memory/archive/schema.md`
- `/home/arcaneorion/user-memory/signals/` 文件列表与相关文件
- `/home/arcaneorion/user-memory/portrait/` 全部文件
- `/home/arcaneorion/user-memory/working.md` 与 `/home/arcaneorion/user-memory/tracks.md`
- `/home/arcaneorion/user-memory/learning/overview.md`
- `/home/arcaneorion/user-memory/journal/` 文件列表
- `/home/arcaneorion/user-memory/archive/` 文件列表

根目录旧画像 `profile*.md` / `self.md` 若仍存在，只标记为迁移残留；fallback 应优先读取 archive 最新 `portrait_snapshot`，`archive/v1/` 只作为低权重 `legacy_prior`。

## 允许操作

可以：

- 修正明显格式错误。
- 标记 schema 缺失项。
- 标记 portrait 条目缺少 evidence。
- 标记 AI 推断疑似写成用户立场。
- 标记 declarations 中缺少用户原话、来源、状态、置信度或主体性边界的条目。
- 标记重复或冲突条目。
- 提出合并/删除建议。
- 修复文件标题、日期格式、frontmatter 小错误。

## 禁止操作

不要默认：

- 删除实质内容。
- 重写画像判断。
- 合并有语义差异的条目。
- 把 AI 推断改写成用户立场。
- 从 signals 生成 portrait。
- 静默改写 declarations 的声明内容。

不确定时，添加疑问标记或询问用户。

## 审计流程

### 1. 结构检查

检查目录是否存在：

- `signals/`
- `portrait/`
- `archive/`
- `journal/`
- `learning/`
- `raw/`

检查关键文件是否存在：

- `signals/schema.md`
- `signals/quality-criteria.md`
- `portrait/self.md`
- `portrait/profile-core.md`
- `portrait/profile-patterns.md`
- `portrait/profile-history.md`
- `portrait/declarations.md`
- `portrait/evidence-index.md`
- `portrait/synthesis-log.md`

### 2. signals 审计

检查每个 signal：

- frontmatter 是否完整。
- 是否逐轮保留用户原文；关键原话摘录是否只作为索引而非替代。
- 是否区分 L1/L2/L3。
- AI 推断是否带置信度、证据、边界。
- 是否存在评价词污染。
- 是否把单次会话直接写成稳定画像。

### 3. portrait 审计

检查 portrait：

- 每条画像是否有 evidence-index 来源。
- synthesis-log 顶部是否维护「当前综合基线」，基线 commit 是否存在于 git 历史。
- declarations 是否保留用户原话、来源、状态、置信度和主体性边界。
- `archive/v1/` 中 `legacy_prior` 是否标注 `needs_signal_support`。
- `archive/v2/`、`archive/v3/` 等 `portrait_snapshot` 是否有版本目录、manifest 和完整 portrait 文件。
- self 行为原则是否来自用户校正或多条 signals。

### 4. working/tracks 审计

检查 working：

- 是否只记录实时状态（本周活跃、待决定、等待/阻塞、最近完成）。
- 是否混入长期轨道或长期画像。
- 是否超 80 行预算。
- 是否有明显过时事项需要询问用户。

检查 tracks：

- 条目是否为当前状态摘要，是否出现日期补丁式追加（应原地重写）。
- 单条是否超 10 行，全文是否超 200 行。
- 是否混入单次观察/洞察（应归 journal/signals）或稳定画像（应归 portrait）。

### 5. learning 审计

检查 learning：

- overview 日期是否与学科文件一致。
- 学习进度是否仍由 learning 系统维护。
- 是否有学习反馈绕过 signals 直接进入 portrait。

### 6. 汇报与最小修正

先汇报发现的问题，再执行安全的格式修正。涉及实质内容删除、画像重写、声明改动时，先询问用户。

## Git

不要自动提交，除非用户明确要求提交。
