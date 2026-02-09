# Codex CLI Tips & Tricks

## Basic Operations

```bash
cd your-project
codex

# Direct query
codex "write a sorting function"
```

## Productivity Tips

### Network Access

With `network_access = "enabled"`, Codex can access online resources.

### Reasoning Depth

Adjust `model_reasoning_effort` based on task complexity:

- `low`: Simple tasks, faster responses
- `medium`: Everyday coding
- `high`: Complex algorithms, architecture design

### Sandbox Environment

Codex CLI runs code in a sandbox by default for safety. Linux requires bubblewrap.

## Comparison

See [Tool Comparison](/en/guide/comparison) to understand how Codex CLI differs from Claude Code and Gemini CLI.
