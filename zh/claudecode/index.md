# Claude Code

Anthropic 官方 AI 编程助手命令行工具。

## 快速开始

只需 3 步，即可通过 Code80 平台使用 Claude Code：

### 1. 安装 CLI 工具

```bash
npm install -g @anthropic-ai/claude-code
```

### 2. 配置 API

编辑配置文件 `~/.claude/settings.json`：

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "your-api-key",
    "ANTHROPIC_BASE_URL": "https://your-code80-domain.com"
  }
}
```

> 将 `your-api-key` 替换为你在 Code80 平台获取的 API Key，`your-code80-domain.com` 替换为你的 Code80 服务地址。

### 3. 开始使用

```bash
cd your-project
claude
```

首次启动流程：选择主题 → 确认安全须知 → 配置终端 → 信任工作目录 → 开始编程。

## 适用场景

- 代码编写与补全
- 代码审查与重构
- Bug 排查与修复
- 项目架构设计
- 文档撰写

## 下一步

- [安装详解](./install) - 分平台的详细安装步骤
- [配置详解](./config) - 完整的配置文件说明
- [使用技巧](./tips) - 高级用法和效率提升
- [常见问题](./faq) - 遇到问题看这里
