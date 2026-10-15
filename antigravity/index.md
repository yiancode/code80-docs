---
description: Antigravity CLI（agy）快速开始：通过 Code80 调用 Gemini，配置 settings.json 与环境变量
---

# Antigravity CLI

通过 Code80 使用 **Antigravity CLI**（命令名 `agy`）调用 Gemini 模型。

::: danger 不要和下面两样搞混
- 这不是桌面版 **Antigravity IDE**。
- 也不是 npm 包 **`@google/gemini-cli`**（命令名 `gemini`）。Google 官方 Gemini CLI 教程见 [Gemini CLI](/gemini/)。
:::

## 快速开始

按下面顺序做完即可冒烟验证：

1. [安装并验证](./install) `agy --version`
2. [配置](./config) `~/.gemini/antigravity-cli/settings.json` 登记自定义模型 `gemini-4-argon`
3. 在 `~/.zshrc` 写入 Code80 环境变量并 `source`
4. 用 [`agy --print`](./usage) 做一次非交互冒烟
5. 再进入交互式 `agy` 发短对话

### 1. 确认已安装

```bash
agy --version
```

![agy --version](/antigravity/01-agy-version.png)

### 2. 登记自定义模型

`agy` **只认识**内置显示名，或你在 `settings.json` 里登记过的自定义模型。直接写 `--model gemini-4-argon` 而不登记，会报 `model is not recognized`。

在 `~/.gemini/antigravity-cli/settings.json` 中至少要有：

- `"modelProvider": "gemini"`
- `"model": "gemini-4-argon"`
- `customModelsConfig.customModels` 里一项键名 `gemini-4-argon`，`apiProvider` 为 `API_PROVIDER_GOOGLE_GEMINI`，`modelName` 为 `gemini-4-argon`

完整字段与示例见 [配置详解](./config)。

### 3. 配置环境变量

在 `~/.zshrc`（或你实际用的 shell 配置）加入：

```bash
export GOOGLE_GEMINI_BASE_URL="https://code.ai80.vip"
export GEMINI_API_KEY="sk-你的Key"
export GEMINI_MODEL="gemini-4-argon"
```

然后执行 `source ~/.zshrc`，或新开一个终端窗口。

::: tip 地址必须是站点根
`GOOGLE_GEMINI_BASE_URL` 只能是 `https://code.ai80.vip`，**不要**带 `/v1`、`/v1beta`、`/gemini`、`/antigravity`。`agy` 会自己在后面拼 `/v1beta`。
:::

::: warning agy 读什么、不读什么
- 使用环境变量 **`GEMINI_API_KEY`**，不认 `GOOGLE_API_KEY`。
- **不读** `~/.gemini/.env`（那是官方 Gemini CLI 的配置方式）。
:::

### 4. 非交互冒烟

```bash
agy --print "Reply with the single word pong." --model gemini-4-argon --print-timeout 60s
```

成功时应回复 `pong`。若返回 `400` 且原文含 `API key group platform is not gemini`，说明这把 Key 所在分组默认不能打 `/v1beta`，处理方式见 [调用与交互](./usage)。

## 适用场景

- 在终端用 `agy` 走 Code80 的 Gemini 原生接口
- 需要自定义模型名（如 `gemini-4-argon`）并在 `/model` 列表里可选
- 与官方 `@google/gemini-cli` 分开使用、互不覆盖配置

## 下一步

- [安装与验证](./install)
- [配置详解](./config)
- [调用与交互](./usage)
- [常见问题](./faq)
