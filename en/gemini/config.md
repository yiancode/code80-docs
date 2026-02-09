# Gemini CLI Configuration

## Config File Locations

| File | macOS/Linux | Windows |
|------|-------------|----------|
| Environment | `~/.gemini/.env` | `%USERPROFILE%\.gemini\.env` |
| Settings | `~/.gemini/settings.json` | `%USERPROFILE%\.gemini\settings.json` |

## .env File

```bash
GOOGLE_GEMINI_BASE_URL=https://your-code80-domain.com/v1beta
GEMINI_API_KEY=your-api-key
GEMINI_MODEL=gemini-2.5-pro
```

### Field Reference

| Field | Description |
|-------|-------------|
| `GOOGLE_GEMINI_BASE_URL` | Code80 API address, must include `/v1beta` |
| `GEMINI_API_KEY` | Your API Key |
| `GEMINI_MODEL` | Model name to use |

## settings.json

```json
{
  "theme": "system"
}
```

| Field | Description |
|-------|-------------|
| `theme` | Theme: `system` (follow system) / `dark` / `light` |

## Complete Example

`.env`:
```bash
GOOGLE_GEMINI_BASE_URL=https://api.ai80.vip/v1beta
GEMINI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxx
GEMINI_MODEL=gemini-2.5-pro
```

`settings.json`:
```json
{
  "theme": "system"
}
```

## Applying Changes

Restart Gemini CLI after modifying config files.

## Important Notes

- Base URL must end with `/v1beta`, which differs from Claude Code and Codex CLI
- Select the **Google platform** group when creating the API Key on Code80
