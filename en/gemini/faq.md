# Gemini CLI FAQ

## Installation

### Node.js version requirement

Gemini CLI requires Node.js 20+. Use nvm:

```bash
nvm install 20
nvm use 20
```

## Configuration

### Base URL format

Gemini CLI requires `/v1beta` suffix, different from other tools:

```bash
# Correct
GOOGLE_GEMINI_BASE_URL=https://api.ai80.vip/v1beta

# Wrong
GOOGLE_GEMINI_BASE_URL=https://api.ai80.vip
GOOGLE_GEMINI_BASE_URL=https://api.ai80.vip/v1
```

### Authentication errors on launch

Check:
1. `.env` file is in the `~/.gemini/` directory
2. `GEMINI_API_KEY` value is correct
3. API Key group is for the Google platform

## Usage

### Advantages over Claude Code?

- Very large context window
- Built-in Google Search
- Agent Mode auto-planning

## Error Codes

| Code | Description | Solution |
|------|-------------|----------|
| 401 | Auth failed | Check .env API Key |
| 403 | No permission | Verify group permissions |
| 429 | Too many requests | Wait and retry |
| 500 | Server error | Try again later |
