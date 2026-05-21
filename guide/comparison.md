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

## 常用快捷键

| 场景 | Claude Code | Codex CLI | Gemini CLI |
|------|-------------|-----------|------------|
| 取消当前步骤 | `Ctrl+C` | `Ctrl+C` | `Ctrl+C` |
| 退出当前会话 | `Ctrl+D` | `Ctrl+D` 或直接退出终端 | `Ctrl+D` 或直接退出终端 |
| 清屏 | `Ctrl+L` | `Ctrl+L` | `Ctrl+L` |
| 历史输入 | 上 / 下箭头 | 上 / 下箭头 | 上 / 下箭头 |
| 多行输入 | `Option+Enter`、`Shift+Enter`、`Ctrl+J`，或输入 `\\` 后回车 | 按终端默认行为处理 | 按终端默认行为处理 |

## 常用启动参数与命令风格

| 目的 | Claude Code | Codex CLI | Gemini CLI |
|------|-------------|-----------|------------|
| 交互启动 | `claude` | `codex` | `gemini` |
| 指定模型 | `--model` | `-m`, `--model` | 主要通过 `GEMINI_MODEL` 配置 |
| 自动执行 | `--permission-mode auto` | `--full-auto` | 依赖 Agent Mode |
| 联网能力 | 主要依赖工具或配置 | `--search` | 内置 Google Search |
| 高风险全放开 | `--dangerously-skip-permissions` | `--dangerously-bypass-approvals-and-sandbox` | 不建议默认这样使用 |

## 会话恢复与分叉

| 任务 | Claude Code | Codex CLI | Gemini CLI |
|------|-------------|-----------|------------|
| 恢复最近一次会话 | `claude -c` | `codex resume --last` | 站内文档未单独展开 |
| 恢复指定会话 | `claude -r [session_id]` | `codex resume` | 站内文档未单独展开 |
| 从旧会话分叉 | `claude --fork-session -r [session_id]` | `codex fork --last` | 站内文档未单独展开 |

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

## 快捷键与交互方式

如果你更关心日常使用时的快捷键、slash commands 和高频命令，可以直接查看：

- [CLI 快捷键总览](./cli-shortcuts)
- [Claude Code 快捷键](/claudecode/shortcuts)
- [Codex CLI 快捷键](/codex/shortcuts)
- [Gemini CLI 快捷键](/gemini/shortcuts)

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

## 选择建议

- **Claude Code**：适合需要深度代码理解和项目级上下文的开发者
- **Codex CLI**：适合喜欢 OpenAI 生态的开发者
- **Gemini CLI**：适合需要大上下文和联网搜索能力的开发者

三个工具都可以通过 Code80 平台统一管理，只需分别创建对应平台的 API Key 即可。
