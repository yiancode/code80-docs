# Codex CLI Installation

Codex CLI requires Node.js 22+. Here are the installation steps for each platform.

## Prerequisites

- Node.js 22 or higher
- npm (comes with Node.js)
- Linux users also need bubblewrap (for sandbox)

## macOS

```bash
brew install node
node --version  # Must be v22+
npm install -g @openai/codex
codex --version
```

## Windows

```bash
winget install OpenJS.NodeJS.LTS
npm install -g @openai/codex
codex --version
```

> Run as Administrator if you encounter permission issues.

## Linux

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install bubblewrap  # Required for sandbox
sudo npm install -g @openai/codex
codex --version
```

## Common Issues

### Node.js version requirement

Codex CLI requires Node.js 22+, which is higher than other tools. Use nvm:

```bash
nvm install 22
nvm use 22
```

### Missing bubblewrap on Linux

```bash
sudo apt-get install bubblewrap
```
