# Codex CLI Configuration

## Config File Locations

| File | macOS/Linux | Windows |
|------|-------------|----------|
| Main config | `~/.codex/config.toml` | `%USERPROFILE%\.codex\config.toml` |
| Auth file | `~/.codex/auth.json` | `%USERPROFILE%\.codex\auth.json` |

## Create Config Directory

```bash
# macOS/Linux
mkdir -p ~/.codex

# Windows
mkdir %USERPROFILE%\.codex
```

## config.toml

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

### Field Reference

| Field | Description |
|-------|-------------|
| `model_provider` | Provider name, must match key in `model_providers` |
| `model` | Model name to use |
| `model_reasoning_effort` | Reasoning depth: `low` / `medium` / `high` |
| `network_access` | Network access: `enabled` / `disabled` |
| `base_url` | Code80 API address, must include `/v1` |
| `wire_api` | API protocol, use `responses` |
| `requires_openai_auth` | Set to `true` for OpenAI-style auth |

## auth.json

```json
{
  "OPENAI_API_KEY": "your-api-key"
}
```

Replace `your-api-key` with your API Key from the Code80 platform.

## Applying Changes

Restart Codex CLI after modifying config files.
