# API Key Management

## What is an API Key

An API Key is your credential for accessing AI services on the Code80 platform. Each key is bound to a group, which determines which models and billing rates apply.

## Creating an API Key

1. Log in to the Code80 dashboard
2. Go to the "API Keys" page
3. Click "Create Key"
4. Enter a name (for easy identification)
5. Select the corresponding group:
   - **Anthropic group** → For Claude Code
   - **OpenAI group** → For Codex CLI
   - **Google group** → For Gemini CLI
6. Click create and **copy immediately**

::: warning Important
API Keys are only displayed once at creation. Copy and save immediately. You'll need to regenerate if lost.
:::

## Group Selection

The group you select when creating a key determines:
- Which upstream accounts the key can use
- The billing multiplier
- Whether it's an exclusive key

## Security Best Practices

- Never commit API Keys to code repositories
- Never share API Keys publicly
- Regularly review and delete unused keys
- If you suspect a key is compromised, delete and recreate immediately
