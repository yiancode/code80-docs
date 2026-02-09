# Codex CLI

OpenAI's official AI coding assistant CLI tool.

## Quick Start

3 steps to use Codex CLI via the Code80 platform:

### 1. Install CLI Tool

```bash
npm install -g @openai/codex
```

### 2. Configure API

Create the config directory:

```bash
mkdir -p ~/.codex
```

Edit `~/.codex/config.toml`:

```toml
model_provider = "code80"
model = "gpt-5.3-codex"
model_reasoning_effort = "high"
network_access = "enabled"
disable_response_storage = true
model_verbosity = "high"

[model_providers.code80]
name = "code80"
base_url = "https://your-code80-domain.com/v1"
wire_api = "responses"
requires_openai_auth = true
```

Edit `~/.codex/auth.json`:

```json
{
  "OPENAI_API_KEY": "your-api-key"
}
```

> Replace `your-api-key` with your API Key from the Code80 platform.

### 3. Start Using

```bash
cd your-project
codex
```

First launch: Select dev environment → Configure preferences → Start AI-assisted coding.

## Use Cases

- AI-assisted code generation
- Natural language to code
- Code completion and optimization
- Automated script writing

## Next Steps

- [Installation](./install) - Detailed installation steps per platform
- [Configuration](./config) - Complete config file reference
- [Tips & Tricks](./tips) - Advanced usage
- [FAQ](./faq) - Troubleshooting guide
