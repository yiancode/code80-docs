---
description: Code80 平台 OpenAI 兼容接口对齐官方 API，支持 reasoning effort 调节、思考过程摘要、usage 用量原样返回，适用于 gpt-5.5 等推理模型
---

# OpenAI 接口对齐（思考 / Reasoning Effort / Usage）

Code80 的 OpenAI 兼容接口走的是原生透传：你发什么字段，平台原样转发到上游；上游返回什么，平台原样回给你，中间不改写请求体、不改写响应体。

这意味着 OpenAI 官方 API 里的高级能力，在 Code80 上一样可用。本页讲三件开发者最关心的事：

- 调节推理强度（`reasoning_effort` / `reasoning.effort`）
- 拿到思考过程摘要（reasoning summary）
- 读到完整的用量统计（`usage`），包括推理 token

如果你直连过 OpenAI，这里的代码几乎不用改，只换 `api_key` 和 `base_url` 两处。

## 适用场景

- 需要按任务难度动态调节推理强度，平衡速度和效果
- 做计费或成本核算，要拿到每次请求的 token 用量，包含推理 token
- 已有的 OpenAI 代码想迁到 Code80，要求行为和官方一致，不被中间层吞字段

## 配置前确认

- 已有 Code80 账号且有可用额度
- 已创建 **OpenAI 分组** 的 API Key
- 目标模型是推理模型（如 `gpt-5.5`），普通模型不产生推理 token

还没有 Key 看这里：[API Key 管理](./api-keys)

## Base URL

OpenAI 兼容接口的 Base URL 要带 `/v1`：

```text
https://code.ai80.vip/v1
```

::: warning 注意
这一点和 Claude / Anthropic 接入不同。Claude 用根地址 `https://code.ai80.vip`（不带 `/v1`），OpenAI 这类接口要写成 `https://code.ai80.vip/v1`。两者不要混用。
:::

两个端点都支持，按你的习惯选：

| 端点 | 说明 |
|------|------|
| `/v1/responses` | Responses API，OpenAI 推理模型的原生形态，思考摘要更完整 |
| `/v1/chat/completions` | Chat Completions，老接口生态最广，同样支持 reasoning effort |

## Reasoning Effort：调节推理强度

`effort` 控制模型在回答前"想多久"。取值越高，推理越充分，但更慢、更贵。OpenAI 推理模型支持 `minimal` / `low` / `medium` / `high`。

### Responses API 写法

字段是 `reasoning.effort`：

```bash
curl -s https://code.ai80.vip/v1/responses \
  -H "Authorization: Bearer 你的API-Key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.5",
    "input": "用三句话解释 CAP 定理",
    "reasoning": { "effort": "high" }
  }'
```

### Chat Completions 写法

字段是顶层的 `reasoning_effort`：

```bash
curl -s https://code.ai80.vip/v1/chat/completions \
  -H "Authorization: Bearer 你的API-Key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.5",
    "messages": [{"role": "user", "content": "用三句话解释 CAP 定理"}],
    "reasoning_effort": "high"
  }'
```

简单任务用 `low` 或 `minimal` 能明显提速，复杂推理再切 `high`。这个值是原样透传的，平台不会替你改。

## 思考过程摘要

OpenAI 不会把模型的原始推理 token 内容吐出来，但 Responses API 可以返回一份**思考摘要**（reasoning summary）。加上 `reasoning.summary` 即可：

```bash
curl -s https://code.ai80.vip/v1/responses \
  -H "Authorization: Bearer 你的API-Key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.5",
    "input": "设计一个短链服务，说明你的取舍",
    "reasoning": { "effort": "high", "summary": "auto" }
  }'
```

摘要会作为 `reasoning` 类型的条目出现在响应的 `output` 数组里，最终答案在 `output` 后续的 `message` 条目里。行为和官方 Responses API 一致。

## Usage：用量原样返回

每次请求的 token 用量都会原样回传，包含推理 token，方便你做成本核算。

### 非流式

**Responses API** 的 `usage` 结构：

```json
{
  "usage": {
    "input_tokens": 24,
    "output_tokens": 512,
    "output_tokens_details": { "reasoning_tokens": 448 },
    "total_tokens": 536
  }
}
```

**Chat Completions** 的 `usage` 结构：

```json
{
  "usage": {
    "prompt_tokens": 24,
    "completion_tokens": 512,
    "completion_tokens_details": { "reasoning_tokens": 448 },
    "total_tokens": 536
  }
}
```

`reasoning_tokens` 是模型思考消耗的部分，它算在输出里。推理模型这块占比可能很高，做预算时别漏。缓存命中的 `cached_tokens`（在 `input_tokens_details` / `prompt_tokens_details` 下）也会原样带回。

### 流式

流式默认不带 usage，这是 OpenAI 的官方行为，要显式开启。

Chat Completions 加 `stream_options`：

```bash
curl -s https://code.ai80.vip/v1/chat/completions \
  -H "Authorization: Bearer 你的API-Key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.5",
    "messages": [{"role": "user", "content": "写一首关于秋天的短诗"}],
    "stream": true,
    "stream_options": { "include_usage": true }
  }'
```

开启后，usage 会出现在流的最后一个数据块里。Responses API 的流式则在 `response.completed` 事件中带 usage，不需要额外参数。

## Python SDK 示例

用 OpenAI 官方 SDK，只改 `api_key` 和 `base_url`：

```python
from openai import OpenAI

client = OpenAI(
    api_key="你的API-Key",
    base_url="https://code.ai80.vip/v1",
)

resp = client.responses.create(
    model="gpt-5.5",
    input="用三句话解释 CAP 定理",
    reasoning={"effort": "high", "summary": "auto"},
)

print(resp.output_text)
print("推理 token:", resp.usage.output_tokens_details.reasoning_tokens)
print("总 token:", resp.usage.total_tokens)
```

## 常见问题

#### 1. 传了 reasoning_effort 没生效

先确认模型是推理模型。普通对话模型不接受这个参数，也不产生推理 token。`gpt-5.5` 这类模型才有效。

#### 2. usage 里 reasoning_tokens 是 0

说明这次请求模型几乎没有推理，常见于 `effort` 设为 `minimal` 或任务很简单。把 `effort` 调高再看。

#### 3. 流式拿不到 usage

流式默认不返回 usage。Chat Completions 要加 `stream_options.include_usage: true`；Responses API 在 `response.completed` 事件里带。这和直连 OpenAI 的行为一致。

#### 4. 字段会不会被平台改写

OpenAI 分组的 `/v1/responses` 和 `/v1/chat/completions` 是原生透传，请求体和响应体不做协议转换，只替换鉴权头。你按官方文档怎么写，这里就怎么用。

#### 5. 接口报 401

通常是这几种：Key 填错或失效、Key 不是 **OpenAI 分组**、`base_url` 漏了 `/v1` 写成了根地址。
