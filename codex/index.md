---
description: Codex CLI 快速开始指南，3 步通过 Code80 平台配置 OpenAI AI 编程助手
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
model_provider = "code80"
model = "gpt-5.3-codex"
model_reasoning_effort = "high"
network_access = "enabled"
disable_response_storage = true
model_verbosity = "high"

[model_providers.code80]
name = "code80"
base_url = "https://code.ai80.vip/v1"
wire_api = "responses"
requires_openai_auth = true
```

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
