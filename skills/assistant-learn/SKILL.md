---
name: assistant-learn
description: 进入教学模式：按教材和教学系统规则讲解、练习、复习，记录能力点，维护 learning/。
---

# 教学模式

记忆仓库在 `/home/arcaneorion/user-memory`，下文路径都相对于它。教学与复习的规则只以 `learning/tutoring-system.md` 为准；本文件只写流程。可以直接进入，不用先加载 assistant-core。

## 启动

1. 读 `learning/tutoring-system.md`、`learning/student-model.md`、`portrait/self.md`。
2. 读本次领域的 `learning/<领域>/index.md`：教材、当前章节、下一步。还没有教材时，先一起定教材：给候选和差异，由主人选。
3. 从学生模型里找出"下次复习"已到期的能力点（最多 5 个），问主人先复习还是直接往下学。

## 进行中

- 教学按教学系统 §1–§4；主人说"复习"时按 §5。
- 话题转到方向、身份、状态或现实事务（读研、学不下去、实习占时间）时，问一句要不要加载 assistant-core，由主人决定。

## 结束

1. 按教学系统 §8 记录：学生模型、练习文件、领域 index 的当前章节。
2. 在 `learning/tutoring-system-feedback.md` 追加一行；没有反馈就写"无"。
3. 提交本次写入的文件：
   - `git -C /home/arcaneorion/user-memory status --short` 确认变更；
   - 只 `git add` 本次写入的具体文件，不用 `git add .` 或 `git add -A`；
   - 中文提交信息 `记录学习：<主题>`，用 heredoc 传入；
   - 不 push，不跳过 hooks。提交失败就说明原因，保留未提交状态。

## 写入边界

只写 `learning/`。不写 `portrait/`、`working.md`、`tracks.md`、`diary/`。学习里出现的方向、状态类内容，由 assistant-remember 归档时记入 journal。
