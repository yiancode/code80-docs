---
description: 使用 Code80 OpenAI 兼容接口配置 xAI 官方 Grok Build，包含模型目录、Key 安全和验证方法
---

# Code80 中转配置

## 前置条件

- 已按[官方安装](./install)安装当前 Grok Build。
- 已创建可以访问 Grok 模型的 Code80 API Key。
- 中转基础地址为 `https://code.ai80.vip/v1`。

## 安全保存 Key

不要把真实 Key 写入仓库。macOS 可以保存到登录钥匙串：

```bash
security add-generic-password -U \
  -a "$USER" \
  -s 'code80-grok-api-key' \
  -w 'YOUR_CODE80_API_KEY'
```

在 `~/.zshrc` 加入：

```bash
export XAI_API_KEY="$(security find-generic-password -a "$USER" -s 'code80-grok-api-key' -w 2>/dev/null)"
```

重新打开终端，或在当前终端执行：

```bash
source ~/.zshrc
```

`XAI_API_KEY` 这个变量名是有意使用的：官方 Grok Build 用它为自定义 `/v1/models` 目录请求添加 `Authorization: Bearer`。不要只设置自定义名称的环境变量，否则聊天模型可能有凭据，但 `/model` 仍无法加载远端模型。

## 创建官方配置

创建 `~/.grok/config.toml`：

```toml
[models]
default = "code80-grok-build"

[model.code80-grok-build]
model = "grok-build-0.1"
name = "Grok Build via Code80"
base_url = "https://code.ai80.vip/v1"
env_key = "XAI_API_KEY"
api_backend = "chat_completions"
context_window = 128000

[endpoints]
models_base_url = "https://code.ai80.vip/v1"
models_list_url = "https://code.ai80.vip/v1/models"
```

限制配置文件权限：

```bash
chmod 600 ~/.grok/config.toml
```

不要在文档、截图或仓库示例中填入真实 `api_key`。如果必须为自动化写入 Key，使用受限权限的用户级配置，并确认不在 Git 仓库内。

## 为什么既要 `base_url` 又要 `models_base_url`

- `[model.*].base_url` 决定实际推理请求发送到哪里。
- `[endpoints].models_base_url` 和 `models_list_url` 决定 `/model` 从哪里读取模型目录。

只配置前者时，Grok Build 只知道手工声明的一个模型，`/model` 通常只显示当前项。配置目录端点并重启后，模型选择器会读取中转返回的 `/v1/models`。

## 验证顺序

先验证 Key 是否有目录访问权限：

```bash
curl -sS https://code.ai80.vip/v1/models \
  -H "Authorization: Bearer $XAI_API_KEY"
```

再验证一个实际模型的推理端点：

```bash
curl -sS https://code.ai80.vip/v1/chat/completions \
  -H "Authorization: Bearer $XAI_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "grok-build-0.1",
    "messages": [{"role": "user", "content": "Reply with exactly: OK"}],
    "max_tokens": 4
  }'
```

最后重启 `grok`，输入 `/model`。模型目录在启动时读取，已打开的 TUI 不会自动刷新。

::: tip 模型名
中转返回的模型名以 `/v1/models` 为准。示例中的 `grok-build-0.1` 仅在该模型出现在你的账号模型目录时使用；否则替换成目录中实际返回的文本模型。
:::
