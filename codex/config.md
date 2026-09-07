---
description: Codex CLI 配置详解：config.toml 官方推荐与最佳实践、Code80 接入、全部参数含义与精确模型 ID（gpt-5.6-terra / gpt-5.6-sol / gpt-5.6-luna）
---

# Codex CLI 配置详解

Codex 的 `config.toml` 不必把所有键都写上。官方明确说：内置默认值已经可用，只把你真正要改的键写进 `~/.codex/config.toml`。CLI、IDE 插件、桌面端共用同一套配置层。

官方参考：

- [Config basics](https://developers.openai.com/codex/config-basic)
- [Sample Configuration](https://developers.openai.com/codex/config-sample)
- [Configuration Reference](https://developers.openai.com/codex/config-reference)
- [Advanced Config](https://developers.openai.com/codex/config-advanced)
- Schema：<https://developers.openai.com/codex/config-schema.json>

编辑时建议在文件第一行加上：

```toml
#:schema https://developers.openai.com/codex/config-schema.json
```

配合 VS Code / Cursor 的 Even Better TOML 插件，可以自动补全和校验。

::: warning 不要写 `gpt-5.6`
官方 sample 里偶尔会出现 `model = "gpt-5.6"`，那是家族别名，不是 Code80 上的可用模型 ID。Code80 的 GPT-5.6 只有三个精确 ID：

- `gpt-5.6-terra`：日常默认
- `gpt-5.6-sol`：复杂编码、审查、研究
- `gpt-5.6-luna`：快、便宜、重复性任务

不要写成 `gpt-5.6`，也不要写成 `gpt-luna`。Luna 的精确 ID 是 `gpt-5.6-luna`。
:::

## Code80 推荐配置

接 Code80 时，用户级配置从这份开始即可。密钥放在 `auth.json`，不要写进 toml。

从 Codex **0.149.0** 起，自定义 provider 必须同时满足两件事，否则会 401 或每次提问先卡「正在重新连接 1/5 … 5/5」：

1. `requires_openai_auth = true`，让请求走 `auth.json` 里的 Key
2. `supports_websockets = false`，跳过 WSS，直接走 HTTP

不要改内置的 `openai` provider，单独建一个。全文件只能有一个 `model_provider`。

`~/.codex/config.toml`：

```toml
#:schema https://developers.openai.com/codex/config-schema.json

model = "gpt-5.6-terra"
model_provider = "codex"
model_reasoning_effort = "medium"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
web_search = "cached"
personality = "pragmatic"
forced_login_method = "api"

[model_providers.codex]
name = "codex"
base_url = "https://code.ai80.vip"
wire_api = "responses"
requires_openai_auth = true
supports_websockets = false

[sandbox_workspace_write]
network_access = false

[features]
multi_agent = true
shell_snapshot = true
memories = false

[history]
persistence = "save-all"
```

`~/.codex/auth.json`：

```json
{
  "OPENAI_API_KEY": "your-api-key"
}
```

把 `your-api-key` 换成 Code80 控制台里 **OpenAI 分组** 的 Key。macOS / Linux 建议收紧权限：

```bash
chmod 700 ~/.codex
chmod 600 ~/.codex/config.toml ~/.codex/auth.json
```

改完必须**彻底退出再打开**（macOS 用 Cmd+Q，Windows 结束进程），并用**新对话**测试。只关窗口不够，旧会话可能还绑着原来的连接方式。

::: tip 为什么默认是 terra
官方 Config basics 把「人们最常改」的组合写成：日常写代码用 `workspace-write` + `on-request`。模型侧，Terra 是 GPT-5.6 里性价比均衡的一档，适合作为个人默认。难任务再换成 `gpt-5.6-sol`，或把 `model_reasoning_effort` 调到 `high` / `xhigh`。
:::

::: danger 0.149.0 之后不要再这样配
- 不要写 `requires_openai_auth = false` 还指望自动读 `auth.json`。这是升级后出现 `API_KEY_REQUIRED` / `401 Unauthorized` 的原因。
- 不要去改内置 `[model_providers.openai]`。直接改内置项经常不生效；WSS 关不掉，就会每次先重连 5 次再降级 HTTP。
- 旧文档里的 `model_provider = "Custom"` 可以继续用，但必须补上 `requires_openai_auth = true` 和 `supports_websockets = false`。新配置统一用 `codex` 这个名字即可。
:::

## 0.149.0 之后的两个必改项

这两条是接中转时最常见的故障，已经并进上面的推荐配置。如果你是从旧配置升上来的，对照改。

### 401 / API_KEY_REQUIRED

Codex 0.149.0 起，自定义 provider 在 `requires_openai_auth = false` 时**不再**自动继承 `auth.json` 鉴权。表现是升级后突然 `API_KEY_REQUIRED` 或 `401 Unauthorized`。

处理：

1. 顶层 `model_provider = "codex"`（或你自己的自定义 ID，不要用内置 `openai`）
2. 对应表里写 `requires_openai_auth = true`
3. 保留 `~/.codex/auth.json` 的 `OPENAI_API_KEY`
4. 彻底退出再打开

不要用 `requires_openai_auth = false` 后继续依赖 `auth.json`。

### 每次提问卡在「正在重新连接 1/5 … 5/5」

这不是账号坏了，也不是模型挂了。Codex 默认先走 WebSocket（WSS）。很多中转能转 HTTPS，但转不好 WSS，于是先失败、重试满 5 次，再降级到 HTTP。HTTP 通常是通的，所以最后又能出字，只是每次白等一轮。

处理：自定义 provider 写 `supports_websockets = false`，强制走 HTTP。不要改内置 `openai`，单独建一个；直接改内置项经常不生效。

改完必须彻底退出（Windows 结束进程 / macOS Cmd+Q），并用新对话测试。旧会话可能还绑着原来的连接方式。

## 配置文件位置与优先级

| 层级 | 路径 | 作用 |
|------|------|------|
| 用户级 | `~/.codex/config.toml`（Windows 一般是 `%USERPROFILE%\.codex\config.toml`） | 个人默认：模型、审批、沙箱、MCP、通知 |
| 项目级 | 仓库里的 `.codex/config.toml` | 只对已信任项目生效 |
| Profile | `~/.codex/<名字>.config.toml` | `codex --profile <名字>` 时叠加 |
| 系统级 | `/etc/codex/config.toml`（Unix） | 整机 / 团队基线 |
| 状态目录 | `$CODEX_HOME`，默认 `~/.codex` | config、auth、logs、sessions、skills |

优先级从高到低：

1. 命令行 flags / `--config`
2. 项目 `.codex/config.toml`（从仓库根到当前目录，最近的赢；未信任项目不加载）
3. `--profile` 对应的 `~/.codex/<name>.config.toml`
4. 用户 `~/.codex/config.toml`
5. 系统 `/etc/codex/config.toml`
6. 内置默认值

企业还可以用 `requirements.toml` 锁死安全边界（例如禁止 `danger-full-access`、禁止 `approval_policy = "never"`）。这不是普通覆盖，而是硬约束。

项目级配置会被忽略的键（必须写在用户级）：

`openai_base_url`、`chatgpt_base_url`、`apps_mcp_product_sku`、`model_provider`、`model_providers`、`notify`、`profile`、`profiles`、`experimental_realtime_ws_base_url`、`otel`

这些会改凭据、登录、通知、遥测，不能让仓库里的文件劫持本机。

::: danger TOML 硬规则
根键必须写在 `[table]` 前面。顺序反了会直接解析失败。
:::

## 官方推荐 vs 日常最佳实践

官方 sample 更保守（安全默认）；Config basics 更贴近日常写代码。两者要分开看。

官方 sample 的安全默认大致是：

```toml
model = "gpt-5.6-terra"
model_provider = "openai"
approval_policy = "on-request"
sandbox_mode = "read-only"
web_search = "cached"
```

`sandbox_mode = "read-only"` 是「默认最安全」，不是「日常最好用」。

官方 Config basics 里人们最常改的组合：

```toml
model = "gpt-5.6-terra"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
web_search = "cached"
```

接 Code80 时再叠一层自定义 provider，就是上一节的推荐配置。

核心原则：

- 个人默认放 `~/.codex/config.toml`
- 仓库行为放 `.codex/config.toml` + `AGENTS.md`
- 命令行只做一次性覆盖
- 先紧后松：新项目 / 不信任目录用 `read-only`；信任的 git 仓库再用 `workspace-write`
- 不要一上来 `--yolo` / `danger-full-access`

## 模型怎么选

Code80 上 Codex 日常只用这三个精确 ID：

| 模型 ID | 适合 |
|---------|------|
| `gpt-5.6-terra` | 日常默认，性价比均衡 |
| `gpt-5.6-luna` | 快、便宜、重复性任务 |
| `gpt-5.6-sol` | 复杂编码、研究、安全审查 |

会话里用 `/model` 临时切换；一次性任务用 `codex --model gpt-5.6-sol`。没写 `model` 时，客户端会用账号推荐默认，接 Code80 时请显式写上。

## 按模块解释参数

没写的键 = 用内置默认。下面按官方 sample + schema 归类。

### 模型与推理

| 键 | 类型 | 官方默认 / 建议 | 含义 |
|----|------|-----------------|------|
| `model` | string | 建议 `gpt-5.6-terra` | 默认模型 ID |
| `review_model` | string | 未设置 = 用当前会话模型 | `/review` 专用模型，审查可写成 `gpt-5.6-sol` |
| `model_provider` | string | `"openai"`；接 Code80 用 `"codex"` | 使用哪个 `[model_providers.<id>]`。全文件只能有一个 |
| `oss_provider` | string | 未设置则提示 | `--oss` 时的本地开源后端，如 `"ollama"` |
| `service_tier` | string | 未设置 | 服务档，如 `"fast"` / `"flex"` / `"priority"`，取决于模型目录 |
| `personality` | `none` / `friendly` / `pragmatic` | 未设置 | 沟通风格；会话里可用 `/personality` 改 |
| `model_reasoning_effort` | `minimal` / `low` / `medium` / `high` / `xhigh` | 跟模型走 | 思考强度。越高越慢、越贵、越稳 |
| `plan_mode_reasoning_effort` | 同上 + `none` | 未设置 | 规划模式单独覆盖 |
| `model_reasoning_summary` | `auto` / `concise` / `detailed` / `none` | `"auto"` | 推理摘要怎么展示 |
| `model_verbosity` | `low` / `medium` / `high` | `"medium"` | GPT-5 家族 Responses API 的文本冗长度 |
| `model_supports_reasoning_summaries` | bool | 未设置 | 强制开 / 关推理摘要（自定义 provider 常用） |
| `model_context_window` | int | 自动 | 上下文窗口 token 数；自定义模型不知道窗口时再写 |
| `model_auto_compact_token_limit` | int | 跟模型走 | 超过后自动压缩历史 |
| `model_auto_compact_token_limit_scope` | `total` / `body_after_prefix` | `"total"` | 压缩阈值按整段还是前缀之后计算 |
| `model_max_output_tokens` | int | 跟模型走 | 单次最大输出 |
| `tool_output_token_limit` | int | 未设置 | 单条工具输出存进历史的 token 上限 |
| `model_catalog_json` | path | 未设置 | 启动时覆盖模型目录 JSON |
| `model_instructions_file` | path | 未设置 | 用文件替换内置系统指令（旧名 `experimental_instructions_file` 已弃用） |
| `developer_instructions` | string | 未设置 | 额外用户指令，插在 `AGENTS.md` 前面 |
| `compact_prompt` | string | 未设置 | 内联覆盖历史压缩 prompt |
| `experimental_compact_prompt_file` | path | 未设置 | 从文件加载压缩 prompt |
| `background_terminal_max_timeout` | ms | `300000` | 后台终端空 `write_stdin` 最长轮询 |
| `log_dir` | path | `$CODEX_HOME/log` | 显式设置还会打开 `codex-tui.log` |
| `sqlite_home` | path | `$CODEX_HOME` | SQLite 运行时状态目录 |

配置建议：

- 日常：`model = "gpt-5.6-terra"` + `model_reasoning_effort = "medium"`
- 大重构 / 深审查：`high` 或 `xhigh`，或换 `gpt-5.6-sol`
- 批量改名、格式化、小补丁：`gpt-5.6-luna`

只改官方 OpenAI 的区域 / 代理时，写 `openai_base_url`，不必新建 provider。接 Code80 不要用这条，也不要改内置 `openai` provider，继续用下面的 `[model_providers.codex]`。

```toml
openai_base_url = "https://us.api.openai.com/v1"
```

### 审批与沙箱

这是最重要的安全开关。

| 键 | 取值 | 含义 |
|----|------|------|
| `approval_policy` | `untrusted` / `on-request` / `never` / granular 对象 | 什么时候停下来问你 |
| `approvals_reviewer` | `user` / `auto_review` | 谁来审这些审批。`auto_review` 用评审子代理 |
| `sandbox_mode` | `read-only` / `workspace-write` / `danger-full-access` | 文件系统 / 网络边界 |
| `default_permissions` | `:read-only` / `:workspace` / `:danger-full-access` 或自定义名 | 命名权限档 |
| `allow_login_shell` | bool，默认 `true` | 是否允许 login shell |

`approval_policy` 细节：

- `untrusted`：只有已知安全的只读命令自动跑，其它都问
- `on-request`（官方日常推荐）：模型自己判断何时询问；出沙箱、联网、高风险命令会停
- `never`：不问。只适合 CI / 隔离环境
- 旧值 `on-failure` 已弃用

granular 例子：

```toml
approval_policy = { granular = {
  sandbox_approval = true,
  rules = true,
  mcp_elicitations = true,
  request_permissions = false,
  skill_approval = false
} }
```

五个子开关分别控制：沙箱升级、execpolicy 规则、MCP elicitation、`request_permissions` 工具、skill 脚本审批。

`sandbox_mode` 细节：

- `read-only`：可读任意文件，写和联网默认拦。适合审代码、看仓库
- `workspace-write`：可写当前工作区；`.git` / `.codex` / `.agents` 仍只读；联网默认关
- `danger-full-access`：无沙箱。只在隔离 runner 里用

对应 CLI：

```bash
codex --sandbox workspace-write --ask-for-approval on-request
codex --dangerously-bypass-approvals-and-sandbox   # 也叫 --yolo，危险
```

官方常见组合：

| 场景 | 配置 |
|------|------|
| 日常写代码 | `sandbox_mode = "workspace-write"` + `approval_policy = "on-request"` |
| 只读浏览 | `read-only` + `on-request` |
| CI 只读 | `read-only` + `never` |
| 自动改文件，危险命令再问 | `workspace-write` + `untrusted` |
| 隔离 runner 全自动 | 才考虑 `never` + `danger-full-access` |

`[sandbox_workspace_write]` 只在 `sandbox_mode = "workspace-write"` 时生效：

| 键 | 默认 | 含义 |
|----|------|------|
| `writable_roots` | `[]` | 额外可写目录，如工具链 shims |
| `network_access` | `false` | 沙箱内出站网络 |
| `exclude_tmpdir_env_var` | `false` | 是否把 `$TMPDIR` 排除出可写根 |
| `exclude_slash_tmp` | `false` | 是否把 `/tmp` 排除出可写根 |

保护路径（即使在可写根里也只读）：

- `<root>/.git`
- `<root>/.codex`（若存在）
- `<root>/.agents`（若存在）

需要装 npm / pip 依赖时再开网络：

```toml
[sandbox_workspace_write]
network_access = true
```

更细的域名策略要用 `features.network_proxy` + `[permissions.<name>.network.domains]`，不要一上来全网开放。

::: warning 旧写法已经失效
早期文档里的顶层 `network_access = "enabled"` 不是当前 schema 的键。请改成 `sandbox_mode = "workspace-write"`，再在 `[sandbox_workspace_write]` 里写 `network_access = true`。
:::

Windows：

```toml
[windows]
sandbox = "elevated"          # 官方推荐
# sandbox = "unelevated"      # 没管理员权限时的回退
# sandbox_private_desktop = true
```

### 登录与认证

| 键 | 取值 | 含义 |
|----|------|------|
| `cli_auth_credentials_store` | `file` / `keyring` / `auto` / `ephemeral` | CLI 登录凭据存哪。默认 `file`（`~/.codex/auth.json`） |
| `chatgpt_base_url` | URL | ChatGPT 登录流，不是 OpenAI API |
| `openai_base_url` | URL | 只改内置 `openai` provider 的 API 根 |
| `forced_chatgpt_workspace_id` | UUID | 强制登录到某个 workspace |
| `forced_login_method` | `chatgpt` / `api` | 强制登录方式。接 Code80 用 `api` |
| `mcp_oauth_credentials_store` | `auto` / `file` / `keyring` | MCP OAuth 凭据存储 |
| `mcp_oauth_callback_port` | 1–65535 | 全局 OAuth 回调端口 |
| `mcp_oauth_callback_url` | URL | 远程 devbox 等自定义回调 |
| `mcp_optional_startup_grace_ms` | ms，默认 `1000` | 等可选 MCP 启动的宽限；`0` 则等每个 server 自己的 `startup_timeout_sec` |

接 Code80 时把 Key 放在 `~/.codex/auth.json` 的 `OPENAI_API_KEY`。不要把 Key 写进 toml。自定义 provider 必须写 `requires_openai_auth = true`，0.149.0 起否则不会继承 `auth.json`。

只换官方代理 / 数据驻留：优先 `openai_base_url`，不要复制一整套 `openai` provider。自定义 ID 不要占用内置保留名：`openai`、`ollama`、`lmstudio`、`amazon-bedrock`。`codex` 可以用来接中转。

### 自定义 Model Provider

接 Code80 的完整块。不要改内置 `openai`，单独建 `codex`：

```toml
model = "gpt-5.6-terra"
model_provider = "codex"

[model_providers.codex]
name = "codex"
base_url = "https://code.ai80.vip"
wire_api = "responses"
requires_openai_auth = true
supports_websockets = false
```

| 字段 | 含义 |
|------|------|
| `name` | UI 显示名 |
| `base_url` | API 根。Responses 会拼 `/responses`。接 Code80 写根地址，**不要**加 `/v1` |
| `env_key` | 读 API Key 的环境变量名，不要把 Key 写进 toml |
| `wire_api` | 协议。官方 OpenAI / Codex 模型用 `responses` |
| `query_params` | Azure 的 `api-version` 就写这里 |
| `http_headers` / `env_http_headers` | 静态头 / 从环境变量取值的头 |
| `request_max_retries` | HTTP 失败重试，默认 4，最大 100 |
| `stream_max_retries` | SSE 断线重连，默认 5，最大 100 |
| `stream_idle_timeout_ms` | 流空闲超时，默认 5 分钟 |
| `requires_openai_auth` | 是否走 Codex 的 OpenAI / ChatGPT 鉴权层（读 `auth.json`）。接 Code80 **必须 `true`**。默认 `false` 时 0.149.0+ 不会自动继承 `auth.json`，会 401 |
| `supports_websockets` | 是否先走 Responses WebSocket。接中转 **必须 `false`**。很多代理能转 HTTPS，转不好 WSS，会先「正在重新连接 1/5 … 5/5」再降级 HTTP |
| `supports_standalone_web_search` | 自定义 provider 是否声明独立搜索端点 |
| `auth.command` / `auth.args` | 用外部命令取 bearer token，不要和 `env_key` 混用 |

::: warning 第三方网关务必写出这三项
不同版本对默认值不完全一致。Code80 固定写：

- `wire_api = "responses"`
- `requires_openai_auth = true`
- `supports_websockets = false`

Chat Completions 协议在 Codex 里已弃用，后续版本会移除。直接改内置 `[model_providers.openai]` 经常不生效，WSS 关不掉。
:::

本地 Ollama：

```toml
model = "qwen2.5-coder"
model_provider = "ollama"
oss_provider = "ollama"
```

Azure：

```toml
model_provider = "azure"

[model_providers.azure]
name = "Azure"
base_url = "https://YOUR_RESOURCE.openai.azure.com/openai"
env_key = "AZURE_OPENAI_API_KEY"
wire_api = "responses"
query_params = { api-version = "2025-04-01-preview" }
```

### 项目文档（AGENTS.md）

| 键 | 默认 | 含义 |
|----|------|------|
| `project_doc_max_bytes` | `32768`（32 KiB） | 第一轮注入 `AGENTS.md` 的最大字节 |
| `project_doc_fallback_filenames` | `[]` | 没有 `AGENTS.md` 时的备用文件名列表 |
| `project_root_markers` | `[".git"]` | 向上找项目根的标记。`[]` = 不向上找，当前目录就是根 |
| `file_opener` | `"vscode"` | 点击引用用的 URI：`vscode` / `vscode-insiders` / `windsurf` / `cursor` / `none` |

仓库约定（怎么构建、测试、不要做什么）写在 `AGENTS.md`，比把长指令塞进 `developer_instructions` 更稳。

### 联网搜索

顶层键 `web_search`（不要再用 `[features]` 里那几个已弃用开关）：

| 值 | 含义 |
|----|------|
| `cached`（默认） | 走 OpenAI 维护的搜索索引，不直接上公网 |
| `indexed` | 只有索引允许时才出网 |
| `live` | 实时检索，等同 `--search` |
| `disabled` | 去掉搜索工具 |

`--yolo` 或 `danger-full-access` 时，搜索默认变成 `live`。

更细的搜索工具还可以写：

```toml
[tools]
web_search = { context_size = "medium", allowed_domains = ["docs.python.org"] }
```

`allowed_domains` 只限制搜索工具，不管 MCP / Apps / 沙箱命令网络。

已弃用、不要新写：

- `features.web_search`
- `features.web_search_cached`
- `features.web_search_request`

### 历史、推理显示、杂项

| 键 | 默认 | 含义 |
|----|------|------|
| `hide_agent_reasoning` | `false` | 隐藏内部推理事件 |
| `show_raw_agent_reasoning` | `false` | 显示原始推理（调试用） |
| `disable_paste_burst` | `false` | 关闭 TUI 爆发粘贴检测；更推荐写在 `[tui]` |
| `windows_wsl_setup_acknowledged` | `false` | Windows 引导是否已确认 |
| `check_for_update_on_startup` | `true` | 启动检查更新。公司统一升级可关 |
| `suppress_unstable_features_warning` | `false` | 关闭「开启了未稳定 feature」警告 |
| `notify` | 未设置 | 外部通知程序 argv，如 `["notify-send", "Codex"]`。项目级会被忽略 |
| `[history].persistence` | `"save-all"` | `"save-all"` 或 `"none"` |
| `[history].max_bytes` | 未设置 | 历史文件上限，超了删最旧 |

```toml
[history]
persistence = "save-all"
# max_bytes = 5242880
```

### TUI

```toml
[tui]
notifications = true
# notifications = ["agent-turn-complete", "approval-requested"]
notification_method = "auto"          # auto | osc9 | bel
notification_condition = "unfocused"  # unfocused | always
animations = true
show_tooltips = true
alternate_screen = "auto"             # auto | always | never（Zellij 建议 auto）
# resume_cwd = "session"              # current | session
# status_line = ["model-with-reasoning", "context-remaining", "current-dir"]
# terminal_title = ["spinner", "project"]
# theme = "catppuccin-mocha"
# raw_output_mode = false
# vim_mode_default = false

[tui.keymap.global]
open_transcript = "ctrl-t"

[tui.keymap.composer]
submit = ["enter", "ctrl-m"]

[tui.keymap.chat]
interrupt_turn = "f12"
```

`status_line` 常见 ID：`model`、`model-with-reasoning`、`context-remaining`、`current-dir`、`git-branch`、`used-tokens`。设 `[]` 可隐藏。快捷键写成 `[]` 表示解绑。

`notify` 跑外部程序；`tui.notifications` 是终端内置通知。两者用途不同。

### Feature flags

```toml
[features]
apps = true                 # ChatGPT Apps / connectors
goals = true
hooks = true
fast_mode = true
memories = false            # 实验性，默认关
multi_agent = true
personality = true
remote_plugin = true
shell_snapshot = true
shell_tool = true
unified_exec = true         # Windows 上默认可能关
```

也可用：

```bash
codex features list
codex features enable unified_exec
codex features disable memories
```

带 `--profile` 时，开关会写进对应 profile 文件。

其它较新 / 实验开关（按需）：

| 开关 | 作用 |
|------|------|
| `features.network_proxy` | 沙箱命令的网络代理与域名策略 |
| `features.prevent_idle_sleep` | 防止空闲休眠 |
| `features.codex_git_commit` | Codex 辅助 git commit |
| `features.rollout_budget.enabled` + `limit_tokens` | 会话 token 预算 |
| `features.code_mode.enabled` | Code mode（开发中，默认关） |
| `features.context_management.experimental_mode` | 实验性上下文管理 |

### MCP Servers

每个服务器一块表：`[mcp_servers.<名字>]`。

STDIO：

```toml
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]
env_vars = ["LOCAL_TOKEN"]
cwd = "/path/to/server"
startup_timeout_sec = 10
tool_timeout_sec = 60
enabled = true
required = false
enabled_tools = ["resolve-library-id", "query-docs"]
disabled_tools = []
default_tools_approval_mode = "prompt"   # auto | prompt | writes | approve

[mcp_servers.context7.env]
MY_ENV_VAR = "MY_ENV_VALUE"
```

HTTP / SSE：

```toml
[mcp_servers.figma]
url = "https://mcp.figma.com/mcp"
bearer_token_env_var = "FIGMA_OAUTH_TOKEN"
http_headers = { "X-Figma-Region" = "us-east-1" }
# auth = "oauth"                  # oauth | chatgpt
```

| 字段 | 含义 |
|------|------|
| `command` / `args` / `cwd` | STDIO 启动方式 |
| `env` / `env_vars` | 注入或转发环境变量 |
| `url` | HTTP MCP 地址 |
| `bearer_token_env_var` | Bearer Token 环境变量名 |
| `http_headers` / `env_http_headers` | 请求头 |
| `enabled` / `required` | 启用；以及是否必须启动成功 |
| `enabled_tools` / `disabled_tools` | 工具白 / 黑名单，黑名单后应用 |
| `default_tools_approval_mode` | 该 server 工具的默认审批 |
| `startup_timeout_sec` / `tool_timeout_sec` | 启动 / 单次工具超时 |

单工具覆盖：

```toml
[mcp_servers.chrome_devtools.tools.open]
approval_mode = "approve"
output_token_limit = 30000
```

TUI 里用 `/mcp` 查看当前 MCP。

### Shell 环境策略

控制 Codex 派生命令能看到哪些环境变量。默认会过滤名字里带 `KEY` / `SECRET` / `TOKEN` 的变量。

```toml
[shell_environment_policy]
inherit = "all"                   # all | core | none
ignore_default_excludes = false
set = {}

[shell_environment_policy.filters]
"PATH" = "include"
"HOME" = "include"
"AWS_*" = "exclude"
"AZURE_*" = "exclude"
```

- `inherit = all`：继承当前环境再过滤
- `core`：只留核心变量
- `none`：几乎空手开始，再靠 `set` / include
- include 出现后变成白名单模式
- 同一层不要把新的 `filters` 和旧的 `exclude` / `include_only` 混用

一次性覆盖：

```bash
codex --config 'shell_environment_policy.include_only=["PATH","HOME"]'
```

### Agents / Skills / Memories

```toml
[agents]
enabled = true
max_concurrent_threads_per_session = 6
default_subagent_model = "gpt-5.6-terra"
default_subagent_reasoning_effort = "high"
interrupt_message = true

[agents.reviewer]
description = "找正确性、安全和测试风险"
config_file = "./agents/reviewer.toml"
```

```toml
[skills]
max_context_tokens = 2000         # 默认约模型窗口的 2%，上限 10000

[[skills.config]]
path = "/path/to/skill"
enabled = false
```

```toml
[features]
memories = true                   # 总开关，EEA/UK/CH 必须显式开

[memories]
generate_memories = true
use_memories = true
disable_on_external_context = true
```

子代理只有你明确要求时才会拉起，token 消耗比单代理高。审查子代理建议用 `gpt-5.6-sol`。

### Hooks

可写在 `~/.codex/hooks.json` 或 config.toml 的 `[hooks]`。项目级 hooks 同样要求项目受信任。

```toml
[[hooks.PreToolUse]]
matcher = "^Bash$"

[[hooks.PreToolUse.hooks]]
type = "command"
command = '/usr/bin/python3 "$(git rev-parse --show-toplevel)/.codex/hooks/pre_tool_use_policy.py"'
timeout = 30
statusMessage = "Checking Bash command"
async = false
```

常见事件：`PreToolUse`、`PostToolUse`、`SessionStart`、`SessionEnd`、`UserPromptSubmit`、`Stop`、`SubagentStart`、`SubagentStop`。

同一层同时有 `hooks.json` 和 `[hooks]` 会两边都加载并警告，选一种即可。

### 项目信任

```toml
[projects."/home/you/work/my-repo"]
trust_level = "trusted"
```

未信任则忽略该仓库的 `.codex/config.toml`、hooks、rules。

### Analytics / Feedback / OTel

```toml
[analytics]
enabled = true

[feedback]
enabled = true
```

`[otel]` 只能写在用户级，用来把请求、工具审批、SSE 事件导出到 OpenTelemetry。公司环境才需要，个人一般别开，且注意 prompt 脱敏。

## Profiles：现在怎么配

Codex 0.134.0 起，不要再写：

```toml
profile = "deep-review"

[profiles.deep-review]
model = "gpt-5.6-sol"
```

正确做法是独立文件。`~/.codex/deep-review.config.toml`：

```toml
model = "gpt-5.6-sol"
model_reasoning_effort = "xhigh"
approval_policy = "on-request"
sandbox_mode = "read-only"
```

启动：

```bash
codex --profile deep-review
codex exec --profile deep-review "review this change"
```

Profile 只写和默认不同的键。名字限字母、数字、连字符、下划线。

建议三套：

| 文件 | 用途 |
|------|------|
| `~/.codex/config.toml` | 日常，默认 `gpt-5.6-terra` |
| `~/.codex/review.config.toml` | `gpt-5.6-sol` + 高推理 + 只读沙箱 |
| `~/.codex/ci.config.toml` | `approval_policy = "never"` + `sandbox_mode = "workspace-write"` 或 `read-only` |

## 命令行一次性覆盖

有专用 flag 就用 flag：

```bash
codex --model gpt-5.6-terra
codex --sandbox workspace-write
codex --ask-for-approval on-request
codex --profile ci
```

任意键用 `--config`，值是 TOML 不是 JSON：

```bash
codex --config model='"gpt-5.6-sol"'
codex --config sandbox_workspace_write.network_access=true
codex --config 'shell_environment_policy.include_only=["PATH","HOME"]'
codex --config mcp_servers.context7.enabled=false
```

## 按场景的完整例子

### A. Code80 日常开发（推荐起点）

就是文首那份：`gpt-5.6-terra` + `model_providers.codex`（`requires_openai_auth = true`、`supports_websockets = false`）+ `workspace-write` + `on-request`。

### B. 审查模式

`~/.codex/review.config.toml`：

```toml
model = "gpt-5.6-sol"
review_model = "gpt-5.6-sol"
model_reasoning_effort = "xhigh"
approval_policy = "on-request"
sandbox_mode = "read-only"
web_search = "cached"
```

```bash
codex --profile review
```

### C. 项目级（仓库内，需信任）

`.codex/config.toml`：

```toml
model_reasoning_effort = "high"
sandbox_mode = "workspace-write"

[features]
hooks = true
```

不要在这里写 `model_provider` / `openai_base_url` / `notify`。

### D. CI

`~/.codex/ci.config.toml`：

```toml
approval_policy = "never"
sandbox_mode = "workspace-write"
web_search = "disabled"
model = "gpt-5.6-terra"
model_reasoning_effort = "medium"
```

```bash
codex exec --profile ci "run tests and fix failures"
```

### E. 高频小任务

```toml
model = "gpt-5.6-luna"
model_reasoning_effort = "low"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
```

## 配置时最容易踩的坑

1. 根键写在 `[table]` 后面 → TOML 解析失败。
2. 把 provider / 凭据写进项目级 `.codex/config.toml` → 被静默忽略并警告。
3. 继续用 `[profiles.xxx]` → 0.134.0+ 已失效，改独立文件。
4. 第三方网关不写 `wire_api = "responses"` → 协议混用直接报错。
5. `web_search` 默认是 `cached` 不是实时。要最新网页写 `"live"`。
6. `workspace-write` 默认不能出网。装依赖要显式 `network_access = true`。
7. `danger-full-access` / `--yolo` 没有沙箱。只在容器 / CI runner 里用。
8. `experimental_instructions_file` 已改名为 `model_instructions_file`。
9. 不必把 sample 里上百个键全抄进去。只写要覆盖的。
10. 模型写成 `gpt-5.6` 或 `gpt-luna` → Code80 找不到模型。必须用 `gpt-5.6-terra` / `gpt-5.6-sol` / `gpt-5.6-luna`。
11. 旧文档里的 `preferred_auth_method`、`disable_response_storage`、顶层 `network_access = "enabled"` 已不在当前 schema 里，删掉。
12. Codex 0.149.0+ 自定义 provider 写 `requires_openai_auth = false` 还依赖 `auth.json` → `API_KEY_REQUIRED` / 401。必须改成 `true`。
13. 每次提问卡在「正在重新连接 1/5 … 5/5」→ 默认先走 WSS，中转转不好 WebSocket。自定义 provider 写 `supports_websockets = false`，不要改内置 `openai`。
14. 全文件出现两个 `model_provider`，或改完只关窗口不退出进程 → 配置看起来改了但不生效。彻底退出（Cmd+Q / 结束进程）后用新对话测。
15. 改桌面端配置后可能要重启应用；CLI 每次启动重读。

## 配置生效

修改 `config.toml` 或 `auth.json` 后，必须彻底退出再打开：macOS 用 Cmd+Q，Windows 结束 Codex 进程，CLI 则退出当前会话再运行 `codex`。只关窗口不够。用**新对话**测试，旧会话可能还绑着原来的鉴权或 WSS 连接。

## 最小记忆版

日常真正高频的只有这几个：

```toml
model = "gpt-5.6-terra"
model_provider = "codex"
model_reasoning_effort = "medium"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
web_search = "cached"

[model_providers.codex]
name = "codex"
base_url = "https://code.ai80.vip"
wire_api = "responses"
requires_openai_auth = true
supports_websockets = false
```

再往上：

- 换模型 / 推理强度：terra 日常、luna 图快、sol 图稳
- 给信任仓库开写、给陌生目录保持只读
- 需要时再加 MCP、自定义 provider、profile
- 用 `AGENTS.md` 管仓库规矩，用 `config.toml` 管客户端行为

最新字段以 [Configuration Reference](https://developers.openai.com/codex/config-reference) 和 [Sample Configuration](https://developers.openai.com/codex/config-sample) 为准。编辑时加上 schema 最省事。
