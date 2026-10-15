---
description: Antigravity CLI 配置详解：settings.json 自定义模型与 zshrc 环境变量
---

# Antigravity CLI 配置详解

配置分两块：**settings.json**（模型登记）和 **shell 环境变量**（Base URL / API Key）。缺一不可。

## settings.json

### 路径

| 系统 | 路径 |
|------|------|
| macOS / Linux | `~/.gemini/antigravity-cli/settings.json` |
| Windows | `%USERPROFILE%\.gemini\antigravity-cli\settings.json` |

### 必填字段

通过 Code80 使用 `gemini-4-argon` 时，至少保证：

| 字段 | 值 |
|------|-----|
| `modelProvider` | `"gemini"` |
| `model` | `"gemini-4-argon"` |
| `customModelsConfig.customModels.gemini-4-argon.apiProvider` | `"API_PROVIDER_GOOGLE_GEMINI"` |
| `customModelsConfig.customModels.gemini-4-argon.modelName` | `"gemini-4-argon"` |

::: tip 保留已有权限与主题
只**补上**上述字段，不要删掉文件里已有的权限、主题等设置。
:::

### 示例（合并进现有文件）

下面是需要关注的片段；实际文件里通常还有 `permissions`、`theme` 等，请保留：

```json
{
  "modelProvider": "gemini",
  "model": "gemini-4-argon",
  "customModelsConfig": {
    "customModels": {
      "gemini-4-argon": {
        "apiProvider": "API_PROVIDER_GOOGLE_GEMINI",
        "modelName": "gemini-4-argon"
      }
    }
  }
}
```

配置截图示例：

![settings.json](/antigravity/02-settings-json.png)

::: warning 模型必须登记
`agy` 只接受内置显示名，或在 `customModels` 里登记过的名字。未登记就执行 `--model gemini-4-argon`，会报 `model is not recognized`。
:::

## 环境变量（~/.zshrc）

`agy` 从当前 shell 环境读变量，**不读** `~/.gemini/.env`。

在 `~/.zshrc`（bash 用户用 `~/.bashrc` / `~/.bash_profile`）加入：

```bash
export GOOGLE_GEMINI_BASE_URL="https://code.ai80.vip"
export GEMINI_API_KEY="sk-你的Key"
export GEMINI_MODEL="gemini-4-argon"
```

改完后执行：

```bash
source ~/.zshrc
```

或新开一个终端。只截 Gemini 相关三行、Key 打码的示例：

![zshrc Gemini env](/antigravity/03-zshrc-env.png)

### 字段说明

| 变量 | 说明 |
|------|------|
| `GOOGLE_GEMINI_BASE_URL` | Code80 站点**根地址**，不要带路径后缀 |
| `GEMINI_API_KEY` | Code80 API Key（`agy` 认这个名字，不认 `GOOGLE_API_KEY`） |
| `GEMINI_MODEL` | 默认模型名，需与 settings 中登记的一致 |

### Base URL 对错对照

| 写法 | 结果 |
|------|------|
| `https://code.ai80.vip` | 正确；`agy` 会自己拼 `/v1beta` |
| `https://code.ai80.vip/v1` | 错误 |
| `https://code.ai80.vip/v1beta` | 错误 |
| `https://code.ai80.vip/gemini` | 错误 |
| `https://code.ai80.vip/antigravity` | 错误 |
| `https://code.ai80.net/gemini` | 错误（域名与路径都不对） |

## 配置生效

- 改 `settings.json` 后，重新启动 `agy`（退出当前会话再进）
- 改 `~/.zshrc` 后必须 `source` 或新开终端，否则旧环境仍在用

## 下一步

配置完成后去做 [调用与交互](./usage) 冒烟测试。
