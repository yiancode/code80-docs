---
description: Claude Code、Codex CLI、Gemini CLI 三大 AI 编程工具功能对比，帮你选择最适合的工具
---

# 工具功能对比

## 总览

| 特性 | Claude Code | Codex CLI | Gemini CLI |
|------|------------|-----------|------------|
| 开发商 | Anthropic | OpenAI | Google |
| Node.js 要求 | 18+ | 22+ | 20+ |
| 安装命令 | `npm i -g @anthropic-ai/claude-code` | `npm i -g @openai/codex` | `npm i -g @google/gemini-cli` |
| 配置格式 | JSON | TOML + JSON | .env + JSON |
| 启动命令 | `claude` | `codex` | `gemini` |

## 配置对比

### Claude Code
- 配置文件：`~/.claude/settings.json`
- API 地址格式：`https://domain.com`（不加路径后缀）
- Key 字段：`ANTHROPIC_AUTH_TOKEN`

### Codex CLI
- 配置文件：`~/.codex/config.toml` + `~/.codex/auth.json`
- API 地址格式：`https://domain.com/v1`（加 `/v1`）
- Key 字段：`OPENAI_API_KEY`

### Gemini CLI
- 配置文件：`~/.gemini/.env` + `~/.gemini/settings.json`
- API 地址格式：`https://domain.com/v1beta`（加 `/v1beta`）
- Key 字段：`GEMINI_API_KEY`

## 特色功能

| 功能 | Claude Code | Codex CLI | Gemini CLI |
|------|:-----------:|:---------:|:----------:|
| 大上下文 | 中等 | 中等 | 超大 |
| 沙箱执行 | - | Linux 支持 | - |
| 联网搜索 | - | 可配置 | Google Search |
| Agent Mode | - | - | 支持 |
| IDE 集成 | VS Code | - | - |
| 对话压缩 | /compact | - | - |
| CLAUDE.md | 支持 | - | - |

## 选择建议

- **Claude Code**：适合需要深度代码理解和项目级上下文的开发者
- **Codex CLI**：适合喜欢 OpenAI 生态的开发者
- **Gemini CLI**：适合需要大上下文和联网搜索能力的开发者

三个工具都可以通过 Code80 平台统一管理，只需分别创建对应平台的 API Key 即可。
