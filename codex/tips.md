---
description: Codex CLI 使用技巧，涵盖模型选择（gpt-5.6-terra / sol / luna）、推理深度、沙箱网络和高效编程实践
---

# Codex CLI 使用技巧

## 基础操作

### 启动

```bash
cd your-project
codex
```

### 直接提问

```bash
codex "帮我写一个排序函数"
```

## 快捷键与高频交互

Codex CLI 的快捷键与常用交互命令已经整理成独立页面，方便快速查阅：

- [Codex CLI 快捷键](./shortcuts)

## 高效使用

### 模型怎么选

Code80 上请写精确 ID，不要写 `gpt-5.6`：

- `gpt-5.6-terra`：日常默认
- `gpt-5.6-luna`：快、便宜、小改动
- `gpt-5.6-sol`：复杂编码、审查、研究

会话里用 `/model` 切换，或启动时 `codex --model gpt-5.6-sol`。

### 关掉 WebSocket，避免每次先重连 5 次

接 Code80 时在自定义 provider 写 `supports_websockets = false`。Codex 默认先走 WSS，中转转不好就会「正在重新连接 1/5 … 5/5」，一两分钟后才降级 HTTP 开始出字。不要改内置 `openai` provider，单独建 `codex`。改完彻底退出，用新对话测。

### 网络访问

`workspace-write` 默认不能出网。需要装依赖、拉包时再开：

```toml
sandbox_mode = "workspace-write"

[sandbox_workspace_write]
network_access = true
```

不要再写顶层 `network_access = "enabled"`，当前 schema 不认这个键。

### 推理深度调整

根据任务复杂度调整 `model_reasoning_effort`：

- `low` / `minimal`：简单任务，响应更快
- `medium`：日常编程
- `high` / `xhigh`：复杂算法、架构设计、深审查

### 沙箱环境

Codex CLI 默认在沙箱中运行代码，确保安全性。Linux 需要安装 bubblewrap。

## 与其他工具对比

查看 [工具功能对比](/guide/comparison) 了解 Codex CLI 与 Claude Code、Gemini CLI、Grok CLI 的差异。
