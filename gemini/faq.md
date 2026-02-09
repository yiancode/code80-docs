---
description: Gemini CLI 常见问题与解决方案，包括 Node.js 版本要求、API 连接和配置问题排查
---

# Gemini CLI 常见问题

## 安装问题

### Node.js 版本要求

Gemini CLI 需要 Node.js 20+。使用 nvm 升级：

```bash
nvm install 20
nvm use 20
```

## 配置问题

### Base URL 格式

Gemini CLI 的 Base URL 需要加 `/v1beta` 后缀，与其他工具不同：

```bash
# 正确
GOOGLE_GEMINI_BASE_URL=https://api.ai80.vip/v1beta

# 错误
GOOGLE_GEMINI_BASE_URL=https://api.ai80.vip
GOOGLE_GEMINI_BASE_URL=https://api.ai80.vip/v1
```

### 启动报认证错误

检查以下几点：
1. `.env` 文件是否在 `~/.gemini/` 目录下
2. `GEMINI_API_KEY` 值是否正确
3. API Key 对应的分组是否是 Google 平台

## 使用问题

### 与 Claude Code 相比有什么优势？

- 超大上下文窗口
- 内置 Google Search 联网
- Agent Mode 自动规划

## 错误码对照

| 错误码 | 说明 | 解决方法 |
|--------|------|----------|
| 401 | 认证失败 | 检查 .env 中的 API Key |
| 403 | 无权限 | 确认分组权限 |
| 429 | 请求过多 | 等待后重试 |
| 500 | 服务器错误 | 稍后重试 |
