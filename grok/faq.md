---
description: xAI 官方 Grok Build 通过 Code80 中转时的安装、认证、模型选择和上游错误排查
---

# 排障与常见问题

## 为什么 `/model` 只有当前模型

通常是只配置了单个 `[model.*]`，却没有配置模型目录，或当前进程没有 `XAI_API_KEY`。

按[配置页](./config)补齐：

```toml
[endpoints]
models_base_url = "https://code.ai80.vip/v1"
models_list_url = "https://code.ai80.vip/v1/models"
```

确认下面命令返回 `200` 后，退出并重新启动 `grok`：

```bash
curl -s -o /dev/null -w '%{http_code}\n' \
  -H "Authorization: Bearer $XAI_API_KEY" \
  https://code.ai80.vip/v1/models
```

## 为什么出现 `auth.x.ai/.well-known/openid-configuration`

这表示 Grok Build 没有发现可用的 API Key，退回到了 xAI 的浏览器登录。对于 Code80 中转，不需要走这个流程。

检查当前 Shell：

```bash
test -n "$XAI_API_KEY" && echo 'XAI_API_KEY is set' || echo 'XAI_API_KEY is missing'
```

如果缺失，重新加载用户级环境变量后再启动 `grok`。不要把中转 Key 发送给 `auth.x.ai`，也不要通过修改 OIDC 地址解决该问题。

## `/v1/models` 返回 200，但聊天请求是 502 或 503

这说明 Key 和模型目录权限有效，但中转的上游推理服务暂时不可用，或所选模型没有可用上游账号。它不是 401/403 认证错误。

保留以下两条测试结果再联系服务方：

1. `GET /v1/models` 的状态码和目标模型是否在列表中。
2. 最小 `POST /v1/chat/completions` 的状态码、模型名和错误体，不包含 Key。

稍后重试或切换到目录中另一款文本模型。不要通过反复登录 xAI 来解决中转的 5xx。

## TUI 显示 `Turn cancelled by user`

这是当前轮被用户按下取消键或终端中断，不是安装或 API Key 配置错误。先重新发起一个简短请求；如果每次都在固定时间停止，再检查网络超时和中转上游状态。

## 官方安装器下载失败

- 确认 `https://x.ai/cli/install.sh` 可访问，检查企业代理、DNS 和 TLS。
- 官方脚本会在主站不可达时回退到官方 GCS 发行源。
- 不要关闭 TLS 校验，也不要改装同名社区包作为替代。

## 安装后还是启动了旧 CLI

运行：

```bash
which -a grok
command -v grok
grok --version
```

官方当前二进制应优先位于 `~/.grok/bin/grok`。清理旧 npm 包、把 `~/.grok/bin` 放到 PATH 前面，并执行 `hash -r` 后再次检查。

## 如何判断配置是否真的走了 Code80

检查两类证据：

1. `~/.grok/config.toml` 中的推理和目录地址均为 `https://code.ai80.vip/v1`。
2. 使用脱敏的 `curl` 测试能访问该地址的 `/v1/models` 和目标推理端点。

不要只看 TUI 底部的显示名称；它只能说明一个本地模型条目已加载，不能证明模型目录认证或上游推理服务正常。
