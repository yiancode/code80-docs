---
description: Codex CLI 使用技巧，涵盖交互模式、自动执行、安全策略和高效编程实践
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

### 网络访问

配置 `network_access = "enabled"` 后，Codex 可以访问网络资源辅助编程。

### 推理深度调整

根据任务复杂度调整 `model_reasoning_effort`：

- `low`：简单任务，响应更快
- `medium`：日常编程
- `high`：复杂算法、架构设计

### 沙箱环境

Codex CLI 默认在沙箱中运行代码，确保安全性。Linux 需要安装 bubblewrap。

## 与其他工具对比

查看 [工具功能对比](/guide/comparison) 了解 Codex CLI 与 Claude Code、Gemini CLI 的差异。
