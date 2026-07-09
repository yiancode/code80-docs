---
description: 在 Code80 平台接入 OpenAI GPT Image 生图模型，使用 OpenAI 兼容接口通过 curl 和 Python SDK 生成图片
---

# GPT Image 生图接入

Code80 除了中转 Claude、Codex、Gemini、Grok 这些编程模型，也中转 OpenAI 的图片生成能力。本页介绍如何用你已有的 Code80 API Key，通过 OpenAI 兼容接口调用 GPT Image 生图。

接口格式和 OpenAI 官方完全一致，如果你用过 OpenAI 的 Images API，这里只需要把 `base_url` 换成 Code80 的地址，其余代码不用改。

## 适用场景

- 想用 API 批量生成封面图、插画、文章配图
- 已经在用 Code80 的 Claude Code / Codex / Gemini / Grok CLI，想顺带把生图也接进来
- 需要 OpenAI 兼容的生图接口，但不想直连 OpenAI

## 配置前确认

开始前请先准备：

- 已有 Code80 账号
- 账号里有可用额度
- 已创建 **OpenAI 分组** 的 API Key（生图走的是 OpenAI 接口）
- 已复制好自己的 Key

如果还没有 API Key，可以先看：[API Key 管理](./api-keys)

## 模型说明

目前有两个生图模型，调用路径不一样：

| 模型 | 调用方式 | 鉴权要求 |
|------|----------|----------|
| `gpt-image-1` | 标准 `/v1/images/generations` 接口 | Code80 API Key 即可 |
| `gpt-image-2` | 走 Responses API `/v1/responses` | Code80 API Key 即可 |

`gpt-image-1` 用 API Key 就能直接调，是大多数人的首选。`gpt-image-2` 在中文文字渲染、插画质量上更强，但它不走传统的生图接口，必须通过 Responses API 调用。

如果你的目标只是"能用 API 出图"，先从 `gpt-image-1` 开始最省事。下面的 curl 和 Python 示例都以 `gpt-image-1` 为例，`gpt-image-2` 的差异单独放在文末说明。

## Base URL

生图走的是 OpenAI 兼容接口，Base URL 要带 `/v1`：

```text
https://code.ai80.vip/v1
```

::: warning 注意
这一点和 Claude / Anthropic 兼容接入不同。Claude 接入用的是根地址 `https://code.ai80.vip`（不带 `/v1`），而生图这类 OpenAI 接口要写成 `https://code.ai80.vip/v1`。两者不要混用。
:::

## 方式一：curl

最直接的方式，一条命令就能出图：

```bash
curl -s https://code.ai80.vip/v1/images/generations \
  -H "Authorization: Bearer 你的API-Key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-1",
    "prompt": "A cinematic illustration of a programmer working late at night, multiple monitors, warm desk lamp, city lights through window, deep navy and amber tones",
    "n": 1,
    "size": "1536x1024",
    "quality": "medium",
    "response_format": "b64_json"
  }' | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
img = base64.b64decode(data['data'][0]['b64_json'])
open('output.png', 'wb').write(img)
print('保存成功：output.png')
"
```

`response_format` 有两种取值：

- `url`：返回 base64 data URI（`data:image/png;base64,...`），可直接用于 `<img>` 标签
- `b64_json`：返回纯 base64 字符串，适合存为本地文件

批量处理两种都可以，`b64_json` 解析更直接。

## 方式二：Python SDK

有了 API Key，用 OpenAI 官方 Python SDK 只需要把 `base_url` 指向 Code80：

```python
from openai import OpenAI
import base64
from pathlib import Path

client = OpenAI(
    api_key="你的API-Key",
    base_url="https://code.ai80.vip/v1"
)

response = client.images.generate(
    model="gpt-image-1",
    prompt="A dramatic split-screen editorial illustration. Left: glowing purple terminal. Right: bold green terminal. Beams colliding center. Dark cyberpunk style.",
    n=1,
    size="1536x1024",
    quality="medium",
    response_format="b64_json"
)

image_data = base64.b64decode(response.data[0].b64_json)
Path("cover.png").write_bytes(image_data)
print("生成完成")
```

和直连 OpenAI 官方接口的写法一样，区别只有 `api_key` 和 `base_url` 两处。

### 参数说明

| 参数 | 常用值 | 说明 |
|------|--------|------|
| `size` | `1024x1024` / `1536x1024` / `1024x1536` | 方图 / 横图 / 竖图 |
| `quality` | `low` / `medium` / `high` | 速度与质量的取舍，`medium` 是多数场景的平衡点 |
| `n` | `1` | 每次生成数量，建议先用 1 张把 Prompt 调好再批量 |
| `response_format` | `url` / `b64_json` | `url` 返回 data URI，`b64_json` 返回纯 base64 字符串 |

Prompt 建议用英文描述。生成中文文字的能力还不够稳定，如果图里不需要出现文字，用英文描述的效果更可控。

### 关于 gpt-image-2

`gpt-image-2` 不走 `/v1/images/generations` 接口，而是通过 **Responses API** 调用，同样只需要 Code80 API Key。

调用示例：

```bash
curl -s https://code.ai80.vip/v1/responses \
  -H "Authorization: Bearer 你的API-Key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "input": "A cinematic illustration of a programmer working late at night",
    "tools": [{"type": "image_generation"}]
  }' | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
img = base64.b64decode(data['output'][0]['result'])
open('output.png', 'wb').write(img)
print('保存成功：output.png')
"
```

返回结构和 `gpt-image-1` 不同，图片 base64 在 `output[0].result` 字段里。

两个模型的对比：

- `gpt-image-1`：标准生图接口，接入简单，日常配图够用
- `gpt-image-2`：Responses API，中文文字渲染和插画质量更好，配置稍复杂

### 常见问题

#### 1. 提示 401 错误

通常优先检查：

- API Key 填错了，或已失效
- Key 不是 **OpenAI 分组**（生图必须走 OpenAI 接口）
- `base_url` 漏了 `/v1`，写成了根地址

我实际验证过 Code80：

- `POST https://code.ai80.vip/v1/images/generations` 未鉴权会返回 `401`
- `POST https://code.ai80.vip/v1/responses` 未鉴权也会返回 `401`

这说明接口本身是通的，`401` 更偏向鉴权或配置问题。

#### 2. response_format: "url" 返回的不是 HTTP 链接

Code80 的 `url` 模式实际返回的是 `data:image/png;base64,...` 格式的 data URI，不是带时效的 HTTP 链接。可以直接塞进 `<img src="">` 使用。如果需要保存为文件，用 `b64_json` 更直接。

#### 3. 生成很慢

`quality` 设成 `high` 会明显变慢。大多数配图场景 `medium` 就够用，速度和质量更平衡。先用 `medium` 把 Prompt 调好，确实需要高清再切 `high`。

#### 4. base_url 到底要不要带 /v1

生图走 OpenAI 兼容接口，推荐写成 `https://code.ai80.vip/v1`。Claude / Anthropic 兼容接入用的是根地址，两者配置习惯不同，注意别混用。

## 方式三：Skill 一键生图

不想手写代码，可以直接给 Claude Code / Codex 说：

```
帮我安装这个 skill: https://docs.ai80.vip/skills/gen-gpt-image-2.md
```

Agent 会自动把 `gen-gpt-image-2` skill 装好。之后只需要说：

```
/gen-gpt-image-2 A programmer working late at night, city lights, warm lamp
```

Agent 会自动调用 Code80 的 `gpt-image-2` 模型，把图片保存到本地。

Skill 功能：
- 自动读取 `CODE80_API_KEY` 环境变量，或询问你提供 Key
- 调用 `gpt-image-2` Responses API 生图
- 结果保存为 `image_<时间戳>.png`
