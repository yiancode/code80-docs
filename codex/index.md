---
description: Codex CLI 快速开始指南，3 步通过 Code80 配置 gpt-5.6-terra / gpt-5.6-sol / gpt-5.6-luna
---

# Codex CLI

OpenAI 官方 AI 编程助手命令行工具。

## 快速开始

只需 3 步，即可通过 Code80 平台使用 Codex CLI：

### 1. 安装 CLI 工具

```bash
npm install -g @openai/codex
```

### 2. 配置 API

创建配置目录和文件：

```bash
mkdir -p ~/.codex
```

编辑 `~/.codex/config.toml`：

```toml
#:schema https://developers.openai.com/codex/config-schema.json

model = "gpt-5.6-terra"
model_provider = "codex"
model_reasoning_effort = "medium"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
web_search = "cached"
forced_login_method = "api"

[model_providers.codex]
name = "codex"
base_url = "https://code.ai80.vip"
wire_api = "responses"
requires_openai_auth = true
supports_websockets = false
```

日常默认用 `gpt-5.6-terra`。复杂任务换成 `gpt-5.6-sol`，图快图省用 `gpt-5.6-luna`。不要写 `gpt-5.6` 或 `gpt-luna`。

`requires_openai_auth = true` 让 0.149.0+ 继续读 `auth.json`；`supports_websockets = false` 避免每次提问先卡「正在重新连接」。完整说明见 [配置详解](./config)。

编辑 `~/.codex/auth.json`：

```json
{
  "OPENAI_API_KEY": "your-api-key"
}
```

> 将 `your-api-key` 替换为你在 Code80 平台获取的 API Key。

### 3. 开始使用

```bash
cd your-project
codex
```

首次启动流程：选择开发环境 → 配置偏好 → 开始 AI 辅助编程。

## 适用场景

- AI 辅助代码生成
- 自然语言描述转代码
- 代码补全与优化
- 自动化脚本编写

## 下一步

- [安装详解](./install) - 分平台的详细安装步骤
- [配置详解](./config) - 完整的配置文件说明
- [快捷键速查](./shortcuts) - 常用快捷键与高频交互命令
- [使用技巧](./tips) - 高级用法和效率提升
- [常见问题](./faq) - 遇到问题看这里
