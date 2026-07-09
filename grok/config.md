---
description: Grok CLI 配置详解，包括 Code80 API Key、GROK_BASE_URL、grok-4.3、项目配置和优先级
---

# Grok CLI 配置详解

Grok CLI 的密钥、Base URL 和模型来自不同配置入口。Code80 接入时，最稳妥的组合是：

- API Key：保存到用户配置文件
- Base URL：保存为 `GROK_BASE_URL` 环境变量
- 默认模型：在用户配置中设为 `grok-4.3`

## 配置文件位置

| 用途 | macOS / Linux | Windows |
|------|---------------|---------|
| 用户配置 | `~/.grok/user-settings.json` | `%USERPROFILE%\.grok\user-settings.json` |
| 项目配置 | `项目目录/.grok/settings.json` | `项目目录\.grok\settings.json` |

## 配置 API Key

在 Code80 控制台创建一个可以访问 Grok 模型的 API Key，然后创建或编辑用户配置：

```json
{
  "apiKey": "your-api-key",
  "defaultModel": "grok-4.3"
}
```

`your-api-key` 只是占位符，请替换为自己的 Key。已有配置时应合并字段，避免覆盖 MCP、子代理或其他设置。

macOS / Linux 建议收紧权限：

```bash
chmod 700 ~/.grok
chmod 600 ~/.grok/user-settings.json
```

::: tip 为什么不推荐 `grok -k your-api-key`
`-k` 会保存密钥，但密钥也可能进入 shell 历史或进程参数。手工编辑权限为 `0600` 的配置文件更安全。
:::

## 配置 Code80 Base URL

Code80 的 Grok API 前缀是：

```text
https://code.ai80.vip/v1
```

### zsh

编辑 `~/.zshrc`，加入：

```bash
export GROK_BASE_URL="https://code.ai80.vip/v1"
```

然后执行：

```bash
source ~/.zshrc
```

### bash

编辑 `~/.bashrc`，加入：

```bash
export GROK_BASE_URL="https://code.ai80.vip/v1"
```

然后执行：

```bash
source ~/.bashrc
```

### fish

```fish
set -Ux GROK_BASE_URL https://code.ai80.vip/v1
```

### Windows PowerShell

设置当前终端：

```powershell
$env:GROK_BASE_URL = "https://code.ai80.vip/v1"
```

永久保存到当前用户：

```powershell
[Environment]::SetEnvironmentVariable(
  "GROK_BASE_URL",
  "https://code.ai80.vip/v1",
  "User"
)
```

永久设置后需要重新打开终端。

::: danger 不要把地址写成完整接口
正确值是 `https://code.ai80.vip/v1`，不要写成 `/v1/chat/completions` 或 `/v1/responses`。CLI 会自行追加接口路径。
:::

## 1.1.7 的 baseURL 陷阱

下面这种旧版配置在 Grok CLI 1.1.7 中不会生效：

```json
{
  "baseURL": "https://code.ai80.vip/v1"
}
```

当前版本只从 `--base-url` 或 `GROK_BASE_URL` 读取中转地址。`--base-url` 也不会自动持久化，所以长期使用应配置环境变量。

## 模型配置

推荐默认使用：

```text
grok-4.3
```

启动时指定模型并保存为新的用户默认值：

```bash
grok -m grok-4.3
```

Grok CLI 1.1.7 会把 `-m` / `--model` 写回用户配置的 `defaultModel`。只想为单次命令覆盖、又不修改用户默认值时，可以使用进程级环境变量：

```bash
GROK_MODEL=grok-4.3 grok -p "只回复 OK"
```

使用环境变量强制所有项目使用同一模型：

```bash
export GROK_MODEL="grok-4.3"
```

只有确实希望禁止项目或执行模式切换模型时才设置 `GROK_MODEL`。日常使用保留 `defaultModel` 更灵活。

项目可以在 `.grok/settings.json` 中单独指定模型：

```json
{
  "model": "grok-4.3"
}
```

## 配置优先级

| 配置 | 从高到低 |
|------|----------|
| API Key | `--api-key` → `GROK_API_KEY` → 用户配置 `apiKey` |
| Base URL | `--base-url` → `GROK_BASE_URL` → xAI 官方默认地址 |
| 模型 | `--model` → `GROK_MODEL` → 项目 `.grok/settings.json` → 当前执行模式的模型 → 用户配置 `defaultModel` |

如果全局已经设置 `grok-4.3`，某个目录仍请求旧模型，优先检查该项目的 `.grok/settings.json` 和 `GROK_MODEL`。

上表描述的是启动时的解析顺序。在交互界面中切换执行模式后，该模式配置的模型仍可能成为当前模型；需要始终锁定同一模型时，使用 `GROK_MODEL`。

## 查看和验证配置

确认环境变量：

```bash
echo "$GROK_BASE_URL"
```

查看 CLI 本地模型目录：

```bash
grok models
```

::: warning `grok models` 不是服务端模型列表
该命令显示 Grok CLI 内置的模型目录，不代表当前 Code80 API Key 一定有权调用。实际可用模型以 Code80 控制台和 `/v1/models` 返回结果为准。
:::

做一次端到端验证：

```bash
grok -m grok-4.3 -p "只回复 GROK_CLI_OK"
```

## 安全建议

- 不要把真实 API Key 写进项目仓库、截图或聊天记录
- 不要把 `user-settings.json` 复制到公开目录
- 怀疑泄露时立即在 Code80 控制台轮换 Key
- CI 中使用密钥管理服务注入 `GROK_API_KEY`，不要硬编码
- Base URL 不是秘密，可以保存在 shell 配置中

## 上游项目参考

- [Grok CLI README](https://github.com/superagent-ai/grok-cli#api-key-pick-one)
- [Grok CLI v1.1.7 配置读取逻辑](https://github.com/superagent-ai/grok-cli/blob/grok-dev%401.1.7/src/utils/settings.ts#L312-L335)
