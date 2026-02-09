# Codex CLI FAQ

## Installation

### Node.js 22+ required

Use nvm to manage versions:

```bash
nvm install 22
nvm use 22
```

### bubblewrap error on Linux

```bash
sudo apt-get install bubblewrap
```

## Configuration

### Connection failures after config

Check:
1. `base_url` ends with `/v1` (required for Codex CLI)
2. API Key is correct
3. API Key group is for the OpenAI platform

### config.toml format errors

TOML format is strict:
- String values need double quotes
- `[section]` markers on their own line
- Boolean values: `true` / `false`

## Error Codes

| Code | Description | Solution |
|------|-------------|----------|
| 401 | Auth failed | Check auth.json API Key |
| 403 | No permission | Verify group permissions |
| 429 | Too many requests | Wait and retry |
| 500 | Server error | Try again later |
