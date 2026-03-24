---
description: Claude Code、Codex CLI、Gemini CLI 快捷键、启动参数、会话恢复与审批模式总览，适合横向对照速查
---

# CLI 快捷键总览

这一页把 Claude Code、Codex CLI、Gemini CLI 三套 AI 编程命令行工具的快捷键、常用启动参数、会话恢复方式和审批模式放在一起，适合横向对照查看。

## 常用快捷键对照

| 场景 | Claude Code | Codex CLI | Gemini CLI |
|------|-------------|-----------|------------|
| 取消当前步骤 | `Ctrl+C` | `Ctrl+C` | `Ctrl+C` |
| 退出当前会话 | `Ctrl+D` | `Ctrl+D` 或直接退出终端 | `Ctrl+D` 或直接退出终端 |
| 清屏 | `Ctrl+L` | `Ctrl+L` | `Ctrl+L` |
| 历史输入 | 上 / 下箭头 | 上 / 下箭头 | 上 / 下箭头 |
| 多行输入 | `Option+Enter`、`Shift+Enter`、`Ctrl+J`，或输入 `\\` 后回车 | 按终端默认行为处理 | 按终端默认行为处理 |
| 切换执行模式 | `Shift+Tab` | 会话内更常见的是通过命令或参数切换 | 按工具默认行为处理 |
| 编辑上一条消息 | `Esc` 再 `Esc` | 未单独强调专属快捷键 | 未单独强调专属快捷键 |

## 高频交互方式对照

三套 CLI 的使用重心并不一样：

- `Claude Code`：更偏会话内操作，slash commands 更完整
- `Codex CLI`：更偏“命令 + 参数”风格，子命令比较清晰
- `Gemini CLI`：更偏终端原生体验，突出大上下文、Agent Mode 和联网搜索

## 最常用启动参数

| 目的 | Claude Code | Codex CLI | Gemini CLI |
|------|-------------|-----------|------------|
| 交互启动 | `claude` | `codex` | `gemini` |
| 指定模型 | `--model` | `-m`, `--model` | 站内文档当前主要通过 `GEMINI_MODEL` 环境变量配置 |
| 指定工作目录 | 通常在目标目录直接启动，也可配 `--add-dir` | `-C`, `--cd <DIR>` | 通常在目标目录直接启动 |
| 附加目录 | `--add-dir <DIR>` | `--add-dir <DIR>` | 站内文档未单独展开 |
| 启用联网能力 | 更多依赖工具或配置 | `--search` | 内置 Google Search 能力 |
| 指定配置覆盖 | `--settings <file-or-json>` | `-c key=value` | 站内文档当前主要通过 `.env` 与 `settings.json` 配置 |
| 自动执行 | `--permission-mode auto` | `--full-auto` | 依赖 Agent Mode 与工具默认行为 |
| 危险全放开 | `--dangerously-skip-permissions` | `--dangerously-bypass-approvals-and-sandbox` | 不建议默认这样使用 |

## 会话恢复与分叉

| 任务 | Claude Code | Codex CLI | Gemini CLI |
|------|-------------|-----------|------------|
| 恢复最近一次会话 | `claude -c` | `codex resume --last` | 站内文档未单独展开 |
| 恢复指定会话 | `claude -r [session_id]` | `codex resume` | 站内文档未单独展开 |
| 从旧会话分叉 | `claude --fork-session -r [session_id]` | `codex fork --last` | 站内文档未单独展开 |

## 审批模式与权限风格

这一部分是三套 CLI 差异最明显的地方。

| 场景 | Claude Code | Codex CLI | Gemini CLI |
|------|-------------|-----------|------------|
| 权限控制风格 | `permission mode` | `sandbox + approval` 显式分离 | 更偏工具默认行为 |
| 常见自动模式 | `--permission-mode auto` | `--full-auto` | Agent Mode 自动规划 |
| 手动切换模式 | 会话内可配合快捷键和命令调整 | 更常通过启动参数显式声明 | 站内文档未单独展开 |
| 高风险全开放 | `--dangerously-skip-permissions` | `--dangerously-bypass-approvals-and-sandbox` | 不建议默认全开放 |

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

## 最值得背的命令

### Claude Code

```bash
claude
claude -c
claude -r
claude --model sonnet
claude --permission-mode auto
claude --dangerously-skip-permissions
/help
/compact
/mcp
/review
```

### Codex CLI

```bash
codex
codex exec "..."
codex review
codex resume --last
codex fork --last
codex mcp list
codex mcp add <name> -- <command>
codex --full-auto
codex --search
codex --dangerously-bypass-approvals-and-sandbox
```

### Gemini CLI

```bash
gemini
gemini --version
```

如果你只想先记最实用的一组，可以优先记“启动、恢复、自动执行、联网、审查”这几类命令。

## 一页看懂差异

- `Claude Code` 更像“终端里的会话型助手”，快捷键和 slash commands 比较完整。
- `Codex CLI` 更像“显式参数驱动的工程工具”，很多能力都通过一级子命令和启动参数完成。
- `Gemini CLI` 更强调大上下文、联网搜索和 Agent Mode，交互层面相对更接近终端原生体验。

## 哪套更适合你

- 如果你习惯在终端里长期保留上下文，并依赖交互命令管理状态，优先看 `Claude Code`
- 如果你更喜欢显式参数、子命令分明的工具风格，优先看 `Codex CLI`
- 如果你需要更大的上下文窗口，以及更强的联网搜索和自动规划能力，优先看 `Gemini CLI`

## 分工具详解

- [Claude Code 快捷键](/claudecode/shortcuts)
- [Codex CLI 快捷键](/codex/shortcuts)
- [Gemini CLI 快捷键](/gemini/shortcuts)
