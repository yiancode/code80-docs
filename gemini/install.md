---
description: Gemini CLI 安装教程，覆盖 macOS、Linux、Windows 全平台，Node.js 20+ 环境配置
---

# Gemini CLI 安装详解

Gemini CLI 需要 Node.js 20+ 环境。以下是各平台的安装步骤。

## 前置条件

- Node.js 20 或更高版本
- npm（随 Node.js 一起安装）

## macOS

### 安装 Node.js

```bash
brew install node
```

### 安装 Gemini CLI

```bash
npm install -g @google/gemini-cli
```

### 验证安装

```bash
gemini --version
```

## Windows

### 安装 Node.js

```bash
winget install OpenJS.NodeJS.LTS
```

### 安装 Gemini CLI

```bash
npm install -g @google/gemini-cli
```

### 验证安装

```bash
gemini --version
```

## Linux

### 安装 Node.js

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 安装 Gemini CLI

```bash
sudo npm install -g @google/gemini-cli
```

### 验证安装

```bash
gemini --version
```

## 常见安装问题

### Node.js 版本要求

Gemini CLI 需要 Node.js 20+。使用 nvm 管理版本：

```bash
nvm install 20
nvm use 20
```

### 网络问题

如果 npm 下载较慢，使用国内镜像：

```bash
npm config set registry https://registry.npmmirror.com
npm install -g @google/gemini-cli
```
