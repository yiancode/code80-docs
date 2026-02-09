# Gemini CLI 使用技巧

## 基础操作

### 启动

```bash
cd your-project
gemini
```

## Gemini CLI 特色功能

### 超大上下文窗口

Gemini 模型支持超大上下文，适合分析大型代码库，无需频繁压缩上下文。

### Agent Mode

Gemini CLI 支持 Agent Mode，可以自动规划和执行多步骤任务。

### Google Search 联网

Gemini CLI 内置 Google Search 能力，可以实时搜索最新的技术文档和解决方案。

## 高效使用

### 主题设置

在 `settings.json` 中配置主题：
- `system`：跟随系统
- `dark`：深色
- `light`：浅色

### 模型选择

在 `.env` 文件中修改 `GEMINI_MODEL` 来切换模型。

## 与其他工具对比

查看 [工具功能对比](/zh/guide/comparison) 了解 Gemini CLI 与 Claude Code、Codex CLI 的差异。
