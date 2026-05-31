---
description: Code80 平台 gpt-5.5 与 gpt-image-2 接口文档，OpenAI 兼容、原生透传，支持 thinking 思考摘要、可调 reasoning effort、usage 用量原样返回
---

# 接口文档：gpt-5.5 与 gpt-image-2

本文是 `gpt-5.5`（推理对话）与 `gpt-image-2`（图像生成）两个模型的接口规范，供对接集成参考。

平台采用 **OpenAI 兼容、原生透传**：请求体原样转发到上游、响应体原样回传，中间层不改写字段，仅替换鉴权。因此 OpenAI 官方文档中的字段与行为在此一致，已直连 OpenAI 的代码迁移时只需更换 `api_key` 与 `base_url`。

## 通用约定

### Base URL

```text
https://code.ai80.vip/v1
```

::: warning
OpenAI 兼容接口的 Base URL 必须带 `/v1`。这与 Anthropic 兼容接入使用根地址 `https://code.ai80.vip` 不同，请勿混用。
:::

### 鉴权

所有请求通过 HTTP 头携带 API Key（**OpenAI 分组**）：

```text
Authorization: Bearer <YOUR_API_KEY>
Content-Type: application/json
```

未鉴权或鉴权失败返回 `401`。

### 错误响应

错误结构与 OpenAI 官方一致：

```json
{
  "error": {
    "message": "错误描述",
    "type": "invalid_request_error",
    "code": "..."
  }
}
```

| 状态码 | 含义 |
|--------|------|
| `400` | 请求参数错误 |
| `401` | 鉴权失败：Key 错误 / 失效 / 非 OpenAI 分组 / Base URL 漏写 `/v1` |
| `429` | 触发限流，请退避重试 |
| `5xx` | 上游或网关异常，例如 `{"error":{"type":"upstream_error","message":"Upstream service temporarily unavailable"}}`，建议带退避重试 |

---

## gpt-5.5（推理对话）

`gpt-5.5` 是推理模型，支持调节推理强度（reasoning effort）、返回思考摘要（thinking summary）、并在 `usage` 中给出推理 token 统计。

提供两个端点，按习惯选用：

| 端点 | 说明 |
|------|------|
| `POST /v1/responses` | Responses API，推理模型的原生形态，思考摘要更完整 |
| `POST /v1/chat/completions` | Chat Completions，生态最广，同样支持 reasoning effort |

### 请求参数

#### Responses API

| 参数 | 类型 | 必填 | 说明 |
|------|------|:----:|------|
| `model` | string | 是 | 固定 `gpt-5.5` |
| `input` | string \| array | 是 | 输入内容，字符串或结构化消息数组 |
| `reasoning.effort` | string | 否 | 推理强度：`minimal` / `low` / `medium` / `high` |
| `reasoning.summary` | string | 否 | 思考摘要：`auto` / `concise` / `detailed` |
| `stream` | boolean | 否 | 是否流式输出，默认 `false` |
| `max_output_tokens` | integer | 否 | 输出 token 上限 |

#### Chat Completions

| 参数 | 类型 | 必填 | 说明 |
|------|------|:----:|------|
| `model` | string | 是 | 固定 `gpt-5.5` |
| `messages` | array | 是 | 消息数组，结构同官方 |
| `reasoning_effort` | string | 否 | 顶层字段，取值 `minimal` / `low` / `medium` / `high` |
| `stream` | boolean | 否 | 是否流式输出，默认 `false` |
| `stream_options.include_usage` | boolean | 否 | 流式时是否在末块返回 usage |
| `max_completion_tokens` | integer | 否 | 输出 token 上限 |

> **Reasoning effort**：取值越高推理越充分，但更慢、更贵。简单任务用 `low` / `minimal` 提速，复杂推理用 `high`。该字段原样透传，平台不改写。

### Reasoning Effort 示例

Responses API（字段为 `reasoning.effort`）：

```bash
curl -s https://code.ai80.vip/v1/responses \
  -H "Authorization: Bearer <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.5",
    "input": "用三句话解释 CAP 定理",
    "reasoning": { "effort": "high" }
  }'
```

Chat Completions（字段为顶层 `reasoning_effort`）：

```bash
curl -s https://code.ai80.vip/v1/chat/completions \
  -H "Authorization: Bearer <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.5",
    "messages": [{"role": "user", "content": "用三句话解释 CAP 定理"}],
    "reasoning_effort": "high"
  }'
```

### 思考摘要（thinking）

原始推理 token 内容不会被吐出，但 Responses API 可返回一份**思考摘要**，加上 `reasoning.summary` 即可：

```bash
curl -s https://code.ai80.vip/v1/responses \
  -H "Authorization: Bearer <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.5",
    "input": "设计一个短链服务，说明你的取舍",
    "reasoning": { "effort": "high", "summary": "auto" }
  }'
```

`reasoning.summary` 参数会被接受并原样透传，响应中回显（如 `"reasoning": { "effort": "high", "summary": "detailed" }`）。

是否返回摘要正文取决于上游：与官方一致，OpenAI 仅对通过身份验证的组织返回推理摘要条目。实测中 `output` 数组通常仅含 `message`（最终答案），不出现独立的 `reasoning` 摘要条目。无论摘要是否展示，推理消耗都会计入 `usage.output_tokens_details.reasoning_tokens`。

### 响应与 usage

每次请求的 token 用量原样返回，含推理 token，便于成本核算。

Responses API（实测结构）：

```json
{
  "usage": {
    "input_tokens": 24,
    "input_tokens_details": { "cached_tokens": 0 },
    "output_tokens": 144,
    "output_tokens_details": { "reasoning_tokens": 23 },
    "total_tokens": 168
  }
}
```

Chat Completions（实测结构）：

```json
{
  "usage": {
    "prompt_tokens": 24,
    "completion_tokens": 138,
    "completion_tokens_details": { "reasoning_tokens": 20 },
    "total_tokens": 162
  }
}
```

- `reasoning_tokens`：思考消耗，计入输出，推理模型占比可能很高，预算时勿漏。
- `cached_tokens`：缓存命中部分，在 `input_tokens_details` / `prompt_tokens_details` 下原样返回。

### 流式 usage

流式默认不带 usage（官方行为）：

- **Chat Completions**：需加 `stream_options.include_usage: true`，usage 出现在最后一个数据块。
- **Responses API**：在 `response.completed` 事件中带 usage，无需额外参数。

```bash
curl -s https://code.ai80.vip/v1/chat/completions \
  -H "Authorization: Bearer <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.5",
    "messages": [{"role": "user", "content": "写一首关于秋天的短诗"}],
    "stream": true,
    "stream_options": { "include_usage": true }
  }'
```

开启后，流的末块 `choices` 为空数组、单独携带 usage（实测）：

```text
data: {"object":"chat.completion.chunk","model":"gpt-5.5","choices":[],"usage":{"prompt_tokens":20,"completion_tokens":40,"total_tokens":60,"completion_tokens_details":{"reasoning_tokens":26}}}

data: [DONE]
```

### Python SDK

```python
from openai import OpenAI

client = OpenAI(
    api_key="<YOUR_API_KEY>",
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

---

## gpt-image-2（图像生成）

`gpt-image-2` 通过标准 OpenAI Images API 调用，接口与官方一致。

| 端点 | 说明 |
|------|------|
| `POST /v1/images/generations` | 文本生图 |
| `POST /v1/images/edits` | 图像编辑（需上传原图，可带 mask） |

也可通过 Responses API 的 `image_generation` 工具调用，见文末。

### 请求参数（generations）

| 参数 | 类型 | 必填 | 说明 |
|------|------|:----:|------|
| `model` | string | 是 | 固定 `gpt-image-2` |
| `prompt` | string | 是 | 图像描述，建议英文，文字渲染更稳定 |
| `n` | integer | 否 | 生成数量，默认 `1` |
| `size` | string | 否 | `1024x1024`（方）/ `1536x1024`（横）/ `1024x1536`（竖） |
| `quality` | string | 否 | `low` / `medium` / `high`，默认平衡用 `medium` |
| `response_format` | string | 否 | `b64_json`（纯 base64）/ `url`（返回 data URI） |
| `background` | string | 否 | `transparent` / `opaque` / `auto` |
| `output_format` | string | 否 | `png` / `jpeg` / `webp` |
| `output_compression` | integer | 否 | 压缩等级（jpeg/webp） |
| `stream` | boolean | 否 | 是否流式返回中间帧 |
| `partial_images` | integer | 否 | 流式时的中间帧数量 |

> `response_format: "url"` 返回的是 `data:image/png;base64,...` 形式的 data URI，可直接用于 `<img src>`；保存为文件用 `b64_json` 更直接。

### 响应

以下为 `gpt-image-2` 实测返回结构（base64 已省略）：

```json
{
  "created": 1780265876,
  "data": [
    {
      "b64_json": "iVBORw0KGgoAAA...",
      "revised_prompt": "A realistic red apple sitting on a clean white table, soft natural lighting, photorealistic"
    }
  ],
  "background": "auto",
  "output_format": "png",
  "quality": "auto",
  "size": "1024x1024",
  "model": "gpt-image-2",
  "usage": {
    "input_tokens": 35,
    "input_tokens_details": { "image_tokens": 0, "text_tokens": 35 },
    "output_tokens": 196,
    "output_tokens_details": { "image_tokens": 196, "text_tokens": 0 },
    "total_tokens": 231
  }
}
```

- 图像数据在 `data[].b64_json`（或 `data[].url` 的 data URI）。
- `data[].revised_prompt`：模型对原始 prompt 的改写版本，反映实际用于生成的描述。
- 顶层回显本次生成的 `background` / `output_format` / `quality` / `size` / `model`。
- `usage` 随上游原样返回，与官方 Images API 一致：`input_tokens` / `output_tokens` / `total_tokens`，并在 `input_tokens_details`、`output_tokens_details` 中按 `image_tokens` / `text_tokens` 拆分。图像生成的输出主要计入 `output_tokens_details.image_tokens`。

### curl 示例

```bash
curl -s https://code.ai80.vip/v1/images/generations \
  -H "Authorization: Bearer <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "A cinematic illustration of a programmer working late at night, warm desk lamp, city lights through window",
    "n": 1,
    "size": "1536x1024",
    "quality": "medium",
    "response_format": "b64_json"
  }' | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
open('output.png','wb').write(base64.b64decode(data['data'][0]['b64_json']))
print('saved: output.png')
"
```

### Python SDK

```python
from openai import OpenAI
import base64
from pathlib import Path

client = OpenAI(api_key="<YOUR_API_KEY>", base_url="https://code.ai80.vip/v1")

resp = client.images.generate(
    model="gpt-image-2",
    prompt="A dramatic editorial illustration, glowing terminal, dark cyberpunk style",
    n=1,
    size="1536x1024",
    quality="medium",
    response_format="b64_json",
)

Path("cover.png").write_bytes(base64.b64decode(resp.data[0].b64_json))
print("done")
```

### 通过 Responses API 调用

`gpt-image-2` 也可作为 Responses API 的图像生成工具使用：

```bash
curl -s https://code.ai80.vip/v1/responses \
  -H "Authorization: Bearer <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "input": "A cinematic illustration of a programmer working late at night",
    "tools": [{"type": "image_generation"}]
  }' | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
open('output.png','wb').write(base64.b64decode(data['output'][0]['result']))
print('saved: output.png')
"
```

此形态下响应 `output` 为 `image_generation_call` 条目，图像 base64 在 `output[0].result`（实测结构）：

```json
{
  "output": [
    {
      "id": "ig_0a51...",
      "type": "image_generation_call",
      "status": "completed",
      "action": "generate",
      "background": "opaque",
      "output_format": "png",
      "quality": "high",
      "size": "1536x1024",
      "revised_prompt": "...",
      "result": "iVBORw0KGgoAAA..."
    }
  ],
  "usage": {
    "input_tokens": 2214,
    "input_tokens_details": { "cached_tokens": 0 },
    "output_tokens": 43,
    "output_tokens_details": { "reasoning_tokens": 0 },
    "total_tokens": 2257
  }
}
```

> 通过工具调用时，`usage` 采用 Responses 口径（`input_tokens` / `output_tokens`），且 `input_tokens` 会因工具系统提示而偏高；这与标准 `/v1/images/generations` 的 `image_tokens` / `text_tokens` 拆分口径不同。如只需出图、按图像 token 计量，优先用标准 Images API。

---

## 与官方差异说明

| 项目 | 说明 |
|------|------|
| Base URL | OpenAI 接口统一 `https://code.ai80.vip/v1`（带 `/v1`） |
| 请求 / 响应 | 原生透传，不做协议转换，仅替换鉴权头 |
| 字段行为 | 与 OpenAI 官方文档一致，包括 reasoning、思考摘要、usage、流式 |
| 鉴权 | 使用 Code80 **OpenAI 分组** 的 API Key |

需要并发配额、专属资源或更多模型对接，请通过商务渠道联系。相关页面：[OpenAI 接口对齐](./openai-compat) · [GPT Image 生图接入](./gpt-image) · [API Key 管理](./api-keys)
