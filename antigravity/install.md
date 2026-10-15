---
description: Antigravity CLI（agy）安装与验证，确认版本后即可配置 Code80
---

# Antigravity CLI 安装与验证

本页只确认你本机已有可用的 `agy` 命令。安装渠道以 **Antigravity CLI 官方说明**为准，本文不编造具体的 curl / npm 包名。

## 前置条件

- 已按 Antigravity CLI 官方方式完成安装
- 终端能直接执行 `agy`（已在 `PATH` 中）
- 准备一把 Code80 API Key（后续配置用）

## 验证安装

在任意目录执行：

```bash
agy --version
```

能打印出版本号即表示 CLI 可用。截图示例（本机实测为 `1.3.5`）：

![agy --version](/antigravity/01-agy-version.png)

若提示 `command not found`：

1. 确认已按官方方式安装 Antigravity CLI（不是桌面 IDE，也不是 `npm i -g @google/gemini-cli`）
2. 检查 `which agy` / `echo $PATH`，把安装目录加入 PATH
3. 新开终端再试

## 和 Gemini CLI 的区别

| 项目 | Antigravity CLI | Gemini CLI |
|------|-----------------|------------|
| 命令 | `agy` | `gemini` |
| 包 / 来源 | Antigravity CLI 官方渠道 | npm `@google/gemini-cli` |
| 设置文件 | `~/.gemini/antigravity-cli/settings.json` | `~/.gemini/settings.json` |
| 环境变量文件 | 读 shell 环境变量，**不读** `~/.gemini/.env` | 常用 `~/.gemini/.env` |

官方 Gemini CLI 教程：[Gemini CLI](/gemini/)。

## 下一步

验证通过后，继续 [配置详解](./config)。
