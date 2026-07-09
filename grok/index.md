---
description: Grok CLI 快速开始指南，3 步通过 Code80 平台配置社区开源的 Grok AI 编程助手
---

# Grok CLI

Grok CLI 是 [superagent-ai/grok-cli](https://github.com/superagent-ai/grok-cli) 提供的开源终端编程助手，可以调用 Grok 模型完成代码分析、修改、测试、搜索和多代理任务。

::: info 项目身份
这是社区维护的开源项目，不是 xAI 官方 CLI。本教程按 [grok-dev@1.1.7](https://github.com/superagent-ai/grok-cli/releases/tag/grok-dev%401.1.7) 验证。
:::

## 快速开始

只需 3 步，即可通过 Code80 平台使用 Grok CLI。

### 1. 安装 CLI 工具

macOS、Linux 以及带 Bash 环境的 Windows 可以使用官方安装脚本：

```bash
curl -fsSL https://raw.githubusercontent.com/superagent-ai/grok-cli/main/install.sh | bash
```

安装后确认命中的程序和版本：

```bash
command -v grok
grok --version
```

脚本安装的正确路径通常是 `~/.grok/bin/grok`。其他平台和架构请查看[安装详解](./install)。

### 2. 配置 Code80

先在 Code80 控制台创建一个可以访问 Grok 模型的 API Key，然后创建或编辑 `~/.grok/user-settings.json`：

```json
{
  "apiKey": "your-api-key",
  "defaultModel": "grok-4.3"
}
```

将 `your-api-key` 替换为你的 Code80 API Key。如果文件已有其他配置，请合并字段，不要直接覆盖。

接着把中转地址加入 shell 配置。zsh 用户编辑 `~/.zshrc`，bash 用户编辑 `~/.bashrc`，加入：

```bash
export GROK_BASE_URL="https://code.ai80.vip/v1"
```

重新加载配置，以 zsh 为例：

```bash
source ~/.zshrc
```

::: warning Base URL 必须通过环境变量配置
Grok CLI 1.1.7 不读取 `user-settings.json` 里的 `baseURL` 字段。地址必须通过 `GROK_BASE_URL` 或启动参数 `--base-url` 设置，并且要保留末尾的 `/v1`。
:::

### 3. 开始使用

```bash
cd your-project
grok -m grok-4.3
```

也可以先做一次无头验证：

```bash
grok -m grok-4.3 -p "只回复 GROK_CLI_OK"
```

## 适用场景

- 代码编写、重构与审查
- Bug 排查、测试运行与失败分析
- 大型仓库探索和项目文档生成
- Web / X 搜索与多代理并行调研
- 脚本、CI 和自动化任务中的无头调用

## 下一步

- [安装详解](./install) - 分平台安装、更新和同名程序排查
- [配置详解](./config) - API Key、Base URL、模型与配置优先级
- [快捷键速查](./shortcuts) - 常用按键、slash commands 和启动参数
- [使用技巧](./tips) - 会话恢复、AGENTS.md、子代理与自动化
- [常见问题](./faq) - 404 模型、旧版 CLI、认证和网络错误
