---
description: Grok CLI 常见问题与排障指南，包括 grok-code-fast-1、Base URL、模型列表、认证、限流和平台兼容性
---

# Grok CLI 常见问题

## 模型问题

### 提示 `404 The model 'grok-code-fast-1' does not exist`

这通常不是 Code80 中转不可用，而是终端命中了旧的同名 CLI。当前 1.1.7 会在请求前把 `grok-code-fast-1` 这个旧别名转换成 `grok-4.3`；如果服务端错误仍显示旧模型名，几乎可以确定运行的不是当前程序。确认二进制后，再排查环境变量和项目模型覆盖。

<figure>
  <img src="/grok/grok-code-fast-1-error.png" alt="Grok CLI 请求 grok-code-fast-1 返回 404 的真实终端截图" loading="lazy" />
  <figcaption>真实终端截图：旧版 CLI 将 grok-code-fast-1 直接发给中转站后返回 404。</figcaption>
</figure>

按顺序排查：

```bash
type -a grok
command -v grok
grok --version
```

本教程核验的当前版本是 `1.1.7`；看到 `0.0.34` 基本可以确认命中了旧的 `@vibe-kit/grok-cli`。

官方脚本安装的当前程序通常位于 `~/.grok/bin/grok`。先绕过 PATH 直接验证：

```bash
~/.grok/bin/grok -m grok-4.3 -p "只回复 OK"
```

如果这样可以使用，说明 PATH 中仍有旧版 `@vibe-kit/grok-cli`。确认不再需要后，根据旧包的安装方式执行其中一条卸载命令，并刷新命令缓存：

```bash
export PATH="$HOME/.grok/bin:$PATH"
npm uninstall -g @vibe-kit/grok-cli
bun remove -g @vibe-kit/grok-cli  # 旧包由 Bun 安装时使用
hash -r  # bash
rehash   # zsh
```

把 `export PATH=...` 写入 `~/.zshrc` 或 `~/.bashrc`，可以确保新程序长期优先。

如果仍请求旧模型，再检查：

```bash
echo "$GROK_MODEL"
```

以及当前项目的 `.grok/settings.json`。命令行 `-m grok-4.3` 在启动时优先级最高，但 1.1.7 也会把它保存为新的用户默认模型。只做一次不持久化的诊断时，使用：

```bash
GROK_MODEL=grok-4.3 grok -p "只回复 OK"
```

### `grok models` 里有模型，为什么调用仍然 404？

`grok models` 展示的是 CLI 内置的本地模型目录，不会实时读取 Code80 `/v1/models`。模型是否真的可用，取决于当前 API Key 绑定分组的模型权限。

先用教程默认的 `grok-4.3` 验证基础链路；其他模型以 Code80 控制台或 `/v1/models` 的实际返回为准。

## Base URL 问题

### 已在 JSON 中写了 `baseURL`，为什么仍然直连 xAI？

Grok CLI 1.1.7 不读取 `user-settings.json` 中的 `baseURL`。请改用环境变量：

```bash
export GROK_BASE_URL="https://code.ai80.vip/v1"
```

长期使用时把它写入 `~/.zshrc` 或 `~/.bashrc`，然后重新加载并重启 Grok CLI：

```bash
source ~/.zshrc  # zsh
echo "$GROK_BASE_URL"
```

也可以临时使用：

```bash
grok --base-url https://code.ai80.vip/v1 -m grok-4.3
```

`--base-url` 只对本次启动生效，不会自动保存。

### Base URL 末尾要不要带 `/v1`？

要。正确值是：

```text
https://code.ai80.vip/v1
```

不要写成根地址，也不要继续追加 `/chat/completions` 或 `/responses`。

## API Key 问题

### 交互界面不接受 `sk-` 开头的 Code80 Key

部分版本的初次配置界面可能按 xAI 官方 Key 格式做前端校验。可以跳过该界面，直接创建 `~/.grok/user-settings.json`：

```json
{
  "apiKey": "your-api-key",
  "defaultModel": "grok-4.3"
}
```

再通过 `GROK_BASE_URL` 指向 Code80。不要把真实 Key 写进项目目录或提交到 Git。

### 返回 401 或 403

- 确认 API Key 完整、未过期且未被禁用
- 确认 Key 绑定的分组可以访问 Grok 模型
- 确认当前进程读取的是预期配置，而不是旧的 `GROK_API_KEY`
- 修改配置后完全退出并重启 Grok CLI

检查是否有环境变量覆盖：

```bash
printenv GROK_API_KEY
printenv GROK_BASE_URL
```

环境变量中有旧 Key 时，可以先执行 `unset GROK_API_KEY`，让 CLI 回到用户配置文件中的 `apiKey`。

## 运行问题

### 配置修改后不生效

Grok CLI 启动时读取配置。退出当前会话、重新加载 shell 配置，然后再次启动：

```bash
source ~/.zshrc  # 或 source ~/.bashrc
grok -m grok-4.3
```

同时检查项目 `.grok/settings.json` 是否覆盖了用户默认模型。

### 返回 429

表示请求频率、并发或额度达到限制。等待后重试，减少并发，并在 Code80 控制台检查配额和余额。

### 返回 5xx 或响应中断

先重试一次最小文本请求：

```bash
grok -m grok-4.3 -p "只回复 OK"
```

如果最小请求正常，问题通常来自某个扩展能力、上下文长度或工具调用；如果持续失败，再检查 Code80 服务状态和上游账号可用性。

### 终端界面错位或颜色异常

- 更新到最新版本
- 使用支持 Unicode 和真彩色的现代终端
- 检查终端窗口宽度与字体
- 自动化场景改用 `grok -p` 无头模式

### `--sandbox` 在 Linux 或 Intel Mac 上不可用

这是当前 Shuru 沙箱的平台限制。它只支持 macOS 14+ Apple Silicon；其他系统使用主机模式即可。

内置 `/verify` 和 `--verify` 也强制使用 Shuru，不会降级到主机模式。其他平台应在普通会话中直接要求 agent 运行 lint、类型检查和测试。

## 功能兼容问题

### `--batch-api` 或 Telegram 语音为什么报 404？

Grok CLI 的批处理模式请求 `/batches`，Telegram 语音转写请求 `/stt`。Code80 当前没有提供这两个端点，因此这两项能力无法通过当前中转使用。普通交互和 `-p` 无头模式不受影响。

### 搜索、Responses 或媒体能力报错，但普通对话正常

这些能力依赖特定的 Grok 上游账号、协议和模型权限。普通 `grok-4.3` 请求正常，说明 API Key 与 Base URL 基础配置已经成功；请再确认当前分组是否开放对应能力。

## 仍然无法解决？

排障时建议保留以下非敏感信息：

- `grok --version`
- `command -v grok` 或 `Get-Command grok -All`
- 操作系统与 CPU 架构
- 使用的模型名和完整错误码
- `GROK_BASE_URL` 的值（不要提供 API Key）

继续查看：[安装详解](./install) · [配置详解](./config)
