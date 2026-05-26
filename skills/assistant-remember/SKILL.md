---
name: assistant-remember
description: 将当前会话整理为高质量逐轮 session signal，并同步写入周级 journal 跨会话摘要；按需实时维护 working.md，不直接写入 profile/self 画像文件。
---

# 会话信号记录

## 定位

从当前对话中提取可审计信号，写入 `~/.claude/user-memory/signals/`，并同步追加到周级 `journal/`。记录证据，不生成画像；画像更新交给 `assistant-portrait`。

- `signals/` 是会话级逐轮标注数据：一场会话一个文件，按时间顺序一比一记录用户每条实质消息原文，并为对应助理回答写摘要。
- `signals/` 的第一层是原始对话顺序与用户原文，第二层才是 L1/L2/L3 标注、反证和 portrait 更新提示；不得用二次总结替代用户原话。
- `journal/` 是周级跨会话摘要：每个被记录的会话都追加一条，按时间和主题串联多会话变化；journal 不承担逐字转录职责。
- 二者都是画像生成的重要数据源，区别在保真度、时间尺度和组织方式。

## 读取文件

开始前读取：

1. `~/.claude/user-memory/signals/schema.md`
2. `~/.claude/user-memory/signals/quality-criteria.md`
3. `~/.claude/user-memory/journal/schema.md`
4. 当前 ISO 周的 `~/.claude/user-memory/journal/YYYY-Www.md`（不存在则创建）
5. `~/.claude/user-memory/working.md`
6. `~/.claude/user-memory/portrait/declarations.md`（避免误把既有声明重复写入）
7. `~/.claude/user-memory/portrait/evidence-index.md`（按需，避免重复画像更新提示）

不要默认读取全部 portrait；只在判断重复或引用既有画像时按需读取。

## 写入范围

每次归档当前会话时，必须同时写入：

- `~/.claude/user-memory/signals/YYYY-MM/YYYY-MM-DD-topic.md`
- `~/.claude/user-memory/journal/YYYY-Www.md`

按需写入：

- `~/.claude/user-memory/working.md`
- `~/.claude/user-memory/raw/YYYY-MM-DD-topic.md`（仅用户明确同意后）

禁止直接写入：

- `portrait/profile-core.md`
- `portrait/profile-patterns.md`
- `portrait/profile-history.md`
- `portrait/self.md`
- `portrait/declarations.md`
- 旧根目录 `profile*.md` / `self.md`

## 写入判断

`assistant-remember` 被调用时，默认当前会话需要归档。除非用户明确说不要记录，或本次对话完全没有可保存内容，否则应写入 signal 和 journal。

优先归档以下会话：

- 用户明确要求记忆、归档、整理本次会话。
- 用户校正助理行为。
- 出现新的系统设计、长期声明、边界或价值判断。
- 出现重要学习反馈。
- 做出路径选择或撤回旧判断。
- 产生可用于画像建模的高质量反例。
- 发生连续问答、方案比较、代码/文件变更、学习推进等可形成历史轨迹的内容。

## 工作流程

### 1. 确定 session signal 文件名

使用：

```text
~/.claude/user-memory/signals/YYYY-MM/YYYY-MM-DD-topic.md
```

一次会话一个文件；不要按日合并多个主题。`topic` 用 2-5 个英文或拼音短词表达主主题。

### 2. 按顺序写 session signal

signal 必须包含当前会话的逐轮标注记录：

- 用户每条实质消息必须按出现顺序逐字记录原文，不合并、不改写、不用摘要替代。
- 助理对应回答写摘要即可；除非用户要求或对审计必要，不需要逐字记录助理全文。
- 用户原文很长时仍优先逐字保留；如果因上下文压缩、平台截断或不可恢复导致无法完整记录，必须把 signal 状态标为 `partial` 或 `needs_user_review`，并在对应轮次写明缺失边界和原因。
- 工具或文件变更结果按事实摘要记录。
- 对后续画像有意义的事实、声明、推断、边界和反证放在后续标注层，必须能回指具体 turn，不替代逐轮原文层。

不要只摘录“看起来重要”的片段而丢失会话顺序；关键原话摘录只能作为索引或复用，不是 signal 的主数据。

### 3. 按 schema 标注

必须包含：

- 会话主题
- 逐轮用户原文与助理摘要
- 关键用户原话索引（可选，用于引用，不替代逐轮原文）
- 用户明示问题与约束
- 事件事实 L1
- 显式声明 L3（如有）
- 助理回答摘要
- AI 推断 L2（如有，必须带置信度和边界）
- 反证、冲突与未决问题
- portrait 更新提示（如有）
- working 更新提示（如有）

### 4. 追加周级 journal

写入或更新当前 ISO 周文件：

```text
~/.claude/user-memory/journal/YYYY-Www.md
```

journal 每个被记录的会话都写一条，按时间顺序追加。它是跨会话摘要，不是 signals 的简化替代。

每条 journal entry 应包含：

- 时间和主题。
- 本次会话的核心问题链。
- 用户做出的修正、选择、确认或撤回。
- 助理给出的主要回答或实际处理摘要。
- 产生或修改的文件。
- 与前后会话的连接。
- 后续状态或未决问题。
- 对应 signal 文件路径。

### 5. 维护 working.md

如果本次会话改变了实时状态，更新 `working.md`：

- 新增进行中事项。
- 更新阻塞/等待。
- 记录最近完成。
- 移除或改写明显过时的实时状态。

只维护状态，不把长期画像写入 working。

### 6. raw 例外存档

只有当对话属于重大决策、核心命题、深度认知框架，且用户明确同意时，才写入 `raw/`。

### 7. 汇报结果

汇报写入了哪些文件：

- signal 文件。
- journal 周记录。
- working/raw（如有）。

说明哪些内容只是 portrait 更新提示，未直接进入 portrait。

## Journal 周记录格式

按 `~/.claude/user-memory/journal/schema.md` 写入 weekly journal。

同一周内按时间顺序追加，不覆盖旧 entry。历史月度 journal 不回改，新记录从周级格式开始迭代。

## 标注规则

- 逐轮保留用户每条实质消息原文，尤其是声明、边界、修正和关键问题；不能只保留摘录。
- 按会话顺序记录用户原文与助理回答摘要，用户原文不合并、不改写、不摘要化。
- 区分事实、声明、AI 推断。
- AI 推断必须有置信度、证据、边界。
- 不把 AI 推断写成用户立场。
- 不使用“正确、深刻、重要、优雅”等评价词。
- 不因单次会话生成稳定画像。

## Git

每次成功写入 signal、journal、working 或 raw 后，必须在 `~/.claude/user-memory` 仓库自动提交一次版本记录，不再额外询问。

提交规则：

1. 只在 `~/.claude/user-memory` 内执行 git 操作，使用 `git -C ~/.claude/user-memory ...`，不要影响当前项目仓库。
2. 先运行 `git -C ~/.claude/user-memory status --short` 确认变更。
3. 只 stage 本次 `assistant-remember` 实际写入或修改的文件，例如：
   - `signals/YYYY-MM/YYYY-MM-DD-topic.md`
   - `journal/YYYY-Www.md`
   - `working.md`
   - `raw/YYYY-MM-DD-topic.md`（如本次写入）
4. 不使用 `git add .` 或 `git add -A`。
5. 如果没有变更，跳过提交并汇报“无变更可提交”。
6. commit message 使用中文，格式建议：

```text
记录会话信号：<会话主题>
```

7. 使用 heredoc 传递提交信息。
8. 不 push。
9. 不跳过 hooks；如果 commit 失败，说明原因并保留未提交状态。
