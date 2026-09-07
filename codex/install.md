---
description: Codex CLI 安装教程：macOS/Windows 一键脚本、Node.js 22+、bubblewrap 与手工安装步骤
---

# Codex CLI 安装详解

Codex CLI 需要 Node.js 22+ 环境。最快的方式是跑一键脚本：装官方 CLI、写入 Code80 推荐配置、把 Key 放进 `auth.json`。

## 一键安装配置

### macOS / Linux

在终端执行：

```bash
curl -fsSL https://docs.ai80.vip/codex/install.sh | bash
```

脚本会通过 `/dev/tty` 向你要 Code80 **OpenAI 分组** 的 API Key，不会把 Key 打到屏幕上。不想交互时，把变量写在管道**右边**（写在 `curl` 前面 bash 读不到）：

```bash
curl -fsSL https://docs.ai80.vip/codex/install.sh | CODE80_API_KEY='你的Key' bash
```

### Windows

在 **PowerShell**（不是 CMD）执行：

```powershell
irm https://docs.ai80.vip/codex/install.ps1 | iex
```

若提示无法运行脚本：

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

也可以把下面两个文件下到同一目录，双击 `install.cmd`：

- https://docs.ai80.vip/codex/install.ps1
- https://docs.ai80.vip/codex/install.cmd

脚本会：

1. 检查 / 安装 Node.js 22+
2. `npm install -g @openai/codex`
3. 写入 `~/.codex/config.toml`（已有文件会先备份）
4. 把 Key 写入 `~/.codex/auth.json`，权限收紧为当前用户
5. 固定 `requires_openai_auth = true`、`supports_websockets = false`，避免 0.149.0 的 401 和「正在重新连接」

默认模型是 `gpt-5.6-terra`。不要写 `gpt-5.6` 或 `gpt-luna`。

配完必须彻底退出 Codex 再开，并用**新对话**测试。只关窗口不够。

不想跑脚本，也可以把[概述页的 Agent 提示词](/codex/#agent-setup)复制给 Claude Code / Grok，让 Agent 代装。

## 前置条件

- Node.js 22 或更高版本
- npm（随 Node.js 一起安装）
- Linux 用户还需要 bubblewrap（沙箱运行）

## macOS

### 安装 Node.js

```bash
brew install node
```

### 验证版本

```bash
node --version  # 需要 v22+
```

### 安装 Codex CLI

```bash
npm install -g @openai/codex
```

### 验证安装

```bash
codex --version
```

## Windows

### 安装 Node.js

```bash
winget install OpenJS.NodeJS.LTS
```

::: details 其他安装方式
```bash
choco install nodejs-lts
scoop install nodejs-lts
```
:::

### 安装 Codex CLI

```bash
npm install -g @openai/codex
```

> 如遇权限问题，请以管理员身份运行。

### 验证安装

```bash
codex --version
```

## Linux

### 安装 Node.js

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 安装沙箱依赖

Codex CLI 在 Linux 上需要 bubblewrap 来运行沙箱环境：

```bash
sudo apt-get install bubblewrap
```

### 安装 Codex CLI

```bash
sudo npm install -g @openai/codex
```

### 验证安装

```bash
codex --version
```

## 常见安装问题

### Node.js 版本不够

Codex CLI 要求 Node.js 22+，比 Claude Code 的要求更高。使用 nvm 管理版本：

```bash
nvm install 22
nvm use 22
```

### Linux 缺少 bubblewrap

```bash
sudo apt-get install bubblewrap
```
