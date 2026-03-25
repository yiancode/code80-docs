---
description: Gemini CLI 快速开始指南，3 步通过 Code80 平台配置 Google AI 编程助手
---

# Gemini CLI

Google 官方 AI 编程助手命令行工具。

## 快速开始

只需 3 步，即可通过 Code80 平台使用 Gemini CLI：

### 1. 安装 CLI 工具

```bash
npm install -g @google/gemini-cli
```

### 2. 配置 API

创建环境变量文件 `~/.gemini/.env`：

```bash
GOOGLE_GEMINI_BASE_URL=https://code.ai80.vip
GEMINI_API_KEY=your-api-key
GEMINI_MODEL=gemini-2.5-pro
```

创建设置文件 `~/.gemini/settings.json`：

```json
{
  "ide": {
    "enabled": true
  },
  "security": {
    "auth": {
      "selectedType": "gemini-api-key"
    }
  },
  "ui": {
    "theme": "Default"
  }
}
```

> 将 `your-api-key` 替换为你在 Code80 平台获取的 API Key。

### 3. 开始使用

```bash
cd your-project
gemini
```

Gemini CLI 特色：超大上下文窗口、Agent Mode 自动规划、Google Search 联网。

## 适用场景

- 大上下文代码分析
- Agent 模式自动规划任务
- 联网搜索辅助编程
- 代码生成与优化

## 下一步

- [安装详解](./install) - 分平台的详细安装步骤
- [配置详解](./config) - 完整的配置文件说明
- [快捷键速查](./shortcuts) - 常用快捷键与高频使用入口
- [使用技巧](./tips) - 高级用法和效率提升
- [常见问题](./faq) - 遇到问题看这里
