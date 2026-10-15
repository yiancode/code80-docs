---
description: Antigravity CLI 常见问题：模型未登记、Base URL 错误、.env 无效、400 platform not gemini
---

# Antigravity CLI 常见问题

## 模型相关

### `model is not recognized`

`agy` 只接受：

1. 内置显示名，或
2. 已在 `~/.gemini/antigravity-cli/settings.json` 的 `customModelsConfig.customModels` 里登记过的名字

直接 `--model gemini-4-argon` 却未登记会失败。按 [配置详解](./config) 补上 `apiProvider` / `modelName` 后重启 `agy`。

### `/model` 列表里没有 gemini-4-argon

检查 settings 里是否已有键名 `gemini-4-argon` 的自定义项，且 `modelProvider` 为 `gemini`。改完后退出再进交互会话。

## 环境变量与地址

### Base URL 怎么写？

只能写站点根：

```bash
# 正确
export GOOGLE_GEMINI_BASE_URL="https://code.ai80.vip"

# 错误
export GOOGLE_GEMINI_BASE_URL="https://code.ai80.vip/v1"
export GOOGLE_GEMINI_BASE_URL="https://code.ai80.vip/v1beta"
export GOOGLE_GEMINI_BASE_URL="https://code.ai80.vip/gemini"
export GOOGLE_GEMINI_BASE_URL="https://code.ai80.vip/antigravity"
```

`agy` 会自己拼 `/v1beta`。

### 写了 ~/.gemini/.env 为什么不生效？

`agy` **不读** `~/.gemini/.env`（那是官方 Gemini CLI / `gemini` 命令的配置方式）。请把变量写进 `~/.zshrc`（或等价 shell 配置）并 `source`。

### 用了 GOOGLE_API_KEY 仍然鉴权失败？

请改用 **`GEMINI_API_KEY`**。`agy` 不认 `GOOGLE_API_KEY`。

## 400：API key group platform is not gemini

完整信息通常类似：

```text
Error 400, Message: API key group platform is not gemini, Status: INVALID_ARGUMENT
```

含义：当前 Key 所在分组的平台不是「仅 Gemini」，且未开启 Gemini 原生 `/v1beta`。

处理：

1. 后台编辑该分组，打开 **「Gemini 原生接口」→「允许 /v1beta」**
2. **不要**把分组平台改成仅 Gemini——若你还要用同一把 Key 调 Claude / GPT，改成仅 Gemini 会踩坑
3. 保存后重试 `agy --print …`

详见 [调用与交互](./usage)。

## 和其他工具混淆

| 现象 | 原因 | 做法 |
|------|------|------|
| 装了 `@google/gemini-cli` 却找不到 `agy` | 那是另一套 CLI | 按 Antigravity CLI 官方方式安装 `agy` |
| 打开了 Antigravity 桌面 IDE | 不是本教程目标 | 使用终端里的 `agy` |
| 改了 `~/.gemini/settings.json` 无效果 | Antigravity 读的是 `antigravity-cli/settings.json` | 改对路径 |

## 错误码速查

| 现象 / 码 | 说明 | 处理 |
|-----------|------|------|
| `model is not recognized` | 模型未登记 | 补 `customModels` |
| 400 `platform is not gemini` | 分组未开 `/v1beta` | 开「允许 /v1beta」，勿改成仅 Gemini |
| 401 | 鉴权失败 | 检查 `GEMINI_API_KEY`、是否 `source` 过 |
| 连接失败 / 404 | Base URL 带了错误路径 | 改回站点根 |

## 相关文档

- [概述与快速开始](./)
- [配置详解](./config)
- [调用与交互](./usage)
- 官方 Gemini CLI（另一套工具）：[Gemini CLI](/gemini/)
