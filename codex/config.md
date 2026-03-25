---
description: Codex CLI 配置详解，包括 config.toml 主配置、auth.json 认证文件和 API 地址设置
---

# Codex CLI 配置详解

## 配置文件位置

Codex CLI 需要两个配置文件：

| 文件 | macOS/Linux | Windows |
|------|-------------|----------|
| 主配置 | `~/.codex/config.toml` | `%USERPROFILE%\.codex\config.toml` |
| 认证文件 | `~/.codex/auth.json` | `%USERPROFILE%\.codex\auth.json` |

## 创建配置目录

```bash
# macOS/Linux
mkdir -p ~/.codex

# Windows
mkdir %USERPROFILE%\.codex
```

## 主配置文件 config.toml

```toml
model_provider = "Custom"
model = "gpt-5.4"
preferred_auth_method = "apikey"
model_reasoning_effort = "medium"
network_access = "enabled"
disable_response_storage = true
windows_wsl_setup_acknowledged = true
model_verbosity = "high"

[model_providers.Custom]
name = "Custom"
base_url = "https://code.ai80.vip"
wire_api = "responses"
```

### 字段说明

| 字段 | 说明 |
|------|------|
| `model_provider` | 使用的提供商名称，需与下方 `model_providers` 中的键名一致 |
| `model` | 使用的模型名称 |
| `preferred_auth_method` | 认证方式，使用 API Key 时可设为 `apikey` |
| `model_reasoning_effort` | 推理努力程度：`low` / `medium` / `high` |
| `network_access` | 是否允许网络访问：`enabled` / `disabled` |
| `disable_response_storage` | 是否禁止存储响应 |
| `model_verbosity` | 输出详细程度：`low` / `medium` / `high` |
| `base_url` | Code80 平台的 API 地址，直接使用根地址即可 |
| `wire_api` | API 协议类型，使用 `responses` |

## 认证文件 auth.json

```json
{
  "OPENAI_API_KEY": "your-api-key"
}
```

将 `your-api-key` 替换为你在 Code80 平台获取的 API Key。

## 配置生效

修改配置后需要重启 Codex CLI 才能生效。
