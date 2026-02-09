# Claude Code 安装详解

Claude Code 需要 Node.js 18+ 环境。以下是各平台的安装步骤。

## 前置条件

- Node.js 18 或更高版本
- npm（随 Node.js 一起安装）

## macOS

### 推荐方法：Homebrew

```bash
brew install node
```

::: details 没有 Homebrew？先安装它
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
:::

::: details 其他安装方式
访问 [nodejs.org](https://nodejs.org/) 下载 LTS 版本安装。
:::

### 验证 Node.js

```bash
node --version
```

### 安装 Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### 验证安装

```bash
claude --version
```

## Windows

### 推荐方法：winget

```bash
winget install OpenJS.NodeJS.LTS
```

::: details 其他安装方式
```bash
# Chocolatey
choco install nodejs-lts

# Scoop
scoop install nodejs-lts
```

或者访问 [nodejs.org](https://nodejs.org/) 下载 LTS 版本安装。
:::

### 验证 Node.js

```bash
node --version
```

### 安装 Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

> 如遇权限问题，请以管理员身份运行命令提示符或 PowerShell。

### 验证安装

```bash
claude --version
```

## Linux

### 推荐方法：NodeSource

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

::: details 其他安装方式
```bash
# Fedora/RHEL
sudo dnf install nodejs
```

或者访问 [nodejs.org](https://nodejs.org/) 下载 LTS 版本安装。
:::

### 验证 Node.js

```bash
node --version
```

### 安装 Claude Code

```bash
sudo npm install -g @anthropic-ai/claude-code
```

### 验证安装

```bash
claude --version
```

## 常见安装问题

### 权限错误

- **macOS/Linux**：在命令前加 `sudo`
- **Windows**：以管理员身份运行终端

### npm 网络问题

如果 npm 下载较慢，可以使用国内镜像：

```bash
npm config set registry https://registry.npmmirror.com
npm install -g @anthropic-ai/claude-code
```

### Node.js 版本过低

确保安装的是 Node.js 18 或更高版本。可以使用 [nvm](https://github.com/nvm-sh/nvm) 管理多个 Node.js 版本：

```bash
nvm install 18
nvm use 18
```
