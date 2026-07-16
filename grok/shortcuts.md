---
description: xAI 官方 Grok Build 的交互快捷键、模型选择、slash commands 与安全启动参数速查
---

# 快捷键速查

不同 Grok Build 版本的可见菜单可能略有不同。最可靠的做法是在 TUI 中输入 `/`，以当前版本显示的命令为准。

## 常用交互

| 目的 | 操作 | 说明 |
|---|---|---|
| 发送消息 | `Enter` | 提交当前输入。 |
| 取消运行中的任务 | `Ctrl+C` | 任务运行时取消；输入框有草稿时优先清空草稿。 |
| 清空或回退 | `Esc` | 空闲时按两次可清空草稿或打开回退，具体行为取决于当前状态。 |
| 切换焦点 | `Tab` | 在输入区与滚动记录之间切换。 |
| 打开模型选择器 | `Ctrl+M` | 在滚动记录聚焦时打开模型选择器；输入框聚焦时会切换多行输入。 |
| 新建会话 | `Ctrl+N` 或 `/new` | 开始干净的对话上下文。 |

## 常用 Slash Commands

| 命令 | 用途 |
|---|---|
| `/model <model>` 或 `/m <model>` | 切换模型。先配置模型目录，才会看到中转返回的模型。 |
| `/compact` | 压缩较长会话的上下文。 |
| `/always-approve` | 切换会话内的自动审批。只应在可信仓库中使用。 |
| `/new` | 新建会话。 |
| `/resume` | 恢复已保存会话。 |

## 官方启动参数

当前官方二进制可通过 `grok --help` 查看其精确参数。常用选项包括：

```bash
# 在指定工作目录启动
grok --cwd /path/to/project

# 带首条提示启动
grok --prompt "阅读当前仓库并说明入口"

# 单轮运行后退出
grok --single-turn --prompt "总结当前改动"

# 自动批准工具操作，只用于可信目录
grok --yolo
```

不要把社区 CLI 的 `--base-url`、`--session`、`--format` 等参数套用到官方 Grok Build。中转地址、模型和认证应通过 [Code80 中转配置](./config) 中的 `~/.grok/config.toml` 管理。

## 模型选择提示

`/model` 只显示当前模型时，通常是模型目录未加载。确认：

1. `XAI_API_KEY` 在启动 `grok` 的进程中可用。
2. 配置包含 `models_base_url = "https://code.ai80.vip/v1"`。
3. 重启 Grok Build 后再打开 `/model`。

详见[排障与常见问题](./faq)。
