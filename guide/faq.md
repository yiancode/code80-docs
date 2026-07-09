---
description: Code80 平台常见问题解答，涵盖账号注册、API 使用、计费和工具配置等
---

# 常见问题

## 平台相关

### Code80 是什么？

Code80 是一个 AI API 网关平台，让你通过一个统一的平台管理和使用多个 AI 编程工具（Claude Code、Codex CLI、Gemini CLI、Grok CLI）。

### 支持哪些工具？

目前支持：
- **Claude Code** - Anthropic 官方 CLI
- **Codex CLI** - OpenAI 官方 CLI
- **Gemini CLI** - Google 官方 CLI
- **Grok CLI** - superagent-ai 社区维护的开源 CLI（不是 xAI 官方 CLI）

### 数据安全吗？

- Code80 不存储你的代码内容
- API 请求通过加密通道转发
- 你的 API Key 仅你自己可见

## 账号相关

### 如何注册？

访问 Code80 平台首页，点击「注册」按钮。

### 忘记密码怎么办？

在登录页点击「忘记密码」，按提示操作。

### API Key 丢失了怎么办？

API Key 创建后只显示一次。如果丢失，请删除旧 Key 并重新创建。

## 使用相关

### 四款工具能用同一个 API Key 吗？

通常不能。每个 API Key 只绑定一个分组，而不同 CLI 使用的协议和模型权限不同。请分别创建或选择包含 Anthropic、OpenAI、Google、Grok 对应模型权限的 Key。

### 配置文件修改后不生效

所有工具修改配置后都需要重启才能生效。退出当前会话后重新启动工具即可。

### Grok CLI 为什么仍请求 `grok-code-fast-1`？

通常是终端命中了旧的同名程序，或项目配置覆盖了模型。请查看 [Grok CLI 常见问题](/grok/faq) 完成 PATH、版本和模型排查。

### 如何查看使用量？

登录控制台，在「我的订阅」页面查看当前用量和余额。

### 遇到 429 错误（请求过多）

- 等待几秒后重试
- 检查是否超出配额限制
- 联系管理员提升配额

### 遇到 401 错误（认证失败）

- 确认 API Key 是否正确
- 确认 API Base URL 是否正确
- 确认 Key 是否过期或被禁用
