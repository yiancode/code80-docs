---
description: Grok CLI 安装教程，覆盖 macOS、Linux、Windows、Bun 备用安装、版本更新和同名程序冲突排查
---

# Grok CLI 安装详解

本教程使用 [superagent-ai/grok-cli](https://github.com/superagent-ai/grok-cli)。它的 npm 包名是 `grok-dev`，安装后的命令名是 `grok`。

::: warning 不要装错同名项目
旧包 `@vibe-kit/grok-cli` 也会安装名为 `grok` 的命令，但它不是本教程使用的当前版本。安装完成后务必检查路径和版本。
:::

## 支持范围

官方安装脚本当前提供以下预编译程序：

| 系统 | 脚本安装支持 |
|------|--------------|
| macOS Apple Silicon | 支持 |
| macOS Intel | 不支持预编译程序，尝试 Bun 安装 |
| Linux x64 | 支持 |
| Linux ARM64 | 不支持预编译程序，尝试 Bun 安装 |
| Windows x64 | 支持 Git Bash / MSYS / Cygwin；也可使用 WSL |

交互界面建议使用 WezTerm、Alacritty、Ghostty 或 Kitty 等现代终端。

## macOS

### 安装

```bash
curl -fsSL https://raw.githubusercontent.com/superagent-ai/grok-cli/main/install.sh | bash
```

脚本会把程序安装到：

```text
~/.grok/bin/grok
```

### 验证

```bash
command -v grok
grok --version
```

本教程核验版本是 `1.1.7`。如果输出 `0.0.34`，说明当前命中的是旧的 `@vibe-kit/grok-cli`。

如果当前终端仍找不到命令，重新加载 shell：

```bash
source ~/.zshrc
rehash
```

使用内置 `computer` 子代理控制桌面时，还需要在“系统设置 → 隐私与安全性 → 辅助功能”中授权终端。普通代码任务不需要这项权限。

## Linux

### 安装

```bash
curl -fsSL https://raw.githubusercontent.com/superagent-ai/grok-cli/main/install.sh | bash
```

### 验证

```bash
command -v grok
grok --version
```

如果 PATH 尚未更新，bash 用户可以执行：

```bash
source ~/.bashrc
hash -r
```

Grok CLI 的 Shuru 沙箱只支持 macOS 14+ Apple Silicon。Linux 可以正常使用主机模式，但不要启用 `--sandbox`，也不要使用依赖 Shuru 的 `/verify` 或 `--verify`。

## Windows

### 方式一：使用 WSL

推荐先安装 WSL，然后在 WSL 的 Linux 终端中执行：

```bash
curl -fsSL https://raw.githubusercontent.com/superagent-ai/grok-cli/main/install.sh | bash
```

### 方式二：使用 Bun

在 PowerShell 中安装 Bun：

```powershell
powershell -c "irm bun.sh/install.ps1 | iex"
```

重新打开 PowerShell 后安装 Grok CLI：

```powershell
bun add -g grok-dev
grok --version
```

也可以在 Git Bash、MSYS 或 Cygwin 中运行官方安装脚本。

## Bun 备用安装

已经安装 Bun 的用户可以在各平台执行：

```bash
bun add -g grok-dev
```

脚本安装会提供内置更新与卸载命令；Bun 安装则通过 Bun 自己管理包版本。

## 更新与卸载

使用官方脚本安装时：

```bash
grok update
grok uninstall --dry-run
grok uninstall --keep-config
```

- `grok update`：更新到最新版本
- `--dry-run`：只预览卸载内容
- `--keep-config`：卸载程序但保留 `~/.grok` 配置

## 检查同名程序冲突

macOS / Linux：

```bash
type -a grok
command -v grok
grok --version
```

Windows PowerShell：

```powershell
Get-Command grok -All
grok --version
```

脚本安装时，`command -v grok` 应优先返回 `~/.grok/bin/grok`。如果命中了旧的 Node.js 全局目录，并且界面仍显示 `grok-code-fast-1`，可以先直接使用正确程序：

```bash
~/.grok/bin/grok -m grok-4.3
```

也可以确保脚本安装目录排在 PATH 前面，并把这一行加入 `~/.zshrc` 或 `~/.bashrc`：

```bash
export PATH="$HOME/.grok/bin:$PATH"
```

确认不再需要旧包后，根据当初的安装方式执行其中一条卸载命令，再刷新 shell 缓存：

```bash
npm uninstall -g @vibe-kit/grok-cli
bun remove -g @vibe-kit/grok-cli  # 旧包由 Bun 安装时使用
hash -r  # bash
rehash   # zsh
```

## 安装失败排查

### curl 不可用

确认系统已经安装 curl：

```bash
curl --version
```

### 脚本无法识别平台

先检查架构：

```bash
uname -s
uname -m
```

macOS Intel 和 Linux ARM64 当前没有官方预编译程序，可以改用 Bun 安装，或关注项目后续发布。

### 界面显示异常

- 更新到最新版 Grok CLI
- 换用支持真彩色和 Unicode 的现代终端
- 在脚本中只做一次性任务时改用 `grok --prompt`，无头模式不依赖完整 TUI 渲染
