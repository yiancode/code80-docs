---
description: Gemini CLI 配置详解，包括 .env 环境变量、settings.json 设置和 API 地址配置
---

# Gemini CLI 配置详解

## 配置文件位置

Gemini CLI 需要两个配置文件：

| 文件 | macOS/Linux | Windows |
|------|-------------|----------|
| 环境变量 | `~/.gemini/.env` | `%USERPROFILE%\.gemini\.env` |
| 设置文件 | `~/.gemini/settings.json` | `%USERPROFILE%\.gemini\settings.json` |

## 环境变量文件 .env

```bash
GOOGLE_GEMINI_BASE_URL=https://code.ai80.vip/v1beta
GEMINI_API_KEY=your-api-key
GEMINI_MODEL=gemini-2.5-pro
```

### 字段说明

| 字段 | 说明 |
|------|------|
| `GOOGLE_GEMINI_BASE_URL` | Code80 平台的 API 地址，注意路径需要加 `/v1beta` |
| `GEMINI_API_KEY` | 你的 API Key |
| `GEMINI_MODEL` | 使用的模型名称 |

## 设置文件 settings.json

```json
{
  "theme": "system"
}
```

### 字段说明

| 字段 | 说明 |
|------|------|
| `theme` | 主题设置：`system`（跟随系统）/ `dark` / `light` |

## 完整配置示例

`.env` 文件：
```bash
GOOGLE_GEMINI_BASE_URL=https://api.ai80.vip/v1beta
GEMINI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxx
GEMINI_MODEL=gemini-2.5-pro
```

`settings.json` 文件：
```json
{
  "theme": "system"
}
```

## 配置生效

修改配置后需要重启 Gemini CLI 才能生效。

## 注意事项

- Base URL 末尾需要加 `/v1beta`，这与 Claude Code 和 Codex CLI 不同
- API Key 在 Code80 平台创建时，请选择 **Google 平台**对应的分组
