---
name: assistant-review
description: 基于遗忘曲线和知识重联进行复习，维护 learning/ 复习记录，并把画像相关反馈交由 signals 管道处理。
---

# 复习系统

## 定位

执行间隔复习和知识重联，维护 `learning/` 中的复习记录。不要直接写入 `portrait/`。

## 启动步骤

1. 读取 `/home/arcaneorion/user-memory/portrait/self.md`。
2. 读取 `/home/arcaneorion/user-memory/portrait/profile-patterns.md`（如当前 portrait 信息不足，则低权重读取 archive 最新 portrait 快照，不再读取根目录旧画像）。
3. 读取 `/home/arcaneorion/user-memory/learning/overview.md`。
4. 读取相关学科文件。
5. 识别需要复习的内容。
6. 展示今日复习建议，询问要复习哪个，或是否全部过一遍。

## 写入范围

允许写入：

- `/home/arcaneorion/user-memory/learning/`

不要直接写入：

- `portrait/`
- `signals/`
- `working.md`

如果复习中产生画像相关反馈，建议后续调用 `assistant-remember` 写入 signals。

## 复习机制

使用简化 SM-2 间隔：

| 回忆效果 | 下次间隔倍数 | 说明 |
|---|---:|---|
| 完全回忆，轻松 | ×2.5 | 记忆稳固 |
| 回忆起来但费力 | ×1.5 | 需要加强 |
| 模糊/部分回忆 | ×1.0 | 保持当前间隔 |
| 完全想不起 | →1天 | 重置 |

## 知识重联流程

1. 构造跨域问题，不只问定义。
2. 等用户先回答。
3. 审计旧知识提取质量和跨域连接深度。
4. 补充关键缺口。
5. 更新复习记录。

## 复习记录格式

在学科文件中维护：

```markdown
## 复习记录

| 知识点 | 上次复习 | 间隔 | 效果 | 连接到 | 下次复习 |
|---|---|---:|---:|---|---|
| ... | ... | ... | ... | ... | ... |
```

效果评分 1-5：1 表示完全想不起，5 表示轻松回忆且产生新连接。

## 轻量复习

用户说“快速复习”时：

1. 选择 3-5 个关键概念。
2. 串成一个跨域问题。
3. 引导用户回答。
4. 记录整体印象，不逐条评分。

## 会话结束

1. 更新复习记录。
2. 更新 `learning/overview.md`。
3. 如果产生画像相关反馈，提示可用 `assistant-remember` 写 signals。

## 原则

- 重联优先。
- 提取优先。
- 跨域连接。
- 效果诚实。
- 负担可控。
- 不把复习反馈绕过 signals 直接写入 portrait。

## Git

不要自动提交，除非用户明确要求提交。
