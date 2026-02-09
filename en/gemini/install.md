# Gemini CLI Installation

Gemini CLI requires Node.js 20+. Here are the installation steps for each platform.

## Prerequisites

- Node.js 20 or higher
- npm (comes with Node.js)

## macOS

```bash
brew install node
npm install -g @google/gemini-cli
gemini --version
```

## Windows

```bash
winget install OpenJS.NodeJS.LTS
npm install -g @google/gemini-cli
gemini --version
```

## Linux

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g @google/gemini-cli
gemini --version
```

## Common Issues

### Node.js version requirement

Gemini CLI requires Node.js 20+. Use nvm:

```bash
nvm install 20
nvm use 20
```

### Slow npm downloads

Use a mirror registry:

```bash
npm config set registry https://registry.npmmirror.com
npm install -g @google/gemini-cli
```
