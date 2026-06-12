---
name: assistant-portrait
description: 默认增量综合：以 synthesis-log 记录的综合基线为界，用 important_raw 和基线后新增的 signals/raw/journal/learning/working 材料修订 portrait/ 用户画像与 assistant self；保留证据链、版本快照、置信度、边界和纠错记录；assistant-portrait full 触发全量重综合。
---

# Assistant Portrait

## 定位

从 `~/.claude/user-memory/` 的高质量历史材料中综合用户画像与助理行为规则，并默认直接写入 `portrait/`。核心目标是用大量真实数据和 AI 综合能力生成可演化的数字画像，而不是把画像更新变成繁琐审批流。

默认增量综合：当前 portrait 被视为基线之前全部历史材料的综合结果，每次只用基线之后的新材料修订画像，不重放历史。

画像写入不是最终定稿；每条内容都必须保留来源类型、证据链、置信度、边界和状态，方便后续审计、纠错、降级或删除。每次写入新画像前，必须先把当前 `portrait/` 归档到 `archive/`，形成 v1/v2/v3... 的历史画像序列。

## 读取范围

默认增量读取：信任当前 portrait，只重读综合基线之后的新材料。读取：

1. `~/.claude/user-memory/signals/schema.md`
2. `~/.claude/user-memory/signals/quality-criteria.md`
3. `~/.claude/user-memory/journal/schema.md`
4. `~/.claude/user-memory/archive/schema.md`
5. `~/.claude/user-memory/portrait/` 全量（self、profile 三件、declarations、evidence-index、synthesis-log）
6. `~/.claude/user-memory/working.md`
7. `~/.claude/user-memory/learning/overview.md` 与相关学科文件
8. `~/.claude/user-memory/important_raw/` 全量，作为 `important_raw_curated`，最高权重；体积小且为用户主动标记层，不参与增量裁剪
9. 综合基线之后新增或修改的 `signals/` 文件，作为 `signal_structured`
10. 综合基线之后新增或修改的 `raw/` 文件，作为 `raw_curated`
11. 综合基线之后新增或修改的 `journal/YYYY-Www.md`，作为 `journal_weekly`；历史月度 `journal/YYYY-MM.md` 为 `journal_compressed`，只在全量综合时读取
12. `archive/` 最近两个 `portrait_snapshot` 版本目录（vN 与 vN-1，含 manifest），用于版本连续性；更早快照与 `archive/v1/` legacy prior 默认不读

### 综合基线机制

- 基线记录在 `portrait/synthesis-log.md` 顶部「当前综合基线」：一个 `~/.claude/user-memory` 仓库 commit hash 加日期。
- 综合开始时先执行 `git -C ~/.claude/user-memory rev-parse HEAD` 记下本次新基线 `NEW_HEAD`，再列出增量材料：

```text
git -C ~/.claude/user-memory diff --name-only <旧基线> <NEW_HEAD> -- signals raw journal learning working.md
```

- 列出的文件全部读取，不按"重要性"二次裁剪增量集。
- 综合完成后把「当前综合基线」更新为 `NEW_HEAD`。综合期间其他 skill 新提交的材料会落入下一次增量窗口，不会丢失。

### 全量综合

只在以下情况执行全量综合（读取 important_raw/signals/raw/journal 全部历史；archive 仍只读最近两个版本）：

- 用户明确调用 `assistant-portrait full` 或要求全量重综合。
- `synthesis-log.md` 找不到「当前综合基线」。
- 旧基线 commit 不存在于 git 历史。

读取时不要追求“纯净数据源”，而要保留来源类型、证据权重和置信度。旧 journal 不需要回改为新 schema。archive 既保存旧系统先验，也保存每次 portrait 更新前的历史画像版本。

## 输出文件

允许直接写入：

- `~/.claude/user-memory/portrait/self.md`
- `~/.claude/user-memory/portrait/profile-core.md`
- `~/.claude/user-memory/portrait/profile-patterns.md`
- `~/.claude/user-memory/portrait/profile-history.md`
- `~/.claude/user-memory/portrait/declarations.md`
- `~/.claude/user-memory/portrait/evidence-index.md`
- `~/.claude/user-memory/portrait/synthesis-log.md`
- `~/.claude/user-memory/archive/vN/`

不要写入 `signals/`；signals 由 `assistant-remember full` 维护。不要写入 `learning/`；learning 由 `assistant-learn` 和 `assistant-review` 维护。

## 工作流程

### 1. 确定综合范围

按「读取范围」的增量规则确定本次输入：

- 读取 synthesis-log 顶部旧基线，记录 `NEW_HEAD`，用 git diff 列出基线后新增或修改的 signals/raw/journal/learning/working.md 文件，全部读取。
- 用户可以指定只综合某个主题或时间段，也可以调用 `assistant-portrait full` 全量重综合；默认不裁剪增量集。
- `important_raw/` 是用户主动标记的最高权重原始材料层，标记为 `important_raw_curated`，每次全量读取；其权重高于 `signals/`、`raw/`、`journal_weekly`、`working_state` 和 `archive`。它通常保存用户认为具有核心画像价值、人生哲学、价值排序、长期身份叙事、重大校正或高强度原话证据的材料。
- `important_raw/` 可以支持高置信度写入 `declarations.md`、`profile-core.md`、`profile-patterns.md` 或 `self.md`，但仍必须区分用户原话、用户确认、其他 AI 推断和当前助理综合；不得把其他 AI 的解释直接写成用户立场。
- `signals/`、`raw/` 和 `journal_weekly` 都是强证据：signals 有 full 模式下的逐轮用户原文、助理摘要和结构化标注，raw 高保真，weekly journal 有默认跨会话连续性。不能因为某次会话没有 signal 就忽略对应 journal-only 记录。
- 当前 `portrait/` 全量读取：增量综合的本质是用新证据修订既有画像，不是重新生成。修订时遵守既有条目状态机——`user_confirmed` / `user_corrected` 条目不得被单次 AI 推断覆盖或降级。
- `archive/` 最近两个 `portrait_snapshot` 版本用于理解最近的画像演化和回溯，不自动覆盖当前 portrait；`archive/v1/` legacy prior 与更早快照只在全量综合或用户要求版本对比时读取。
- 多次综合差异审计默认关闭，用户明确要求时开启。

如果单次增量材料过大，先列出文件索引和主题，再按主题分批综合；`important_raw/` 必须优先读取，不得因已有 signals 或 journal 摘要而跳过。

### 2. 审计输入质量

在综合前检查：

- signals 是否符合 `schema.md`
- journal 是否符合 `journal/schema.md`
- archive 是否符合 `archive/schema.md`
- important_raw 是否保留足够上下文，是否能区分用户原话、用户确认、用户校正、网页端 AI 推断和当前助理综合
- 是否混淆事实、声明、AI 推断
- 是否逐轮保留用户原文，是否用二次摘要替代了用户原话
- 是否存在高频污染风险
- 是否把 AI 推断写成用户立场
- 是否与 `declarations.md` 既有条目冲突

质量不足时，不要停止画像更新；应降低置信度、标明边界，并在 `evidence-index.md` 或 `synthesis-log.md` 记录缺口。

### 3. 归档当前 portrait

在写入新 `portrait/` 前，必须先按 `archive/schema.md` 归档当前 `portrait/`：

1. 计算下一个版本号：取 `archive/` 下已有 `vN/` 目录的最大 N + 1。
2. `archive/v1/` 保留旧系统迁移快照；第一次归档当前 `portrait/` 时创建 `archive/v2/`。
3. 复制当前 portrait 关键文件到 `archive/vN/`：
   - `self.md`
   - `profile-core.md`
   - `profile-patterns.md`
   - `profile-history.md`
   - `declarations.md`
   - `evidence-index.md`
   - `synthesis-log.md`
4. 写入 `manifest.md`，记录版本号、归档时间、归档原因、来源文件和上一版本。
5. 在本次 `synthesis-log.md` 记录归档目录。

如果当前 `portrait/` 仍是空骨架，也要归档，并在 manifest 中标注 `notes: transitional skeleton`。不要因为它不完整而跳过版本记录。

### 4. 直接生成并写入 portrait

按目标文件分组生成画像条目，并直接写入对应文件。每条写入必须包含或可在 `evidence-index.md` 追溯到：

```markdown
## 条目标题

- 状态：active_ai_generated / user_confirmed / user_corrected / needs_review / deprecated
- 来源类型：important_raw_curated / signal_structured / raw_curated / journal_weekly / journal_compressed / learning_record / working_state / legacy_prior / portrait_snapshot
- 置信度：低 / 中 / 中高 / 高
- 证据：
  - important_raw/YYYY-MM-DD-topic.md#section
  - signals/YYYY-MM/YYYY-MM-DD-topic.md#section
  - raw/YYYY-MM-DD-topic.md#section
  - archive/vN/file.md#section
- 边界/反证：...
- 最近审计：YYYY-MM-DD

画像内容...
```

写入原则：

- 高置信度条目可写入为 `active_ai_generated`。
- 用户明确确认过的条目标为 `user_confirmed`。
- 用户纠正过的条目标为 `user_corrected`，并记录旧表述如何被替换。
- 证据不足但值得观察的条目可写入 `needs_review`，不得伪装成稳定事实。
- 旧条目被推翻时标为 `deprecated`，不要静默删除证据链。

### 5. 区分画像层级

按以下规则处理：

- `profile-core.md`：稳定事实、身份、长期方向；必须有强证据或明确标注为低权重 legacy prior。
- `profile-patterns.md`：认知模式、学习偏好、行为模式；需要多条证据或明确写为 `needs_review`。
- `profile-history.md`：历史决策和长期观察；保留时间、来源和解释层级。
- `declarations.md`：理想、使命、核心命题、座右铭、价值排序、关系边界、长期身份叙事；可以直接写入，但必须保留用户原话、来源、状态和主体性边界。
- `self.md`：助理行为原则和角色定位；写入条件比 profile 更严格，必须来自用户明确校正、系统职责变化，或多条 signals 支持的反复行为问题。

### 6. 写入后汇报与纠错入口

写入完成后，向用户简短汇报：

- 本次综合基线窗口（旧基线 → 新基线）与增量文件清单。
- 归档了哪个 archive 版本目录。
- 写入了哪些 portrait 文件。
- 哪些条目是高置信度，哪些是 `needs_review`。
- 哪些条目来自 important_raw/raw/signals/weekly journal/历史 journal/archive。
- 是否发现冲突、反证或高频污染风险。
- 用户可以直接要求修改、降级、删除、恢复或确认某条画像。

不要在写入前把所有内容变成审批清单；只有当存在会覆盖核心声明、删除大量既有画像、或用户明确要求先看草稿时，才先展示草稿。

### 7. 更新索引和日志

每次写入后：

1. 更新对应 `portrait/*.md` 文件。
2. 更新 `portrait/evidence-index.md`，记录证据链、状态、反证和 archive 版本来源。
3. 更新 `portrait/synthesis-log.md`，记录本次输入范围、归档目录、权重、写入结果、降级/删除、后续疑问。
4. 把 `synthesis-log.md` 顶部「当前综合基线」更新为本次综合开始时记录的 `NEW_HEAD` 和日期。

### 8. Git 版本记录

每次成功写入 portrait 和 archive 后，必须在 `~/.claude/user-memory` 仓库自动提交一次版本记录，不再额外询问。

提交规则：

1. 只在 `~/.claude/user-memory` 内执行 git 操作，使用 `git -C ~/.claude/user-memory ...`，不要影响当前项目仓库。
2. 先运行 `git -C ~/.claude/user-memory status --short` 确认变更。
3. 只 stage 本次 `assistant-portrait` 实际写入或修改的文件，例如：
   - `portrait/self.md`
   - `portrait/profile-core.md`
   - `portrait/profile-patterns.md`
   - `portrait/profile-history.md`
   - `portrait/declarations.md`
   - `portrait/evidence-index.md`
   - `portrait/synthesis-log.md`
   - `archive/vN/manifest.md`
   - `archive/vN/self.md`
   - `archive/vN/profile-core.md`
   - `archive/vN/profile-patterns.md`
   - `archive/vN/profile-history.md`
   - `archive/vN/declarations.md`
   - `archive/vN/evidence-index.md`
   - `archive/vN/synthesis-log.md`
4. 不使用 `git add .` 或 `git add -A`。
5. 如果没有变更，跳过提交并汇报“无变更可提交”。
6. commit message 使用中文，格式建议：

```text
更新用户画像：<综合主题>
```

7. 使用 heredoc 传递提交信息。
8. 不 push。
9. 不跳过 hooks；如果 commit 失败，说明原因并保留未提交状态。

## archive 规则

`archive/` 是历史画像版本库，不只是旧系统兼容目录。

来源类型分两类：

```text
source_type: legacy_prior
status: needs_signal_support
```

用于旧系统迁移快照，权重低，不自动继承。

```text
source_type: portrait_snapshot
status: archived_snapshot
```

用于每次 portrait 更新前冻结的历史画像版本，保留画像演化轨迹。portrait_snapshot 可用于回溯、版本比较和解释变化，但不自动覆盖当前 portrait。

不要把 legacy prior 或 portrait snapshot 自动复制成当前画像；如需迁移条目，必须在 `evidence-index.md` 标注来源版本、证据状态和迁移原因。

## self.md 更新规则

self 是助理操作系统，更新条件更严格。

允许直接写入 self 的情况：

1. 用户明确校正助理行为。
2. 多条 signals 显示助理同类错误反复出现。
3. 用户要求改变助理系统职责。
4. 既有 self 规则与当前 portrait 架构冲突，需要迁移或降级。

行为原则写入后必须可追溯、可纠错，不得用单次弱推断改写助理长期操作系统。

## 多次综合差异审计

默认关闭。用户明确要求时，对同一批数据生成多份综合结果并比较差异：

- 多次输出一致：提高置信度。
- 多次输出差异大：标记为证据不足或解释不稳定。

## 禁止事项

- 不从单次会话直接写稳定画像；单次信号只能写为 `needs_review` 或明确低置信度。
- 不把 AI 推断写成用户立场。
- 不用高频主题覆盖低频核心命题。
- 不替用户最终定义理想、使命、价值排序或身份结论；声明层写入必须保留用户原话和可纠错状态。
- 不因追求流程安全而阻塞画像生成；质量控制依靠证据链、置信度、状态、版本快照和后续审计。
- 不在生成新 portrait 前跳过 archive 版本归档。
- 不在增量模式下重读基线之前的 signals/raw/journal 或 archive 全量；追溯历史用 `assistant-portrait full` 或用户明确要求的版本对比。
