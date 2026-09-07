---
description: Codex CLI 常见问题，包括 401、正在重新连接、模型 ID、config.toml 格式和沙箱网络
---

# Codex CLI 常见问题

## 安装问题

### Node.js 版本需要 22+，比其他工具要求更高

Codex CLI 确实需要更高的 Node.js 版本。建议使用 nvm 管理多个版本：

```bash
nvm install 22
nvm use 22
```

### Linux 上报 bubblewrap 错误

安装 bubblewrap 沙箱工具：

```bash
sudo apt-get install bubblewrap
```

### 一键脚本卡住或要不到 Key

`curl ... | bash` 时脚本用 `/dev/tty` 读 Key。无 TTY 或不想交互时，把变量写在管道右边（写在 `curl` 前面 bash 读不到）：

```bash
curl -fsSL https://docs.ai80.vip/codex/install.sh | CODE80_API_KEY='你的Key' bash
```

Windows 请在 PowerShell 里运行 `irm ... | iex`，不要用 CMD。

已有 `config.toml` 时脚本会问：保留现有配置（oh-my-codex 等）只改接入，还是覆盖成推荐模板。无交互时默认保留。覆盖前会备份。

### 一键脚本把我的 oh-my-codex 弄没了

先看 `~/.codex/config.toml.bak.*` 或 `.code80-last-backup`。然后：

```bash
curl -fsSL https://docs.ai80.vip/codex/restore.sh | bash
```

选 **1）恢复安装前的备份**。Windows 用 `irm https://docs.ai80.vip/codex/restore.ps1 | iex`。

### 想不用 Code80、改回官方 OpenAI

同样跑恢复脚本，选 **2）只切回官方 openai provider**。之后用 ChatGPT 登录或官方 Key。Code80 的 Key 打不通 `api.openai.com`。

## 配置问题

### 配置后连接失败

检查以下几点：
1. `base_url` 末尾不要加 `/v1`
2. API Key 是否正确，且写在 `~/.codex/auth.json` 的 `OPENAI_API_KEY`
3. API Key 对应的分组是否是 OpenAI 平台
4. 自定义 provider 是否写了 `requires_openai_auth = true`（0.149.0 起必写）

### 升级到 0.149.0 后出现 401 / API_KEY_REQUIRED

自定义 provider 在 `requires_openai_auth = false` 时不再自动继承 `auth.json`。改成：

```toml
model_provider = "codex"

[model_providers.codex]
name = "codex"
base_url = "https://code.ai80.vip"
wire_api = "responses"
requires_openai_auth = true
supports_websockets = false
```

并保留 `auth.json`。不要改内置 `openai` provider。保存后彻底退出再打开。

### 每次提问都卡在「正在重新连接 1/5 … 5/5」

Codex 默认先走 WebSocket。中转往往 HTTPS 通、WSS 不通，于是重试 5 次再降级 HTTP，看起来像卡住。

在自定义 provider 里写 `supports_websockets = false`，不要去改内置 `[model_providers.openai]`。全文件只能有一个 `model_provider`。改完必须彻底退出（macOS Cmd+Q / Windows 结束进程），并用新对话测试。

### config.toml 格式报错

TOML 格式比较严格，注意：
- 字符串值要用双引号
- `[section]` 标记要独占一行
- 布尔值用 `true` / `false`
- **根键必须写在所有 `[table]` 前面**，顺序反了会直接解析失败

## 使用问题

### 运行时报权限错误 / 装不了依赖

确认两件事：

1. `sandbox_mode = "workspace-write"`
2. `[sandbox_workspace_write]` 里 `network_access = true`

旧写法 `network_access = "enabled"` 已经失效。

### 如何查看当前使用的模型？

查看 `~/.codex/config.toml` 中的 `model` 字段。Code80 上请写成精确 ID：`gpt-5.6-terra`、`gpt-5.6-sol` 或 `gpt-5.6-luna`。不要写 `gpt-5.6` 或 `gpt-luna`。

### 写成 gpt-5.6 报模型不存在

`gpt-5.6` 是官方文档里的家族别名，Code80 不提供这个 ID。改成：

- 日常：`gpt-5.6-terra`
- 复杂：`gpt-5.6-sol`
- 图快：`gpt-5.6-luna`

## 错误码对照

| 错误码 | 说明 | 解决方法 |
|--------|------|----------|
| 401 | 认证失败 | 检查 `auth.json` 的 Key，以及自定义 provider 是否 `requires_openai_auth = true` |
| 403 | 无权限 | 确认分组权限 |
| 429 | 请求过多 | 等待后重试 |
| 500 | 服务器错误 | 稍后重试 |
