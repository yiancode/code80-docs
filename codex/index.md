---
description: Codex CLI 快速开始指南：3 步手工配置，或复制提示词交给 Agent 安装并接到 Code80
---

# Codex CLI

OpenAI 官方 AI 编程助手命令行工具。不想手工改配置时，把[下面的提示词](#agent-setup)整段复制给 Claude Code、Grok Build 或其他 Agent，让它代为安装并接到 Code80。

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

## 一键交给 Agent 安装并配置 {#agent-setup}

下面的提示词用于让另一个 Agent **协助安装官方 Codex CLI，并接到 Code80**。它不会要求 Agent 猜测、打印或提交你的 API Key，也不会改内置的 `openai` provider。

```text
请帮我安装并配置官方 Codex CLI，通过 Code80 中转使用。

要求：
1. 只安装官方包 @openai/codex。需要 Node.js 22+；Linux 还要安装 bubblewrap。安装后验证 command -v codex 和 codex --version。
2. 先检查我是否已经在 ~/.codex/auth.json、环境变量 OPENAI_API_KEY 或系统钥匙串里保存了 Code80 的 OpenAI 分组 API Key。找不到时只向我索取 Key，不要猜测，也不要把 Key 输出、提交到仓库、写入项目目录或写进 config.toml。
3. 用户级配置只写 ~/.codex/config.toml。已有文件时合并，不要覆盖 MCP、hooks 或其他无关设置。全文件只能有一个 model_provider。不要改内置 [model_providers.openai]，不要写 openai_base_url。
4. 按下面写入（或合并）配置，模型必须用精确 ID，禁止写 gpt-5.6、gpt-5.4、gpt-luna：

#:schema https://developers.openai.com/codex/config-schema.json

model = "gpt-5.6-terra"
model_provider = "codex"
model_reasoning_effort = "medium"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
web_search = "cached"
personality = "pragmatic"
forced_login_method = "api"

[model_providers.codex]
name = "codex"
base_url = "https://code.ai80.vip"
wire_api = "responses"
requires_openai_auth = true
supports_websockets = false

[sandbox_workspace_write]
network_access = false

5. base_url 用 https://code.ai80.vip，末尾不要加 /v1。requires_openai_auth 必须为 true（Codex 0.149.0 起 false 不会继承 auth.json，会 401）。supports_websockets 必须为 false（否则每次提问会卡在「正在重新连接 1/5 … 5/5」）。
6. 把 API Key 写进 ~/.codex/auth.json，格式为 {"OPENAI_API_KEY": "<key>"}。macOS/Linux 执行 chmod 700 ~/.codex 和 chmod 600 ~/.codex/config.toml ~/.codex/auth.json。Windows 路径是 %USERPROFILE%\.codex\。
7. 配置完成后让我彻底退出再打开 Codex（macOS Cmd+Q / Windows 结束进程 / CLI 退出后重新运行），并用新对话测试。不要只关窗口。不要在输出中显示完整 Key。
8. 若出现 401、API_KEY_REQUIRED、正在重新连接、模型不存在、或 base_url 带了 /v1，按 Code80 Codex 文档定位：自定义 provider 必须 requires_openai_auth=true 且 supports_websockets=false；模型只用 gpt-5.6-terra / gpt-5.6-sol / gpt-5.6-luna。说明证据和下一步，不要用非官方 Codex 包规避。
```

::: tip 复制后记得准备 Key
Agent 找不到现有密钥时会向你要 Code80 **OpenAI 分组** 的 API Key。不要把 Key 贴进仓库、`AGENTS.md` 或聊天截图。
:::

## 安全边界

- 不把真实 Key 放进 `AGENTS.md`、仓库 `.env`、文档、截图或聊天记录。
- Key 只放在 `~/.codex/auth.json`，权限限制为当前用户。
- 日常默认模型用 `gpt-5.6-terra`。不要写 `gpt-5.6` 或 `gpt-luna`。

## 适用场景

- AI 辅助代码生成
- 自然语言描述转代码
- 代码补全与优化
- 自动化脚本编写

## 下一步

- [安装详解](./install) - 分平台的详细安装步骤，也可把上面的提示词交给 Agent
- [配置详解](./config) - 完整的配置文件说明
- [快捷键速查](./shortcuts) - 常用快捷键与高频交互命令
- [使用技巧](./tips) - 高级用法和效率提升
- [常见问题](./faq) - 遇到问题看这里
