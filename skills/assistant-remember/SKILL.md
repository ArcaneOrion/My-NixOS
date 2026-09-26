---
name: assistant-remember
description: 把当前会话归档到记忆仓库：写周级 journal、corpus 原话与 facts，按需更新 working.md 和 tracks.md；assistant-remember full 另写逐轮 signal。不写画像。
---

# 会话归档

记忆仓库在 `/home/arcaneorion/user-memory`，下文路径都相对于它。被调用就归档，除非主人说不记，或会话里没有可保存的内容。按 `portrait/self.md` 的职责只记交流、分析、学习、个人处境和对助理的校正；项目执行流水、部署、账号、投递和工作待办不记。

## 写入前读

1. `schema/memory-contract.md`：所有写入按它打归属标记，拿不准就标〔AI〕。
2. `journal/schema.md` 和当前 ISO 周的 `journal/YYYY-Www.md`（没有就新建）。
3. `working.md`、`tracks.md`。
4. full 模式另读 `signals/schema.md`、`signals/quality-criteria.md`。
5. 担心重复写入已有声明时，查 `portrait/declarations.md`。

## 每次都写

1. **journal**：在当前周文件末尾追加一条 entry，字段按 `journal/schema.md`，本周概览随之更新。默认 `record_mode：journal_only`、`signal：无（journal-only）`。需要进画像的内容写在 entry 的后续状态里，交给 assistant-portrait。
2. **corpus**：主人每条消息逐字进 `corpus/YYYY-MM.md`。
   - Claude Code 会话：先预览 `~/.local/bin/uv run --no-project python tools/corpus_export.py --topic "<主题>"`，没问题再加 `--write`。脚本只追加上次导出之后的消息，按上海时间分月，接续 T 编号。
   - 脚本提示的长消息，检查里面有没有外部粘贴（清单、转发、其他 AI 的输出）；有就把粘贴部分换成 `[外部粘贴：内容摘要 + 字数]`，主人自己写的引导句保留。
   - 其他平台的会话按 `corpus/README.md` 手工转录。
3. **facts**：本次会话里发生的事写进 `facts/YYYY-MM.md` 当日小节，规则见 `facts/README.md`：记发生、不记意义，每行一条，恰好一个标记（〔痕〕〔报〕〔决〕〔档〕）。没有就不写。

## 按需写

- `working.md`：两周内会变的状态（正在进行、待定、最近校正）。原地改写，删掉过期项，不打日期补丁；≤ 80 行。
- `tracks.md`：跨月的学习、兴趣、生活线索，只写当前状态；每条 ≤ 10 行，全文 ≤ 200 行。
- 单次观察、洞察和讨论过程只进 journal，不进 working、tracks。
- `fitness.md`：主人报告锻炼时。
- `arcane-training.md`：本次有 arcane 事件时，只更新周级状态。
- `raw/YYYY-MM-DD-topic.md`：重大对话，且主人同意时。

## full 模式

`assistant-remember full` 另写 `signals/YYYY-MM/YYYY-MM-DD-topic.md`，格式按 `signals/schema.md`：

- 主人每条实质消息按顺序逐字记录，不合并、不改写；助理的回答写摘要。
- 原文缺失（上下文压缩、截断）时标 `partial`，写明缺失的范围。
- journal entry 写 `record_mode：full_signal` 和 signal 路径。

## 不写

- `portrait/` 下的文件，由 assistant-portrait 维护。
- `diary/`：不创建、编辑、删除、重命名。`git status` 显示有主人写好但未提交的日记时，原样单独提交，信息 `提交日记：<日期>（主人手写，未改动内容）`。

## 提交

1. `git -C /home/arcaneorion/user-memory status --short` 确认变更。
2. 只 `git add` 本次写入的具体文件，不用 `git add .` 或 `git add -A`。
3. 中文提交信息，用 heredoc 传入：`记录周记：<主题>`；full 模式用 `记录会话信号：<主题>`。
4. 不 push，不跳过 hooks。提交失败就说明原因，保留未提交状态。

## 汇报

列出写入的文件：journal entry、corpus 条数、facts 条数、signal（full）、working、tracks 等；说明留给画像的内容还没进画像。
