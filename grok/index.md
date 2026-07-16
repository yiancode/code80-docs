---
description: 使用 xAI 官方 Grok Build 通过 Code80 OpenAI 兼容中转进行 AI 编程，包含安全配置与可复现验证步骤
---

# Grok Build

Grok Build 是 xAI 发布的终端 AI 编程工具。本指南只介绍官方项目 [xai-org/grok-build](https://github.com/xai-org/grok-build) 及其官方发行版。

::: danger 不要混淆同名 CLI
社区包或旧 npm 包可能也提供 `grok` 命令，但它们不是本指南的目标，配置格式和请求协议也不同。不要使用 `@vibe-kit/grok-cli`、`superagent-ai/grok-cli`、`grok-dev` 等包替代官方 Grok Build。
:::

## 快速开始

1. 按[官方安装](./install)安装并确认 `grok --version`。
2. 在 Code80 创建可访问 Grok 模型的 API Key。不要将 Key 写入项目文件、Shell 历史或文档。
3. 按[Code80 中转配置](./config)把官方 Grok Build 指向 `https://code.ai80.vip/v1`。
4. 重启 `grok`，用 `/model` 选择可用模型。

## 一键交给 Claude Code / Codex 配置

下面的提示词用于让 Claude Code 或 Codex **协助安装和配置官方 Grok Build**。它不会把 Claude Code 或 Codex 本身切换成 Grok，也不会要求 Agent 猜测、打印或提交你的 API Key。

```text
请帮我安装并配置 xAI 官方 Grok Build，通过 Code80 的 OpenAI 兼容中转使用。

要求：
1. 只使用 xai-org/grok-build 的官方安装方式；检查并卸载已安装的非官方 grok CLI（例如 @vibe-kit/grok-cli、superagent-ai/grok-cli、grok-dev），不要安装同名社区包。
2. 安装后必须确认 command -v grok 指向 ~/.grok/bin/grok 或官方安装位置，并验证 grok --version。
3. 先检查我是否已经在 macOS Keychain 或环境变量中保存 API Key；找不到时只向我索取 Key，不要猜测，也不要把 Key 输出、提交到仓库或写入项目目录。
4. 在 ~/.grok/config.toml 配置 Code80：模型和模型目录均使用 https://code.ai80.vip/v1，使用 OpenAI Chat Completions 协议，并将模型目录设为 /v1/models。
5. 让 XAI_API_KEY 在启动 grok 的进程中可用，以便 /model 可以拉取远端模型列表；API Key 优先存进系统钥匙串或用户级安全配置，权限设为仅当前用户可读。
6. 用 GET /v1/models 和一次最小 /v1/chat/completions 请求分别验证鉴权和推理；不要在输出中显示完整 Key。
7. 如果命令找不到、/model 只有当前模型、出现 auth.x.ai 登录、或 API 返回 502/503，按官方 Grok Build 的配置和排障方式定位，说明证据与下一步，不要用非官方 CLI 规避。
```

## 安全边界

- 不把真实 Key 放进 `AGENTS.md`、仓库 `.env`、文档、截图或聊天记录。
- 优先使用 macOS Keychain、系统凭据管理器或用户级环境变量；配置文件权限应限制为当前用户。
- 只在中转确实支持的模型上进行推理。`/v1/models` 能返回列表不等于所有模型的上游推理服务都可用。

## 下一步

- [官方安装](./install)
- [Code80 中转配置](./config)
- [排障与常见问题](./faq)
