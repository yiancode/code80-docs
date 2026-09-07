---
description: Codex CLI 快速开始：一键脚本、交给 Agent，或手工 3 步配置，三选一即可
---

# Codex CLI

OpenAI 官方 AI 编程助手命令行工具。通过 Code80 接入时，下面三种方式**任选一种**，做完即可开始用，不要顺着全做一遍。

## 选一种方式即可

| 方式 | 适合谁 | 做什么 |
|------|--------|--------|
| [方式一：一键脚本](#方式一-一键脚本安装推荐) | 自己有终端，想最快配好 | 跑一条命令 |
| [方式二：交给 Agent](#agent-setup) | 已经在用 Claude Code / Grok | 复制提示词让它代装 |
| [方式三：手工配置](#方式三-手工三步配置) | 想看清楚每一步 | 自己装 CLI、写配置 |

配完都要彻底退出 Codex 再用**新对话**测试。只关窗口不够。

## 方式一：一键脚本安装（推荐）

::: danger 会改你现有的 Codex 配置
脚本会改 `~/.codex/config.toml` 以接入 Code80。已有文件会先备份，但若选择**覆盖**，oh-my-codex、MCP、hooks 等自定义内容会从当前文件里消失。已装 oh-my-codex 的人请选 **保留现有配置，只改接入**。不确定就先备份，或用下面的恢复脚本改回官方 OpenAI。
:::

macOS / Linux：

```bash
curl -fsSL https://docs.ai80.vip/codex/install.sh | bash
```

Windows（PowerShell，不是 CMD）：

```powershell
irm https://docs.ai80.vip/codex/install.ps1 | iex
```

系统自带 Windows PowerShell 5.1 若出现中文乱码，改用：

```powershell
iex ([Text.Encoding]::UTF8.GetString((iwr -useb https://docs.ai80.vip/codex/install.ps1).RawContentStream.ToArray()).TrimStart([char]0xFEFF))
```

脚本会安装官方 `@openai/codex`，并**交互询问** Code80 **OpenAI 分组** 的 API Key。Windows 同样会问。输入时屏幕上会显示你打的内容，核对无误再回车，避免连打几次把 Key 写错。Key 只写入 `~/.codex/auth.json`，脚本不会再打印一遍。不要截图或把终端日志发到群里。

不想交互输入时，用环境变量跳过提示：

macOS / Linux（变量写在管道**右边**，写在 `curl` 前面 bash 读不到）：

```bash
curl -fsSL https://docs.ai80.vip/codex/install.sh | CODE80_API_KEY='你的Key' bash
```

Windows（先设变量，再跑脚本，必须在同一窗口）：

```powershell
$env:CODE80_API_KEY='你的Key'
irm https://docs.ai80.vip/codex/install.ps1 | iex
```

检测到已有配置时会问你：

1. **接入 Code80，保留现有配置**（oh-my-codex / MCP / hooks 等继续留着）
2. **用 Code80 推荐模板覆盖**（先备份）
3. **取消**

无终端交互时默认选项 1。分平台说明见 [安装详解](./install)。

做完方式一就可以用了，不必再做方式二或方式三。

::: warning Windows：不要在 system32 里启动，也不要写 service_tier
管理员打开 PowerShell 时，默认目录是 `C:\WINDOWS\system32`。必须先 `cd` 到你的项目再运行 `codex`，否则会 `Reconnecting`，还会把系统目录写成信任项目。

config.toml 里**不要写** `service_tier = "fast"` 或 `"priority"`。Code80 不走官方这几档，写了会断流重连。已经写过的删掉这一行，并删掉：

```toml
[projects.'c:\windows\system32']
trust_level = "trusted"
```

任务管理器结束所有 `codex` 进程后，在项目目录开新对话。
:::

::: warning Windows：旧配置若还不能搜，检查这两项
新模板默认 `web_search = "live"`、`network_access = true`。以前装过的人若仍是 `cached` / `false`，问新闻、跑 `Invoke-WebRequest` 会报「无法连接到远程服务器」。改成：

```toml
web_search = "live"

[sandbox_workspace_write]
network_access = true
```

`network_access = true` 之后，若 `curl https://www.google.com` 仍超时，是本机到 Google 不通（国内常见），不是 Codex 没联网。`https://code.ai80.vip` 能聊就说明 API 网络是通的。换能打开的来源，或把链接发给它。
:::

想改回 OpenAI 官方（不用 Code80 中转）时：

```bash
curl -fsSL https://docs.ai80.vip/codex/restore.sh | bash
```

```powershell
irm https://docs.ai80.vip/codex/restore.ps1 | iex
```

恢复脚本可选择：还原安装前备份，或只把 `model_provider` 切回 `openai`。

切回官方后按这个顺序做，**不要立刻提问或跑 `codex --yolo`**：

1. 打开 Codex
2. 输入 `/logout`（清掉 `auth.json` 里的 Code80 凭据）
3. 按提示用 ChatGPT 登录
4. 用新对话测试

漏掉 `/logout` 会带着 Code80 Key 打 `api.openai.com`，立刻 `401 Incorrect API key`。`gpt-5.6-terra` / `sol` / `luna` 是 Code80 模型 ID，官方没有。

## 方式二：交给 Agent 安装并配置 {#agent-setup}

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
web_search = "live"
personality = "pragmatic"
forced_login_method = "api"

[model_providers.codex]
name = "codex"
base_url = "https://code.ai80.vip"
wire_api = "responses"
requires_openai_auth = true
supports_websockets = false

[sandbox_workspace_write]
network_access = true

5. base_url 用 https://code.ai80.vip，末尾不要加 /v1。requires_openai_auth 必须为 true（Codex 0.149.0 起 false 不会继承 auth.json，会 401）。supports_websockets 必须为 false（否则每次提问会卡在「正在重新连接 1/5 … 5/5」）。
6. 把 API Key 写进 ~/.codex/auth.json，格式为 {"OPENAI_API_KEY": "<key>"}。macOS/Linux 执行 chmod 700 ~/.codex 和 chmod 600 ~/.codex/config.toml ~/.codex/auth.json。Windows 路径是 %USERPROFILE%\.codex\。
7. 配置完成后让我彻底退出再打开 Codex（macOS Cmd+Q / Windows 结束进程 / CLI 退出后重新运行），并用新对话测试。不要只关窗口。不要在输出中显示完整 Key。
8. 若出现 401、API_KEY_REQUIRED、正在重新连接、模型不存在、或 base_url 带了 /v1，按 Code80 Codex 文档定位：自定义 provider 必须 requires_openai_auth=true 且 supports_websockets=false；模型只用 gpt-5.6-terra / gpt-5.6-sol / gpt-5.6-luna。说明证据和下一步，不要用非官方 Codex 包规避。
```

::: tip 复制后记得准备 Key
Agent 找不到现有密钥时会向你要 Code80 **OpenAI 分组** 的 API Key。不要把 Key 贴进仓库、`AGENTS.md` 或聊天截图。
:::

做完方式二就可以用了，不必再跑脚本或手工改配置。

## 方式三：手工三步配置

已经做过方式一或方式二的人跳过本节。想自己看清每一步时，按下面做。

### 1. 安装 CLI 工具

```bash
npm install -g @openai/codex
```

需要 Node.js 22+。分平台步骤见 [安装详解](./install)。

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
web_search = "live"
forced_login_method = "api"

[model_providers.codex]
name = "codex"
base_url = "https://code.ai80.vip"
wire_api = "responses"
requires_openai_auth = true
supports_websockets = false

[sandbox_workspace_write]
network_access = true
```

日常默认用 `gpt-5.6-terra`。复杂任务换成 `gpt-5.6-sol`，图快图省用 `gpt-5.6-luna`。不要写 `gpt-5.6` 或 `gpt-luna`。

`requires_openai_auth = true` 让 0.149.0+ 继续读 `auth.json`；`supports_websockets = false` 避免每次提问先卡「正在重新连接」。完整说明见 [配置详解](./config)。

编辑 `~/.codex/auth.json`：

```json
{
  "OPENAI_API_KEY": "your-api-key"
}
```

将 `your-api-key` 替换为你在 Code80 平台获取的 **OpenAI 分组** API Key。

### 3. 开始使用

```bash
cd your-project
codex
```

Windows 先 `cd` 到项目，不要在 `C:\WINDOWS\system32` 里启动。不要在 config.toml 里写 `service_tier`。

首次启动流程：选择开发环境 → 配置偏好 → 开始 AI 辅助编程。

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

- [安装详解](./install) - 一键脚本、恢复官方配置与分平台步骤
- [配置详解](./config) - 完整的配置文件说明
- [快捷键速查](./shortcuts) - 常用快捷键与高频交互命令
- [使用技巧](./tips) - 高级用法和效率提升
- [常见问题](./faq) - 遇到问题看这里
