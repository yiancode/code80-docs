---
description: Claude Code 快捷键与高频交互速查，涵盖常用按键、slash commands 和长会话操作建议
---

# Claude Code 快捷键

Claude Code 的交互快捷键和 slash commands 相对完整，适合长期在终端里高频协作。这一页汇总最常用的一组操作，方便随手查阅。

## 常用快捷键

| 场景 | 快捷键 / 操作 | 说明 |
|------|---------------|------|
| 取消当前步骤 | `Ctrl+C` | 中断当前生成或正在执行的步骤 |
| 退出当前会话 | `Ctrl+D` | 结束当前 Claude Code 会话 |
| 清屏 | `Ctrl+L` | 清空当前终端显示，保留上下文 |
| 历史输入 | 上 / 下箭头 | 复用之前输入过的内容 |
| 多行输入 | `Option+Enter`、`Shift+Enter`、`Ctrl+J`，或输入 `\\` 后回车 | 适合组织更长的 prompt |
| 切换执行模式 | `Shift+Tab` | 在不同 permission mode 间切换 |
| 编辑上一条消息 | `Esc` 再 `Esc` | 快速回到上一条输入内容继续修改 |

## 最常用的 Slash Commands

除了快捷键，Claude Code 最高频的一组操作通常在会话内完成：

| 命令 | 作用 |
|------|------|
| `/help` | 查看当前可用命令 |
| `/clear` | 清空当前对话历史 |
| `/compact` | 压缩当前上下文，减少 token 占用 |
| `/config` | 查看或修改配置 |
| `/mcp` | 管理 MCP 连接 |
| `/memory` | 编辑项目记忆文件 |
| `/model` | 切换模型 |
| `/permissions` | 查看或调整权限模式 |
| `/review` | 发起代码审查 |
| `/terminal-setup` | 配置更顺手的终端输入体验 |
| `/vim` | 进入 vim 风格输入模式 |

## 高频入口命令

```bash
claude
/help
/compact
/review
/mcp
```

对应场景如下：

- `claude`：进入交互模式
- `/help`：快速查看当前支持的命令
- `/compact`：长会话里压缩上下文
- `/review`：请求对当前代码做审查
- `/mcp`：查看和管理 MCP 连接状态

## 实战建议

- 长会话里优先把 `/compact` 当成常规动作，而不是等上下文快满了再处理。
- 复杂需求尽量用多行输入组织 prompt，通常比一次写成一长行更稳定。
- 如果要快速微调上一条问题，直接 `Esc` 两次回编辑状态，比重打一遍更省时间。
- 权限或执行策略频繁切换时，`Shift+Tab` 会比重新进配置更快。

## 相关阅读

- [使用技巧](./tips)
- [配置详解](./config)
- [常见问题](./faq)
