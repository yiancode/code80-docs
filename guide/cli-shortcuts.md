---
description: Claude Code、Codex CLI、Gemini CLI、Grok CLI 快捷键、启动参数、会话恢复与权限模式总览
---

# CLI 快捷键总览

这一页把 Claude Code、Codex CLI、Gemini CLI、Grok CLI 四款 AI 编程命令行工具的快捷键、常用参数和会话恢复方式放在一起，适合横向速查。

## 常用快捷键对照

| 场景 | Claude Code | Codex CLI | Gemini CLI | Grok CLI |
|------|-------------|-----------|------------|----------|
| 取消当前步骤 | `Ctrl+C` | `Ctrl+C` | `Ctrl+C` | `Esc` |
| 退出当前会话 | `Ctrl+D` | `Ctrl+D` 或退出终端 | `Ctrl+D` 或退出终端 | 空输入时 `Ctrl+C` |
| 清空当前输入 | 按终端默认行为 | 按终端默认行为 | 按终端默认行为 | 非空输入时 `Ctrl+C` |
| 清屏 | `Ctrl+L` | `Ctrl+L` | `Ctrl+L` | 未单独强调 |
| 历史输入 / 导航 | 上 / 下箭头 | 上 / 下箭头 | 上 / 下箭头 | 输入框移动光标；菜单中导航 |
| 多行输入 | `Option+Enter`、`Shift+Enter`、`Ctrl+J`，或输入 `\\` 后回车 | 按终端默认行为 | 按终端默认行为 | `Shift+Enter` |
| 切换执行模式 | `Shift+Tab` | 通过命令或参数切换 | 按工具默认行为 | 空闲时 `Tab` |
| 编辑上一条消息 | `Esc` 再 `Esc` | 未单独强调 | 未单独强调 | 未单独提供 |

## 交互风格

- `Claude Code`：偏会话内操作，slash commands 完整
- `Codex CLI`：偏“子命令 + 参数”，自动化和审查入口清晰
- `Gemini CLI`：强调大上下文、Agent Mode 和 Google Search
- `Grok CLI`：全屏交互与无头调用并重，包含 Web / X 搜索和子代理

## 最常用启动参数

| 目的 | Claude Code | Codex CLI | Gemini CLI | Grok CLI |
|------|-------------|-----------|------------|----------|
| 交互启动 | `claude` | `codex` | `gemini` | `grok` |
| 指定模型 | `--model` | `-m`, `--model` | `GEMINI_MODEL` | `-m`, `--model` |
| 指定工作目录 | 目标目录启动或 `--add-dir` | `-C`, `--cd <DIR>` | 通常在目标目录启动 | `-d`, `--directory <DIR>` |
| 一次性任务 | `-p` | `exec` | 通过参数调用 | `-p`, `--prompt` |
| 机器可读输出 | `--output-format` | `exec --json` | 取决于调用方式 | `--format json`（NDJSON） |
| 联网能力 | 依赖工具或配置 | `--search` | 内置 Google Search | 内置 Web / X 搜索 |
| 配置覆盖 | `--settings` | `-c key=value` | `.env` + `settings.json` | `--api-key`、`--base-url`、`--model` |

## 会话恢复

| 任务 | Claude Code | Codex CLI | Gemini CLI | Grok CLI |
|------|-------------|-----------|------------|----------|
| 恢复最近会话 | `claude -c` | `codex resume --last` | 站内文档未单独展开 | `grok --session latest` |
| 恢复指定会话 | `claude -r [session_id]` | `codex resume` | 站内文档未单独展开 | `grok -s <session-id>` |
| 从旧会话分叉 | `claude --fork-session -r [session_id]` | `codex fork --last` | 站内文档未单独展开 | 未单独提供 |
| 新建上下文 | `/clear` 或新开会话 | 新开会话 | 新开会话 | Slash 菜单 → `new session` |

## 权限与执行模式

| 场景 | Claude Code | Codex CLI | Gemini CLI | Grok CLI |
|------|-------------|-----------|------------|----------|
| 权限控制风格 | permission mode | sandbox + approval | 工具权限机制 | 会话模式 + 工具确认 |
| 常见自动入口 | `--permission-mode auto` | `--full-auto` | Agent Mode | 无头 `-p` |
| 手动切换 | `Shift+Tab` 或命令 | 启动参数或命令 | 按工具默认行为 | 空闲时 `Tab` |
| 沙箱能力 | 权限模式 | 支持 | 工具权限机制 | Shuru，仅 macOS 14+ Apple Silicon |

无论使用哪款工具，高风险命令、提交、推送和外部写操作都应在执行前检查目标与 diff。

## 高频入口命令

### Claude Code

```bash
claude
/help
/compact
/review
/mcp
```

### Codex CLI

```bash
codex
codex exec "实现一个带重试的 HTTP 客户端"
codex review
codex resume --last
codex fork --last
codex mcp list
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
grok -p "检查当前 diff" --format json
grok --session latest
grok -s <session-id>
grok models
```

Grok CLI 常用会话命令：

```text
/help
/models
/agents
/mcp
/review
/verify  # 仅 macOS 14+ Apple Silicon
new session  # 从 Slash 菜单选择
/exit
```

Grok 的内置 verify 强制使用 Shuru，不会在其他平台自动降级到主机模式。Linux、Windows 和 Intel Mac 应改用普通提示词运行项目检查。

::: warning Grok 批处理兼容性
Code80 当前未提供 Grok CLI `--batch-api` 所需的 `/batches` 端点。脚本调用请使用普通 `-p` 无头模式。
:::

## 一页看懂差异

- 长期会话和丰富 slash commands：优先看 `Claude Code`
- 显式子命令、审查和自动化：优先看 `Codex CLI`
- 大上下文、Google Search 和 Agent Mode：优先看 `Gemini CLI`
- Grok 模型、Web / X 搜索与社区多代理工作流：优先看 `Grok CLI`

## 分工具详解

- [Claude Code 快捷键](/claudecode/shortcuts)
- [Codex CLI 快捷键](/codex/shortcuts)
- [Gemini CLI 快捷键](/gemini/shortcuts)
- [Grok CLI 快捷键](/grok/shortcuts)
