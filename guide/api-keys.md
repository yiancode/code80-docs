---
description: Code80 平台 API Key 创建、管理与安全使用指南，一个密钥接入多个 AI 编程工具
---

# API Key 管理

## 什么是 API Key

API Key 是你访问 Code80 平台 AI 服务的凭证。每个 Key 绑定一个分组，决定了可以使用哪些模型和计费方式。

## 创建 API Key

1. 登录 Code80 平台控制台
2. 进入「API 密钥」页面
3. 点击「创建密钥」
4. 填写密钥名称（方便识别）
5. 选择对应的分组：
   - **Anthropic 分组** → 用于 Claude Code
   - **OpenAI 分组** → 用于 Codex CLI
   - **Google 分组** → 用于 Gemini CLI
6. 点击创建，**立即复制保存**

::: warning 重要提示
API Key 只在创建时显示一次，请务必立即复制保存。丢失后需要重新生成。
:::

## 分组选择

创建 API Key 时选择的分组决定了：
- 该 Key 可以使用哪些上游账号
- 计费倍率
- 是否为专属 Key

## 安全建议

- 不要将 API Key 提交到代码仓库
- 不要在公开场合分享 API Key
- 定期检查不再使用的 Key 并删除
- 如果怀疑 Key 泄露，立即删除并重新创建
