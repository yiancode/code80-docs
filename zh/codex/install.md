# Codex CLI 安装详解

Codex CLI 需要 Node.js 22+ 环境。以下是各平台的安装步骤。

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
