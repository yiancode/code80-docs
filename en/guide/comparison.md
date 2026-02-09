# Tool Comparison

## Overview

| Feature | Claude Code | Codex CLI | Gemini CLI |
|---------|------------|-----------|------------|
| Developer | Anthropic | OpenAI | Google |
| Node.js Requirement | 18+ | 22+ | 20+ |
| Install Command | `npm i -g @anthropic-ai/claude-code` | `npm i -g @openai/codex` | `npm i -g @google/gemini-cli` |
| Config Format | JSON | TOML + JSON | .env + JSON |
| Launch Command | `claude` | `codex` | `gemini` |

## Configuration Comparison

### Claude Code
- Config file: `~/.claude/settings.json`
- API URL format: `https://domain.com` (no path suffix)
- Key field: `ANTHROPIC_AUTH_TOKEN`

### Codex CLI
- Config files: `~/.codex/config.toml` + `~/.codex/auth.json`
- API URL format: `https://domain.com/v1` (with `/v1`)
- Key field: `OPENAI_API_KEY`

### Gemini CLI
- Config files: `~/.gemini/.env` + `~/.gemini/settings.json`
- API URL format: `https://domain.com/v1beta` (with `/v1beta`)
- Key field: `GEMINI_API_KEY`

## Feature Comparison

| Feature | Claude Code | Codex CLI | Gemini CLI |
|---------|:-----------:|:---------:|:----------:|
| Large Context | Medium | Medium | Very Large |
| Sandbox Execution | - | Linux | - |
| Web Search | - | Configurable | Google Search |
| Agent Mode | - | - | Supported |
| IDE Integration | VS Code | - | - |
| Context Compression | /compact | - | - |
| CLAUDE.md | Supported | - | - |

## Recommendations

- **Claude Code**: Best for deep code understanding and project-level context
- **Codex CLI**: Best for developers in the OpenAI ecosystem
- **Gemini CLI**: Best for large context and web search capabilities

All three tools can be managed through Code80 — just create a separate API Key for each platform.
