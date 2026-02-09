---
description: Claude Code 配置文件详解，包括 API 地址、密钥设置、模型选择和自定义参数配置
---

# Claude Code 配置详解

## 配置文件位置

| 平台 | 路径 |
|------|------|
| macOS/Linux | `~/.claude/settings.json` |
| Windows | `%USERPROFILE%\.claude\settings.json` |

## 配置格式

Claude Code 使用 JSON 格式的配置文件：

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "your-api-key",
    "ANTHROPIC_BASE_URL": "https://your-code80-domain.com"
  }
}
```

## 字段说明

### `env.ANTHROPIC_AUTH_TOKEN`

你的 API Key，在 Code80 平台的「API 密钥」页面生成。

- 格式：`sk-` 开头的字符串
- 创建密钥时请选择 **Anthropic 平台**对应的分组

### `env.ANTHROPIC_BASE_URL`

Code80 平台的 API 地址。

- 格式：完整的 URL，如 `https://api.example.com`
- 不要在末尾加 `/v1` 等路径

## 完整配置示例

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-xxxxxxxxxxxxxxxxxxxxxxxx",
    "ANTHROPIC_BASE_URL": "https://api.ai80.vip"
  }
}
```

## 配置生效

修改配置文件后，需要重启 Claude Code 才能生效。退出当前会话后重新运行 `claude` 即可。

## 与环境变量的关系

你也可以通过环境变量来设置，效果等价：

```bash
export ANTHROPIC_AUTH_TOKEN="sk-xxxxxxxxxxxxxxxxxxxxxxxx"
export ANTHROPIC_BASE_URL="https://api.ai80.vip"
```

配置文件中的设置优先级高于环境变量。
