---
description: OpenClaw 接入 Code80 Claude 模型指南，使用 ai80 的 Anthropic 兼容接口手动配置 OpenClaw
---

# OpenClaw 接入指南

如果你想在 OpenClaw 里接入 Code80 提供的 Claude 模型，推荐按 **Anthropic 兼容 provider** 的方式配置。

先备份原配置，再新增 `ai80` provider，最后把默认模型切到 ai80 提供的 Claude。

## 适用场景

- 已经装好 OpenClaw，但还不会改模型配置
- 想把默认模型切到 ai80 提供的 Claude
- 想在 OpenClaw 里使用 Claude Sonnet / Opus

## 配置前确认

开始前请先准备：

- OpenClaw 已可正常启动
- 你已经有 ai80 账号
- 账号里有可用额度
- 已创建 API Key
- 已复制好自己的 Key

如果还没有 API Key，可以先看：[API Key 管理](./api-keys)

## 配置文件位置

OpenClaw 的主配置文件通常是：

| 平台 | 路径 |
|------|------|
| macOS / Linux | `~/.openclaw/openclaw.json` |
| Windows | `%USERPROFILE%\.openclaw\openclaw.json` |

## 先备份原配置

飞书教程把这一步单独拎出来是对的，建议保留。

最简单的方式就是先复制一份：

### macOS / Linux

```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak
```

### Windows PowerShell

```powershell
Copy-Item "$env:USERPROFILE\.openclaw\openclaw.json" "$env:USERPROFILE\.openclaw\openclaw.json.bak"
```

这样如果后面模型名、JSON 格式或 Key 填错了，可以直接恢复。

## 推荐配置

把下面这段配置加入 `~/.openclaw/openclaw.json`：

```json5
{
  env: {
    AI80_API_KEY: "your-api-key"
  },
  agents: {
    defaults: {
      model: {
        primary: "ai80/claude-sonnet-4-20250514"
      }
    }
  },
  models: {
    mode: "merge",
    providers: {
      ai80: {
        baseUrl: "https://code.ai80.vip",
        apiKey: "${AI80_API_KEY}",
        api: "anthropic-messages",
        models: [
          {
            id: "claude-sonnet-4-20250514",
            name: "Claude Sonnet 4"
          },
          {
            id: "claude-opus-4-1-20250805",
            name: "Claude Opus 4.1"
          }
        ]
      }
    }
  }
}
```

> 把 `your-api-key` 替换成你在 Code80 平台生成的实际密钥。

## 配置思路

这份配置的核心只有两步：

1. 新增 `ai80` 这个模型提供商  
2. 把默认模型改成 `ai80` 提供的 Claude

也就是：

- `models.providers.ai80` 负责声明 ai80 这个 provider
- `agents.defaults.model.primary` 负责指定默认走哪个模型

## 字段说明

### `models.providers.ai80.api`

这里用：

```text
anthropic-messages
```

因为这篇接入指南走的是 **Claude / Anthropic 兼容接口**，不是 OpenAI 兼容接口。

### `models.providers.ai80.baseUrl`

这里应写：

```text
https://code.ai80.vip
```

**这里不要手动加 `/v1`。**

原因是：

- OpenClaw 的 Anthropic 兼容 provider 使用 `anthropic-messages`
- OpenClaw 官方自定义 provider 示例里，这一路的 `baseUrl` 写的是 Anthropic 兼容根路径
- Code80 对 Claude / Anthropic 兼容接入本身也是走根地址配置

也就是说，这里和 OpenAI 兼容配置不同，不要套用 `https://code.ai80.vip/v1` 的写法。

### `models.providers.ai80.apiKey`

建议用环境变量占位：

```text
${AI80_API_KEY}
```

这样比直接把 Key 硬编码在 provider 里更方便维护。

### `models.providers.ai80.models[].id`

这里填的是 **provider 里的模型 ID**。

例如：

- `claude-sonnet-4-20250514`
- `claude-opus-4-1-20250805`

如果这里写错，OpenClaw 能加载 provider，但实际调用会失败。

### `agents.defaults.model.primary`

这里填的是默认模型，格式是：

```text
provider-id/model-id
```

例如：

```text
ai80/claude-sonnet-4-20250514
```

## 想切到 Claude Opus 怎么改

如果你想把默认模型改成 Opus，把这一行：

```json5
primary: "ai80/claude-sonnet-4-20250514"
```

改成：

```json5
primary: "ai80/claude-opus-4-1-20250805"
```

即可。

## 保存并重启

改完配置后：

1. 保存 `openclaw.json`
2. 完全退出 OpenClaw
3. 重新启动 OpenClaw

这一步很重要，不重启的话新配置可能不会生效。

## 如何验证是否生效

建议按这个顺序验证：

1. 打开 OpenClaw
2. 看默认模型是否已经变成 `ai80/claude-sonnet-4-20250514`
3. 发起一条简单对话
4. 如有需要，执行：

```bash
openclaw models status
```

如果模型能正常返回内容，说明接入已经完成。

## 常见问题

### 1. API Key 填错了怎么办

先重新检查：

- `AI80_API_KEY` 是否正确
- 配置里是否误多了空格或引号
- 是否真的保存到了正在使用的 `openclaw.json`

如果还不确定，直接换回备份文件再重配一次最快。

### 2. 配置文件改乱了怎么办

直接恢复备份：

### macOS / Linux

```bash
cp ~/.openclaw/openclaw.json.bak ~/.openclaw/openclaw.json
```

### Windows PowerShell

```powershell
Copy-Item "$env:USERPROFILE\.openclaw\openclaw.json.bak" "$env:USERPROFILE\.openclaw\openclaw.json" -Force
```

### 3. 提示 401 错误是什么意思

通常优先检查：

- API Key 填错了
- Key 已失效
- `baseUrl` 写错了
- `api` 没有写成 `anthropic-messages`

我实际验证过 Code80：

- `POST https://code.ai80.vip/v1/messages` 未鉴权会返回 `401`
- `POST https://code.ai80.vip/v1/responses` 未鉴权也会返回 `401`

这说明接口本身是通的，`401` 更偏向鉴权或配置问题。

### 4. provider 里的模型 ID 和默认模型 primary 有什么区别

区别是：

- `models[].id`：provider 内部声明“这个上游提供了哪些模型”
- `primary`：默认实际调用哪个模型

两者要对应得上。

例如：

- provider 里有 `claude-sonnet-4-20250514`
- 那么 `primary` 才能写成 `ai80/claude-sonnet-4-20250514`

## 补充说明

本页内容是按下面两类证据整理的：

- 飞书参考文章的页面结构与步骤标题
- OpenClaw 官方关于 Anthropic provider、自定义 provider、`anthropic-messages` 的配置约定

如果你后面还想补 OpenClaw 接入 GPT / OpenAI 模型，我可以再单独补一节“OpenAI 兼容 provider 写法”，和这篇 Claude(ai80) 版分开。
