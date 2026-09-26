---
name: assistant-portrait
description: 维护主人画像：从上次综合基线以来的证据增量巩固、改写、合并与遗忘 portrait/；assistant-portrait audit 检查记忆仓库的结构、链接与写入边界；assistant-portrait full 全量重综合。
---

# 画像维护

记忆仓库在 `/home/arcaneorion/user-memory`，下文路径都相对于它。只维护一套当前画像 `portrait/`，历史只靠 Git，不建画像副本目录（如 archive）。

## 读

1. `schema/memory-contract.md`。读到的〔AI〕是过去的判断，可以推翻、重写或撤回，不当成主人的立场。
2. `portrait/` 全部文件，`working.md`、`tracks.md`、`learning/overview.md`。
3. 增量。`portrait/synthesis-log.md` 顶部记着基线 commit（下称 OLD）：
   - `git -C /home/arcaneorion/user-memory rev-parse HEAD` 记为 NEW；
   - `git -C /home/arcaneorion/user-memory diff --name-only OLD NEW -- diary important_raw signals raw journal corpus facts learning working.md tracks.md`；
   - 再用 `git status --short` 找这些范围里未提交、未跟踪的文件，一并读。上次读过的未提交文件记在 synthesis-log 的「已综合未提交输入」（路径 + sha256），内容没变就跳过。
4. diary 只读。important_raw 里其他 AI 说的话仍算那个 AI 的。

主人调用 `assistant-portrait full`，或基线缺失、基线 commit 不存在时，读全部历史输入。

## 判断证据

| 类型 | 何时成立 | 怎样变化 |
|---|---|---|
| stable_fact | 主人原话、正式资料、可核记录 | 只有纠正或反证才改 |
| time_bound_fact | 同上，带 as_of | 过期就更新当前值，或移出当前画像 |
| explicit_declaration | 主人明确表达或确认 | 沉默不是反证；只有主人撤回、纠正或替代才改 |
| inferred_pattern | 多个独立样本 | 标〔AI〕，写反例；可强化、降级、撤回 |
| episodic_event | 一次性事件 | 留在 journal；改变长期结构的才进 profile-history |
| assistant_rule | 主人明确要求，或同类错误多次出现 | 按下面 self.md 的条件 |

- 当前会话里主人的明确纠正优先于旧记录。
- 同一件事被 diary、signal、journal、corpus、facts 或几个模型重复记录，只算一个样本。
- 没有新证据只说明近期没更新，不是遗忘的理由。
- 医学、神经科学等外部机制与主人的体验分开写；没有外部依据的只能当假设。

## 对每个节点做一个动作

强化（补证据）、重写、取代（主人纠正时记下取代关系，删旧正文）、合并、降级、遗忘（只从当前画像移除，原始证据不删）、新建（证据足够且没有节点能承接时）。每次都要审计旧节点，不能只追加。

## 各文件写什么

- `portrait/profile-core.md`：当前事实、身份、长期方向；每节首行写证据状态，条末打标记。
- `portrait/declarations.md`：主人的声明。每节写日期与标记、逐字原话；"背景""边界""取代"各行单独打标记（助理的判断标〔AI〕），再加依据链接。
- `portrait/profile-patterns.md`：AI 的可推翻观察，全文件〔AI〕；每条写依据原话、做法、反例。
- `portrait/profile-history.md`：改变长期结构的转折，一条一两行。
- `portrait/self.md`：助理规则，只写怎么做。只在主人明确校正、职责变化、同类错误多次出现，或规则与记忆结构冲突时改。
- `portrait/evidence-index.md`：每个锚点一个节点，字段为主节点、内容类型、状态、置信度、as_of、首次观察、最近支持、复审日期、来源类型、证据（S 编号）、边界/反证、措辞整理；新来源加进「来源目录」。
- `portrait/synthesis-log.md`：顶部写基线和维护节奏，每次处理追加一段摘要。

原话逐字保留；综合表述不能丢掉会改变范围的限定；锚点 ID 保持稳定，改名时留兼容别名。

## 收尾

1. 更新 synthesis-log：基线改为开始时记下的 NEW，`last_consolidated` 为今天，`next_due` 为 14 天后，记下读过的未提交输入。
2. 运行 `~/.local/bin/uv run --no-project python tools/check.py`，有问题先修。
3. 提交：
   - `git -C /home/arcaneorion/user-memory status --short` 确认变更；
   - 只 `git add` 本次改过的具体文件，不用 `git add .` 或 `git add -A`；
   - 中文提交信息 `巩固用户画像：<主题>`，用 heredoc 传入；
   - 不 push，不跳过 hooks。提交失败就说明原因，保留未提交状态。
4. 汇报：基线窗口和读过的增量文件；各动作涉及的节点；冲突、反证和证据缺口。

## audit 模式

`assistant-portrait audit` 只检查，不综合：

1. 运行 `tools/check.py`：锚点链接、working 与 tracks 的预算和标记、画像副本目录、diary 改动、基线 commit。
2. 再逐项看：
   - portrait 的每个锚点在 evidence-index 里有节点；
   - declarations 每节有原话和依据；
   - 〔AI〕内容没有写成主人的立场；
   - working、tracks 有没有过期项，有没有工作流水、项目运维回到常驻文件；
   - 各学习领域 index 的教材与当前章节，和学生模型对得上。
3. 先汇报。格式、链接这类问题直接修；删除内容、改写判断或声明，先问主人。
4. 有修改时按上面的方式提交，信息 `整理记忆：<主题>`。

## 不做

- 不写 `diary/`：不创建、编辑、删除、重命名。
- 不从单次会话生成稳定画像；不用高频话题覆盖低频的核心声明。
- 不把 AI 推断写成主人的立场。
- 不替主人定义理想、使命、价值排序和身份。
