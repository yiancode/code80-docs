---
description: Claude Code、Codex CLI、Gemini CLI、Grok CLI 四款 AI 编程工具功能对比，帮助选择合适的终端助手
---

# 工具功能对比

## 总览

| 特性 | Claude Code | Codex CLI | Gemini CLI | Grok CLI |
|------|-------------|-----------|------------|----------|
| 开发者 | Anthropic | OpenAI | Google | 社区项目（superagent-ai） |
| 安装前置 | Node.js 18+ | Node.js 22+ | Node.js 20+ | 脚本安装无需 Node.js；也可用 Bun |
| 安装命令 | `npm i -g @anthropic-ai/claude-code` | `npm i -g @openai/codex` | `npm i -g @google/gemini-cli` | 官方脚本或 `bun add -g grok-dev` |
| 配置格式 | JSON | TOML + JSON | `.env` + JSON | JSON + 环境变量 |
| 启动命令 | `claude` | `codex` | `gemini` | `grok` |

Grok CLI 此处指 [superagent-ai/grok-cli](https://github.com/superagent-ai/grok-cli)，不是 xAI 官方 CLI。

## 常用快捷键

| 场景 | Claude Code | Codex CLI | Gemini CLI | Grok CLI |
|------|-------------|-----------|------------|----------|
| 取消当前步骤 | `Ctrl+C` | `Ctrl+C` | `Ctrl+C` | `Esc` |
| 退出当前会话 | `Ctrl+D` | `Ctrl+D` 或退出终端 | `Ctrl+D` 或退出终端 | 空输入时 `Ctrl+C` |
| 清屏 | `Ctrl+L` | `Ctrl+L` | `Ctrl+L` | 未单独强调 |
| 历史输入 / 导航 | 上 / 下箭头 | 上 / 下箭头 | 上 / 下箭头 | 输入框移动光标；菜单中导航 |
| 多行输入 | `Option+Enter`、`Shift+Enter`、`Ctrl+J`，或输入 `\\` 后回车 | 按终端默认行为处理 | 按终端默认行为处理 | `Shift+Enter` |
| 切换执行模式 | `Shift+Tab` | 通过命令或参数切换 | 按工具默认行为处理 | 空闲时 `Tab` |

## 常用启动参数与命令风格

| 目的 | Claude Code | Codex CLI | Gemini CLI | Grok CLI |
|------|-------------|-----------|------------|----------|
| 交互启动 | `claude` | `codex` | `gemini` | `grok` |
| 指定模型 | `--model` | `-m`, `--model` | 主要通过 `GEMINI_MODEL` | `-m`, `--model` |
| 指定工作目录 | 在目标目录启动或 `--add-dir` | `-C`, `--cd` | 通常在目标目录启动 | `-d`, `--directory` |
| 一次性任务 | `claude -p` | `codex exec` | 可通过参数调用 | `-p`, `--prompt` |
| 联网能力 | 主要依赖工具或配置 | `--search` | 内置 Google Search | 内置 Web / X 搜索 |
| 自动执行 | `--permission-mode auto` | `--full-auto` | Agent Mode | 无头 `-p` 或会话模式 |

## 会话恢复与分叉

| 任务 | Claude Code | Codex CLI | Gemini CLI | Grok CLI |
|------|-------------|-----------|------------|----------|
| 恢复最近会话 | `claude -c` | `codex resume --last` | 站内文档未单独展开 | `grok --session latest` |
| 恢复指定会话 | `claude -r [session_id]` | `codex resume` | 站内文档未单独展开 | `grok -s <session-id>` |
| 开始新上下文 | 新开会话或 `/clear` | 新开会话 | 新开会话 | Slash 菜单 → `new session` |
| 从旧会话分叉 | `claude --fork-session -r [session_id]` | `codex fork --last` | 站内文档未单独展开 | 未单独提供分叉命令 |

## 配置对比

### Claude Code

- 配置文件：`~/.claude/settings.json`
- API 地址格式：`https://domain.com`（不加路径后缀）
- Key 字段：`ANTHROPIC_AUTH_TOKEN`

### Codex CLI

- 配置文件：`~/.codex/config.toml` + `~/.codex/auth.json`
- API 地址格式：`https://domain.com`（不加路径后缀）
- Key 字段：`OPENAI_API_KEY`

### Gemini CLI

- 配置文件：`~/.gemini/.env` + `~/.gemini/settings.json`
- API 地址格式：`https://domain.com/v1beta`（加 `/v1beta`）
- Key 字段：`GEMINI_API_KEY`

### Grok CLI

- 用户配置：`~/.grok/user-settings.json`
- API 地址：`GROK_BASE_URL=https://code.ai80.vip/v1`
- Key 字段：用户配置中的 `apiKey`，也可临时使用 `GROK_API_KEY`
- 推荐默认模型：`grok-4.3`

::: warning Grok Base URL 的配置方式不同
Grok CLI 1.1.7 不读取 JSON 中的 `baseURL`。必须使用 `GROK_BASE_URL` 或 `--base-url`，并保留末尾的 `/v1`。
:::

## 特色功能

| 功能 | Claude Code | Codex CLI | Gemini CLI | Grok CLI |
|------|:-----------:|:---------:|:----------:|:--------:|
| 项目规则文件 | `CLAUDE.md` | `AGENTS.md` | `GEMINI.md` | `AGENTS.md` |
| 沙箱执行 | 权限模式 | 支持 | 工具权限机制 | Shuru，仅 macOS 14+ Apple Silicon |
| 联网搜索 | 依赖工具或配置 | 可配置 | Google Search | Web / X Search |
| 多代理能力 | 支持 | 支持 | Agent Mode | 支持子代理 |
| MCP | 支持 | 支持 | 支持 | 支持 |
| 无头调用 | `-p` | `exec` | 支持 | `-p` + `--format json`（NDJSON） |

## 最值得背的命令

### Claude Code

```bash
claude
claude -c
claude -r
/help
/compact
/review
```

### Codex CLI

```bash
codex
codex exec "..."
codex review
codex resume --last
codex --full-auto
codex --search
```

### Gemini CLI

```bash
gemini
gemini --version
```

### Grok CLI

```bash
grok
grok -m grok-4.3
grok -p "..." --format json
grok --session latest
grok -s <session-id>
/agents
/verify  # 仅 macOS 14+ Apple Silicon
```

## 选择建议

- **Claude Code**：适合重视长期会话、项目级上下文和完整交互命令的开发者
- **Codex CLI**：适合喜欢显式参数、审查命令和 OpenAI 生态的开发者
- **Gemini CLI**：适合需要大上下文、Google Search 和 Agent Mode 的开发者
- **Grok CLI**：适合希望使用 Grok 模型、Web / X 搜索和社区多代理工作流的开发者

四款工具都可以通过 Code80 统一管理，但协议和模型分组不同，应为每款工具创建或选择具有对应模型权限的 API Key。

## 快捷键与交互方式

- [CLI 快捷键总览](./cli-shortcuts)
- [Claude Code 快捷键](/claudecode/shortcuts)
- [Codex CLI 快捷键](/codex/shortcuts)
- [Gemini CLI 快捷键](/gemini/shortcuts)
- [Grok CLI 快捷键](/grok/shortcuts)
