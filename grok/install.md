---
description: xAI 官方 Grok Build 的安装、升级、PATH 验证与非官方 CLI 清理说明
---

# 官方安装

## 安装最新稳定版

macOS、Linux 或 Git Bash 使用 xAI 官方安装脚本：

```bash
curl -fsSL https://x.ai/cli/install.sh | bash
```

Windows PowerShell 使用：

```powershell
irm https://x.ai/cli/install.ps1 | iex
```

验证二进制：

```bash
command -v grok
grok --version
```

macOS/Linux 的官方脚本通常安装到 `~/.grok/bin/grok`。预期 `command -v grok` 指向该目录或官方安装器创建的等价路径。

## `x.ai` 下载失败时

官方安装器会在主站不可达时回退到 xAI 的官方 GCS 发行源。请保留官方安装脚本，不要因为下载失败而改装同名社区 npm 包。

若脚本本身无法下载，先检查网络、代理和 TLS；恢复网络后重试。不要为了绕过 TLS 校验而关闭证书验证。

## 清理非官方同名 CLI

先确认当前命令来源：

```bash
command -v grok
which -a grok
```

如果看到社区 npm 包，先卸载它，再安装官方发行版。例如：

```bash
npm uninstall -g @vibe-kit/grok-cli
npm uninstall -g grok-dev
hash -r
```

`@xai-official/grok` 曾发布过较早的 npm 启动器。即使它带有 xAI 名称，也可能不支持当前官方 Grok Build 的自定义模型配置。对于 Code80 中转，请优先使用官方安装脚本下载的当前二进制。

## `grok: command not found`

将官方目录加入 Shell PATH：

```bash
printf '\nexport PATH="$HOME/.grok/bin:$PATH"\n' >> ~/.zshrc
export PATH="$HOME/.grok/bin:$PATH"
hash -r
grok --version
```

第一行让新终端永久生效，第二行让当前 Shell 立即生效。Bash 用户应改写入 `~/.bashrc`。

## 升级

官方 Grok Build 安装完成后，使用：

```bash
grok update
grok --version
```

升级后复查 `command -v grok`。如果 PATH 又命中了旧 npm shim，先清理旧包并恢复 `~/.grok/bin` 的优先级。
