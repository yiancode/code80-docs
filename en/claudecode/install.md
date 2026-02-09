# Claude Code Installation

Claude Code requires Node.js 18+. Here are the installation steps for each platform.

## Prerequisites

- Node.js 18 or higher
- npm (comes with Node.js)

## macOS

### Recommended: Homebrew

```bash
brew install node
```

::: details Don't have Homebrew? Install it first
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
:::

::: details Other installation methods
Visit [nodejs.org](https://nodejs.org/) to download the LTS version.
:::

### Verify Node.js

```bash
node --version
```

### Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### Verify Installation

```bash
claude --version
```

## Windows

### Recommended: winget

```bash
winget install OpenJS.NodeJS.LTS
```

::: details Other installation methods
```bash
# Chocolatey
choco install nodejs-lts

# Scoop
scoop install nodejs-lts
```

Or visit [nodejs.org](https://nodejs.org/) to download the LTS version.
:::

### Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

> Run as Administrator if you encounter permission issues.

### Verify Installation

```bash
claude --version
```

## Linux

### Recommended: NodeSource

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

::: details Other installation methods
```bash
# Fedora/RHEL
sudo dnf install nodejs
```
:::

### Install Claude Code

```bash
sudo npm install -g @anthropic-ai/claude-code
```

### Verify Installation

```bash
claude --version
```

## Common Issues

### Permission Errors

- **macOS/Linux**: Prefix with `sudo`
- **Windows**: Run terminal as Administrator

### Slow npm Downloads

Use a mirror registry:

```bash
npm config set registry https://registry.npmmirror.com
npm install -g @anthropic-ai/claude-code
```

### Node.js Version Too Low

Use [nvm](https://github.com/nvm-sh/nvm) to manage Node.js versions:

```bash
nvm install 18
nvm use 18
```
