# Claude Code FAQ

## Installation Issues

### Node.js version too low

Claude Code requires Node.js 18+. Upgrade with nvm:

```bash
nvm install 18
nvm use 18
```

### Permission errors during npm install

- **macOS/Linux**: Use `sudo npm install -g @anthropic-ai/claude-code`
- **Windows**: Run terminal as Administrator

## Configuration Issues

### 401 error after configuration

Check:
1. API Key is correctly copied (full `sk-` string)
2. API Base URL is correct (no `/v1` suffix)
3. API Key group is for the Anthropic platform
4. API Key is not expired or disabled

### Where is the config file?

| Platform | Path |
|----------|------|
| macOS/Linux | `~/.claude/settings.json` |
| Windows | `%USERPROFILE%\.claude\settings.json` |

Create it manually if it doesn't exist.

## Usage Issues

### Slow response

- Check network connectivity
- Verify Code80 service is running
- Consider using a proxy

### Context too long error

Use `/compact` to compress conversation history.

## Error Code Reference

| Code | Description | Solution |
|------|-------------|----------|
| 401 | Authentication failed | Check API Key |
| 403 | No permission | Verify API Key group |
| 429 | Too many requests | Wait and retry |
| 500 | Server error | Try again later |
| 503 | Service unavailable | Upstream temporarily unavailable |
