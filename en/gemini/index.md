# Gemini CLI

Google's official AI coding assistant CLI tool.

## Quick Start

3 steps to use Gemini CLI via the Code80 platform:

### 1. Install CLI Tool

```bash
npm install -g @google/gemini-cli
```

### 2. Configure API

Create `~/.gemini/.env`:

```bash
GOOGLE_GEMINI_BASE_URL=https://your-code80-domain.com/v1beta
GEMINI_API_KEY=your-api-key
GEMINI_MODEL=gemini-2.5-pro
```

Create `~/.gemini/settings.json`:

```json
{
  "theme": "system"
}
```

> Replace `your-api-key` with your API Key from the Code80 platform.

### 3. Start Using

```bash
cd your-project
gemini
```

Gemini CLI features: Large context window, Agent Mode auto-planning, Google Search integration.

## Use Cases

- Large context code analysis
- Agent mode for automatic task planning
- Web search-assisted coding
- Code generation and optimization

## Next Steps

- [Installation](./install) - Detailed installation steps per platform
- [Configuration](./config) - Complete config file reference
- [Tips & Tricks](./tips) - Advanced usage
- [FAQ](./faq) - Troubleshooting guide
