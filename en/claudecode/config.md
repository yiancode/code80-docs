# Claude Code Configuration

## Config File Location

| Platform | Path |
|----------|------|
| macOS/Linux | `~/.claude/settings.json` |
| Windows | `%USERPROFILE%\.claude\settings.json` |

## Config Format

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "your-api-key",
    "ANTHROPIC_BASE_URL": "https://your-code80-domain.com"
  }
}
```

## Field Reference

### `env.ANTHROPIC_AUTH_TOKEN`

Your API Key, generated on the Code80 platform's "API Keys" page.

- Format: String starting with `sk-`
- Select the **Anthropic platform** group when creating the key

### `env.ANTHROPIC_BASE_URL`

The Code80 platform API address.

- Format: Full URL, e.g. `https://api.example.com`
- Do not append `/v1` or other path suffixes

## Complete Example

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-xxxxxxxxxxxxxxxxxxxxxxxx",
    "ANTHROPIC_BASE_URL": "https://api.ai80.vip"
  }
}
```

## Applying Changes

Restart Claude Code after modifying the config file. Exit the current session and run `claude` again.

## Environment Variables

You can also set these via environment variables:

```bash
export ANTHROPIC_AUTH_TOKEN="sk-xxxxxxxxxxxxxxxxxxxxxxxx"
export ANTHROPIC_BASE_URL="https://api.ai80.vip"
```

Config file settings take precedence over environment variables.
