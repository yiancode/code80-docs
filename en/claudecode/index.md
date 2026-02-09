# Claude Code

Anthropic's official AI coding assistant CLI tool.

## Quick Start

3 steps to use Claude Code via the Code80 platform:

### 1. Install CLI Tool

```bash
npm install -g @anthropic-ai/claude-code
```

### 2. Configure API

Edit `~/.claude/settings.json`:

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "your-api-key",
    "ANTHROPIC_BASE_URL": "https://your-code80-domain.com"
  }
}
```

> Replace `your-api-key` with your API Key from the Code80 platform, and `your-code80-domain.com` with your Code80 service address.

### 3. Start Using

```bash
cd your-project
claude
```

First launch: Choose theme → Confirm safety notice → Configure terminal → Trust workspace → Start coding.

## Use Cases

- Code writing and completion
- Code review and refactoring
- Bug investigation and fixing
- Project architecture design
- Documentation writing

## Next Steps

- [Installation](./install) - Detailed installation steps per platform
- [Configuration](./config) - Complete config file reference
- [Tips & Tricks](./tips) - Advanced usage and productivity tips
- [FAQ](./faq) - Troubleshooting guide
