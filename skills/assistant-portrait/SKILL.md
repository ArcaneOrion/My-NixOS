---
name: assistant-portrait
description: 以当前 portrait 和 synthesis-log 基线增量吸收全部证据源，并按事实、显式声明、AI 推断和事件的不同语义执行画像巩固、纠错、合并、降级与遗忘；只维护单一当前画像，历史由 Git 保存；assistant-portrait full 触发全量重综合。
---

# Assistant Portrait

## 定位

`assistant-portrait` 是长期记忆巩固与遗忘系统。它从高质量历史材料中修订当前用户画像与助理行为规则，直接原地维护 `/home/arcaneorion/user-memory/portrait/`。

系统只保留一套当前画像，不创建 `archive/vN` 或其他画像副本。每次成功更新后由 Git commit 保存历史、diff 和恢复入口。

默认使用增量综合：当前 portrait 代表旧综合基线之前的巩固结果，本次读取基线之后的新材料，并逐条审计现有画像是否应保留、强化、重写、合并、降级或遗忘。

## 读取范围

默认读取：

1. `/home/arcaneorion/user-memory/signals/schema.md`
2. `/home/arcaneorion/user-memory/signals/quality-criteria.md`
3. `/home/arcaneorion/user-memory/journal/schema.md`
4. `/home/arcaneorion/user-memory/portrait/` 当前文件全量
5. `/home/arcaneorion/user-memory/working.md` 与 `/home/arcaneorion/user-memory/tracks.md`
6. `/home/arcaneorion/user-memory/learning/overview.md`
7. 综合基线之后新增或修改的 `diary/`、`important_raw/`、`signals/`、`raw/`、`journal/`、`learning/`、`working.md`、`tracks.md`

diary 是主人手写原生数据和 AI 零接触区，只读。默认模式下 diary 与 important_raw 也服从综合基线，不再每次全量重读；如果 `important_raw/INDEX.md` 的标记发生变化，同时读取本次被重新标记的对应材料。

### 综合基线

基线记录在 `portrait/synthesis-log.md` 顶部。开始综合时：

1. 读取旧基线 `OLD_BASELINE`。
2. 执行 `git -C /home/arcaneorion/user-memory rev-parse HEAD`，记录 `NEW_HEAD`。
3. 列出已提交增量：

```text
git -C /home/arcaneorion/user-memory diff --name-only <OLD_BASELINE> <NEW_HEAD> -- diary important_raw signals raw journal learning working.md tracks.md
```

4. 同时检查上述范围内的 staged、unstaged 和 untracked 文件；不能因材料尚未提交而漏读。对每个文件用只读内容哈希形成 `path + content_hash` 指纹。
5. `synthesis-log.md` 的「已综合未提交输入」保存上次已吸收但尚未进入基线 commit 的指纹；同一指纹不重复综合。文件后来以相同内容进入 `NEW_HEAD` 时，该指纹已被 Git 基线覆盖，从表中移除。
6. 综合完成后把基线更新为开始时记录的 `NEW_HEAD`，并更新未提交输入指纹。综合期间出现的新提交进入下一次窗口。

### 全量综合

以下情况执行全量综合：

- 用户明确调用 `assistant-portrait full`。
- synthesis-log 没有有效基线。
- 旧基线 commit 不存在。
- 用户要求重新审计全部历史证据。

全量模式读取 diary/important_raw/signals/raw/journal 全部历史和相关 learning 材料，但仍只写当前 portrait，diary 始终只读。

## 证据判断

不使用单一来源排名机械覆盖。每条证据分别判断：

- **原生性**：是否由主人亲自书写或逐字保留。
- **声明权威性**：是否为主人明确确认、纠正或撤回。
- **时间稳定性**：单次状态、重复模式还是长期声明。
- **事实性**：主观体验、可验证事件、外部事实或 AI 解释。
- **时效与相关性**：是否仍适用于当前画像。

默认规则：

- 用户当前明确纠正的声明权威性最高，可以取代旧声明。
- diary 的用户原生性最高，但单篇日记中的瞬时情绪不自动成为稳定画像。
- signals 的逐轮原文适合恢复上下文；raw 保留完整语境；weekly journal 提供跨会话连续性。
- important_raw 表示用户主动赋予高关注度，但其中其他 AI 的解释仍是 AI 解释。
- learning 和 working/tracks 主要证明当前行为与状态，不自动证明长期核心。
- 医学、神经科学和其他外部机制必须与用户体验分开；无外部依据时只能作为解释假设。

### 画像的两条形成通道

- **主人主动展现**：主人明确陈述、确认、纠正或撤回的价值观、自我定义、使命、边界和长期方向。用户原话就是这类声明成立的主要证据，不要求靠高频行为反复证明。
- **助理合理推断**：助理根据历史事实、跨时间行为、选择、反例和上下文形成的画像判断。必须标为 AI 综合，保留证据、置信度和可反驳边界，不能覆盖主人当前明确声明。

行为事实可以支持、限制或揭示声明与实践之间的张力，但不能单方面替主人改写价值观。

### 内容类型与证据语义

- `stable_fact`：相对稳定的事实。由用户原话、正式资料或可验证记录支持；没有重复出现不等于失效，只有纠正或反证才改写。
- `time_bound_fact`：带时点的当前事实、状态或方向。记录 `as_of`；过期后标为 stale，并转入 working/history 或更新当前值，不把旧值继续当现状。
- `explicit_declaration`：主人主动表达或确认的价值观、自我定义、使命和边界。保留原话；沉默和低频不构成反证，只能由主人后续纠正、撤回或明确替代。
- `inferred_pattern`：助理从多条历史事实形成的行为或认知模式。需要独立样本、置信度和反例边界；可以被强化、降级或撤回。
- `episodic_event`：一次性事件、任务和阶段经历。默认留在 journal；只有改变长期结构时进入 profile-history。
- `assistant_rule`：主人对助理行为的明确要求或由多次错误形成的规则。按 self.md 的严格条件维护。

缺少新证据只表示“近期没有更新”，不等于旧证据为假，也不自动构成遗忘理由。

## 输出文件

只允许直接写入：

- `/home/arcaneorion/user-memory/portrait/self.md`
- `/home/arcaneorion/user-memory/portrait/profile-core.md`
- `/home/arcaneorion/user-memory/portrait/profile-patterns.md`
- `/home/arcaneorion/user-memory/portrait/profile-history.md`
- `/home/arcaneorion/user-memory/portrait/declarations.md`
- `/home/arcaneorion/user-memory/portrait/evidence-index.md`
- `/home/arcaneorion/user-memory/portrait/synthesis-log.md`

不写 `diary/`、`signals/`、`raw/`、`journal/`、`learning/`、`working.md` 或 `tracks.md`。这些文件由各自维护者更新。

## 工作流程

### 1. 确定输入并审计质量

- 按基线机制列出全部增量材料。
- 检查 signals/journal 是否符合各自 schema。
- 区分用户原话、事实、用户声明、外部事实和 AI 推断。
- 检查高频污染、当前声明冲突、来源缺失和未提交材料。
- 质量不足时降低置信度并记录边界，不伪造缺失证据。

### 2. 建立现有节点索引

先扫描当前 portrait 的标题、已有稳定 ID 和主题关键词。没有 ID 的既有条目暂以“文件路径 + 标题”作为迁移键；新建条目，以及本次被重写或合并的条目，逐步补稳定 ID，不要求为迁移而一次性重写全部画像。每条新发现只能进入以下动作之一：

- **强化**：追加新证据或更新最近支持时间。
- **重写**：新证据修正描述，原地替换旧表述。
- **取代**：用户纠正或强反证推翻旧节点，记录取代关系后移除旧正文。
- **合并**：重复节点收敛为一个主节点。
- **降级**：从 core/self/declarations 降为 pattern、history 一句话或仅保留证据索引。
- **遗忘**：从当前 portrait 移除；原始证据和 Git 历史仍保留。
- **新建**：现有节点无法承接且证据足够时才创建。

### 3. 执行巩固与遗忘

每次综合必须同时审计旧画像，不得只追加新内容：

- 单次事件、临时项目、具体岗位和短期任务不进入 profile-core。
- `needs_review` 条目记录首次观察、最近支持和复审日期。30 天是默认复审触发点，不是自动失效期限。
- 复审时按内容类型处理：显式声明和稳定事实不因时间降级；时效事实检查 `as_of`；AI 推断有新证据则强化，有反证则重写或撤回，只有在长期无支持且当前解释价值低时才压缩成一句话或仅保留证据索引。
- 主人明确确认或纠正的价值声明持续有效，直到主人撤回、纠正或用新声明替代；行为不一致只能记录为张力或反例。
- 被新声明取代的旧表述不长期留在当前正文；在 synthesis-log 记录后移除。
- 相同内容在多个文件重复时保留一个主节点，其他位置改为简短引用或删除。
- profile-history 只保留改变长期结构的转折；普通事件压缩为一句话和证据链接，或只留在 journal。
- 与用户画像无关的外部知识、机制长文和阶段性方案退出 portrait。
- 遗忘只作用于当前投影，不删除 diary/signals/raw/journal/learning 等原始证据。

### 4. 写入当前画像

新建或本次重写、合并的画像条目应有稳定 ID，并包含或可在 evidence-index 追溯到：

```markdown
## 条目标题

- ID：pattern.action.external-structure
- 状态：active_ai_generated / user_confirmed / user_corrected / needs_review
- 内容类型：stable_fact / time_bound_fact / explicit_declaration / inferred_pattern / episodic_event / assistant_rule
- 来源类型：current_conversation / diary_raw / important_raw_curated / signal_structured / raw_curated / journal_weekly / journal_compressed / learning_record / working_state / git_history
- 置信度：低 / 中 / 中高 / 高
- 事实时点（as_of）：YYYY-MM-DD / 不适用
- 首次观察：YYYY-MM-DD
- 最近支持：YYYY-MM-DD
- 复审日期：YYYY-MM-DD / 不适用
- 证据：...
- 边界/反证：...
```

`current_conversation` 仅表示证据来自当前会话；必须同时保留日期和用户原话或纠正内容。

状态规则：

- `user_confirmed`：用户明确确认。
- `user_corrected`：用户明确纠正，优先于旧表述。
- `active_ai_generated`：多源证据支持的 AI 综合，仍可纠错。
- `needs_review`：等待复审的 AI 推断或时效事实；到期触发重新判断，不自动删除。
- `deprecated` 只作为本次迁移日志中的过渡状态，不长期保留在当前画像正文。

### 5. 区分画像层级

- `profile-core.md`：当前稳定事实、身份、长期方向和核心世界观。
- `profile-patterns.md`：跨会话复现的认知、学习和行为模式。
- `profile-history.md`：真正改变长期结构的历史转折索引。
- `declarations.md`：用户明确声明及当前有效版本，保留原话和主体性边界。
- `self.md`：助理操作系统；只接受用户明确校正、职责变化或多次重复问题。
- `evidence-index.md`：优先由条目稳定 ID 派生紧凑索引；尚未迁移 ID 的既有条目暂用“文件路径 + 标题”定位，不重复保存大段画像正文。
- `synthesis-log.md`：当前基线、维护日期、最近综合摘要和历史一行索引。

### 6. 更新维护日期

`synthesis-log.md` 顶部维护：

```text
- last_consolidated: YYYY-MM-DD
- next_due: YYYY-MM-DD
- cadence_days: 14
```

成功完成巩固和遗忘审计后，将 `next_due` 设为 14 天后。即使没有新增画像条目，也要记录本次审计结果。

### 7. 汇报

汇报：

- 基线窗口和增量文件。
- 强化、重写、取代、合并、降级、遗忘和新建的节点。
- 高置信度与 needs_review 条目。
- 冲突、反证、证据缺口和高频污染风险。
- 当前画像仍可由用户直接修改、撤回或纠正。

### 8. Git 版本记录

每次成功写入后，在 `/home/arcaneorion/user-memory` 自动提交一次：

1. 先检查 `git status --short`。
2. 只 stage 本次实际修改的 `portrait/*.md`，不使用 `git add .` 或 `git add -A`。
3. 没有变化时跳过提交并汇报。
4. commit message：`巩固用户画像：<主题>`。
5. 不 push，不跳过 hooks。

Git 是画像历史的唯一版本系统。需要回溯时使用 `git log`、`git show` 和 `git diff`，不创建画像副本目录。

## self.md 更新规则

self 是助理操作系统，更新条件比 profile 更严格。允许写入的情况：

1. 用户明确校正助理行为。
2. 多条 signals 显示同类错误反复出现。
3. 用户要求改变助理系统职责。
4. 既有 self 规则与当前记忆架构冲突。

## 禁止事项

- 严禁写入、编辑、删除或重命名 `diary/` 下任何文件。
- 不从单次会话直接写稳定画像。
- 不把 AI 推断写成用户立场。
- 不用高频主题覆盖低频核心命题。
- 不替用户最终定义理想、使命、价值排序或长期身份。
- 不创建 `archive/vN`、`portrait/archive/` 或其他画像副本。
- 不因保留历史而让失效内容长期占据当前 portrait；历史由 Git 和原始证据层保存。
