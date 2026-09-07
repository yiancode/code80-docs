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

Windows 同样会交互询问 Key，输入时会显示，核对后再回车。请用 **PowerShell**，不要用 CMD。系统自带 Windows PowerShell 5.1 的 `irm` 可能把 UTF-8 中文解成乱码，新版脚本会自动按 UTF-8 重新加载。仍乱码时改用：

```powershell
iex ([Text.Encoding]::UTF8.GetString((iwr -useb https://docs.ai80.vip/codex/install.ps1).RawContentStream.ToArray()).TrimStart([char]0xFEFF))
```

不想交互时，先设变量再跑（同一窗口）：

```powershell
$env:CODE80_API_KEY='你的Key'
irm https://docs.ai80.vip/codex/install.ps1 | iex
```

已有 `config.toml` 时脚本会问：保留现有配置（oh-my-codex 等）只改接入，还是覆盖成推荐模板。无交互时默认保留。覆盖前会备份。

### Windows 上 iex 报意外的属性 CmdletBinding / param

`iex` 把下载内容当表达式执行，`[CmdletBinding()]` 和 `param()` 不能写在文件头注释后面。新版脚本已去掉这两行。请重新跑：

```powershell
iex ([Text.Encoding]::UTF8.GetString((iwr -useb https://docs.ai80.vip/codex/install.ps1).RawContentStream.ToArray()).TrimStart([char]0xFEFF))
```

### Windows 上中文乱码，或 node 报 endsWith(\\n)

系统自带 **Windows PowerShell 5.1**（`PS C:\WINDOWS\system32>`）有两个问题：

1. `irm` 常把 UTF-8 脚本按 Latin-1 解码，中文变成 `ä¸€é...` 这类乱码
2. 调用 `node -e` 时会剥掉参数里的双引号，于是 `endsWith("\n")` 变成 `endsWith(\n)` 报 SyntaxError

请用 **PowerShell** 重新跑新版脚本（会自动按 UTF-8 加载，不再把 JS 塞进 `node -e`）：

```powershell
irm https://docs.ai80.vip/codex/install.ps1 | iex
```

仍乱码时：

```powershell
iex ([Text.Encoding]::UTF8.GetString((iwr -useb https://docs.ai80.vip/codex/install.ps1).RawContentStream.ToArray()).TrimStart([char]0xFEFF))
```

或把 `install.ps1` 和 `install.cmd` 下到同一目录后双击 `install.cmd`。不要用 CMD 直接 `irm`。

### 一键脚本把我的 oh-my-codex 弄没了

先看 `~/.codex/config.toml.bak.*` 或 `.code80-last-backup`。然后：

```bash
curl -fsSL https://docs.ai80.vip/codex/restore.sh | bash
```

选 **1）恢复安装前的备份**。Windows 用 `irm https://docs.ai80.vip/codex/restore.ps1 | iex`。

### 想不用 Code80、改回官方 OpenAI

同样跑恢复脚本，选 **2）只切回官方 openai provider**。然后打开 Codex，先输入 `/logout`，再按提示用 ChatGPT 登录。Code80 的 Key 打不通 `api.openai.com`。

### 跑了恢复脚本后 401 Incorrect API key，URL 是 api.openai.com

这是漏了 `/logout` 的典型结果：`model_provider` 已经是 `openai`，但 `auth.json` 里还是 Code80 Key。官方会报 `Incorrect API key provided`，请求打到 `api.openai.com` 或 `wss://api.openai.com`。

- **确认要用官方 OpenAI**：打开 Codex，输入 `/logout`，等登录提示出来后用 ChatGPT 登录，再用新对话测试。不要带着 Code80 Key 直接提问，也不要用 `gpt-5.6-terra` / `gpt-5.6-sol` / `gpt-5.6-luna`。
- **其实还想用 Code80**：把恢复时另存的文件拷回去（选最新的 `config.toml.code80.bak.*`），彻底退出再开：

```bash
cp ~/.codex/config.toml.code80.bak.时间戳 ~/.codex/config.toml
```

或重跑[一键安装](/codex/#方式一-一键脚本安装推荐)。

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

### 每次提问都卡在「正在重新连接 1/5 … 5/5」/ Reconnecting

先看是哪一种。

**缺 `supports_websockets = false`：** Codex 默认先走 WebSocket，中转往往 HTTPS 通、WSS 不通。打开 `%USERPROFILE%\.codex\config.toml`（一般是 `C:\Users\你的用户名\.codex\config.toml`），确认是这样，不要改内置 `[model_providers.openai]`：

```toml
model_provider = "codex"

[model_providers.codex]
name = "codex"
base_url = "https://code.ai80.vip"
wire_api = "responses"
requires_openai_auth = true
supports_websockets = false
```

**Windows 上 provider 已经对，仍 Reconnecting：** 实测是下面两条，去掉就好。

1. **不要在 `C:\WINDOWS\system32` 启动。** 管理员 PowerShell 默认就在这里。先 `cd` 到项目。config 里若有 `[projects.'c:\windows\system32']`，整段删掉。
2. **删掉 `service_tier = "fast"` / `"priority"`。** Code80 不支持官方服务档，写了会断流，随后 `Reconnecting` / `Stream disconnected`。

然后任务管理器结束所有 `codex` 进程（只关窗口不够），在项目目录开新对话。

若这两条都没有、WebSocket 也关了，仍出现 `当前为官方服务过载`，那是上游把流掐了，等一会儿再问。

### config.toml 格式报错

TOML 格式比较严格，注意：
- 字符串值要用双引号
- `[section]` 标记要独占一行
- 布尔值用 `true` / `false`
- **根键必须写在所有 `[table]` 前面**，顺序反了会直接解析失败

## 使用问题

### 说无法联网搜索 / Invoke-WebRequest 无法连接到远程服务器

常见是这三件事叠在一起，不是 Key 失效：

1. **沙箱没出网。** 新模板默认 `network_access = true`。旧配置若是 `false`，模型用 PowerShell `Invoke-WebRequest` 拉网页会报「无法连接到远程服务器」。改成：

```toml
[sandbox_workspace_write]
network_access = true
```

2. **搜索还是缓存。** 新模板默认 `web_search = "live"`。旧配置若是 `"cached"`，不是实时上网。问「今天有什么 AI 新闻」改成 `"live"`。

3. **目标网站当前网络打不开。** 配置已经是 `network_access = true`、`web_search = "live"` 时，若 `Invoke-WebRequest` / `curl` 访问 Google、Reddit、Reuters 仍报「无法连接到远程服务器」或 `Connection timed out`，说明**本机到这些站点不通**，不是沙箱、也不是 API Key。Codex 已经在和 `https://code.ai80.vip` 对话，网络是通的。

本机可先测：

```powershell
curl.exe -I --max-time 10 https://code.ai80.vip
curl.exe -I --max-time 10 https://www.baidu.com
curl.exe -I --max-time 10 https://www.google.com
```

前两个通、Google 超时，就是站点访问限制。换国内能打开的来源，或把链接/截图发给它。Code80 不一定提供官方 `web_search` 工具，模型常会改用本机 `iwr`/`curl` 去抓 Google，在国内就会失败。

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
| 401 | 认证失败 | 接 Code80：检查 `auth.json` 的 Key，以及自定义 provider 是否 `requires_openai_auth = true`。若 URL 已是 `api.openai.com` 且刚跑过恢复脚本：先 `/logout` 再登录，见上面「跑了恢复脚本后 401」 |
| 403 | 无权限 | 确认分组权限 |
| 429 | 请求过多 | 等待后重试 |
| 500 | 服务器错误 | 稍后重试 |
