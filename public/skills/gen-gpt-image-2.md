---
name: gen-gpt-image-2
description: 使用 Code80 平台的 gpt-image-2 模型生成图片。配置好 API Key 后，一句话描述即可生图，结果保存为本地 PNG 文件。支持中文描述，渲染质量优于 gpt-image-1。当用户说"生成图片""画一张""gen image"或使用 /gen-gpt-image-2 时触发。
---

# gen-gpt-image-2：Code80 GPT Image 2 生图

通过 Code80 平台调用 `gpt-image-2` 模型，一句话描述生成图片，保存为本地 PNG 文件。

## 触发方式

- `/gen-gpt-image-2 [描述]`
- "帮我生成一张图：[描述]"
- "用 gpt-image-2 画一张[描述]"
- "生成图片：[描述]"

## 执行步骤

### 第 1 步：获取 API Key

按以下顺序查找：

1. 检查环境变量 `CODE80_API_KEY`
2. 检查环境变量 `OPENAI_API_KEY`
3. 以上都没有，询问用户："请提供你的 Code80 API Key（需要 OpenAI 分组的 Key，在 https://code.ai80.vip 创建）"

### 第 2 步：获取生图描述

从用户的触发语句中提取 prompt。如果没有描述，询问用户："请描述你想生成的图片内容："

**Prompt 建议**：
- 英文描述效果更稳定
- 中文描述也支持，尤其是需要图中出现中文文字时效果较好
- 描述越具体，生成效果越可控

### 第 3 步：调用 Responses API 生图

执行以下命令（将 `$API_KEY` 和 `$PROMPT` 替换为实际值）：

```bash
curl -s https://code.ai80.vip/v1/responses \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"gpt-image-2\",
    \"input\": \"$PROMPT\",
    \"tools\": [{\"type\": \"image_generation\"}]
  }" | python3 -c "
import sys, json, base64, time
data = json.load(sys.stdin)
if data.get('status') != 'completed':
    print('生图失败:', json.dumps(data, ensure_ascii=False, indent=2))
    exit(1)
outputs = data.get('output', [])
if not outputs or not outputs[0].get('result'):
    print('响应中没有图片数据:', json.dumps(data, ensure_ascii=False, indent=2))
    exit(1)
filename = f'image_{int(time.time())}.png'
open(filename, 'wb').write(base64.b64decode(outputs[0]['result']))
print(f'生成成功：{filename}')
"
```

生图通常需要 15–30 秒，请等待命令执行完成。

### 第 4 步：汇报结果

- 成功：告诉用户图片保存在哪个文件，可以用系统图片查看器打开
- 失败：显示错误信息，常见原因：
  - `401`：API Key 不正确或不是 OpenAI 分组的 Key
  - `400`：Prompt 内容触发了内容过滤

## 配置说明

| 配置项 | 值 |
|--------|-----|
| Base URL | `https://code.ai80.vip/v1` |
| 模型 | `gpt-image-2` |
| 接口 | `POST /responses` |
| 鉴权 | Bearer Token（Code80 OpenAI 分组 Key） |

## 常见问题

**Q：API Key 去哪里获取？**  
在 [Code80 控制台](https://code.ai80.vip) 创建，选择 **OpenAI 分组**。

**Q：和 gpt-image-1 有什么区别？**  
`gpt-image-2` 中文文字渲染更准确、插画质量更好；`gpt-image-1` 接口更简单（标准 images API），两者都用 Code80 普通 API Key 即可。

**Q：图片保存在哪里？**  
保存在命令执行时的当前目录，文件名为 `image_<时间戳>.png`。
