# FAQ

## Platform

### What is Code80?

Code80 is an AI API gateway platform that lets you manage and use multiple AI coding tools (Claude Code, Codex CLI, Gemini CLI) through a unified platform.

### Which tools are supported?

- **Claude Code** - Anthropic's official CLI
- **Codex CLI** - OpenAI's official CLI
- **Gemini CLI** - Google's official CLI

### Is my data safe?

- Code80 does not store your code content
- API requests are forwarded through encrypted channels
- Your API Key is only visible to you

## Account

### How do I register?

Visit the Code80 platform homepage and click "Register".

### Forgot my password?

Click "Forgot Password" on the login page and follow the instructions.

### Lost my API Key?

API Keys are only shown once at creation. Delete the old key and create a new one.

## Usage

### Can I use the same API Key for all three tools?

No. Each tool corresponds to a different platform (Anthropic/OpenAI/Google). Create separate API Keys for each platform group.

### Config changes not taking effect?

All tools require a restart after config changes. Exit and relaunch the tool.

### How to check usage?

Log in to the dashboard and visit "My Subscriptions".

### 429 error (too many requests)

- Wait a few seconds and retry
- Check if you've exceeded your quota
- Contact admin to increase quota

### 401 error (authentication failed)

- Verify API Key is correct
- Verify API Base URL is correct
- Check if key is expired or disabled
