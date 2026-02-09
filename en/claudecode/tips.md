# Claude Code Tips & Tricks

## Basic Operations

### Launch and Exit

```bash
cd your-project
claude

# Exit (type inside Claude Code)
/exit
```

### Common Commands

| Command | Description |
|---------|-------------|
| `/help` | View help information |
| `/clear` | Clear current conversation |
| `/exit` | Exit Claude Code |
| `/compact` | Compress conversation history |

## Productivity Tips

### Project Initialization

Create a `CLAUDE.md` file in your project root with project description and coding standards. Claude Code reads it automatically as context.

### Using Context Effectively

- Launch from the project directory for automatic project awareness
- Provide specific file paths and line numbers in questions
- Use `@filename` to reference specific files

### Large Projects

- Use `/compact` periodically to avoid context overflow
- Break complex tasks into smaller steps
- Have Claude Code analyze before implementing

## IDE Integration

### VS Code

Install the Claude Code extension to use directly in the editor.

### JetBrains

Use Claude Code through the terminal panel.

## Performance Optimization

- **Reduce unnecessary context**: Keep conversations focused
- **Be specific**: Provide precise requirements to minimize back-and-forth
- **Use file references**: Point to specific files rather than asking Claude Code to search
