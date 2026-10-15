---
description: Antigravity CLI 调用与交互：agy --print 冒烟、交互会话、/v1beta 分组开关与计费核对
---

# Antigravity CLI 调用与交互

先保证 [配置详解](./config) 已完成，且当前终端能 `echo $GOOGLE_GEMINI_BASE_URL` 看到站点根地址。

## 非交互冒烟（推荐先做）

```bash
agy --print "Reply with the single word pong." --model gemini-4-argon --print-timeout 60s
```

成功时应回复单个词 `pong`。

### 预期失败：分组未开 /v1beta

若返回 **400**，原文类似：

```text
Error 400, Message: API key group platform is not gemini, Status: INVALID_ARGUMENT
```

这**不是** Base URL 配错。常见原因是：这把 Key 属于「全部平台」类分组（例如「御三家顶级模型200刀包月」），默认不能打 Gemini 原生 `/v1beta`。

截图示例（冒烟命令 + 上述 400）：

![agy --print 400](/antigravity/04-agy-print-pong.png)

#### 怎么开

1. 打开 Code80 管理后台，编辑该 API Key 所在的**分组**
2. 在 OpenAI Messages 调度相关配置附近，找到 **「Gemini 原生接口」**
3. 打开 **「允许 /v1beta」** 并保存
4. **不要**把「分组平台」改成仅 Gemini——否则同一把 Key 可能无法再调 Claude / GPT
5. **不要**把 `GOOGLE_GEMINI_BASE_URL` 改成带 `/antigravity` 的地址
6. 保存后重新执行上面的 `agy --print …`

::: info 截图待补
分组开关关闭 / 打开对照图 `08-group-switch-off.png`、`09-group-switch-on.png` 待补。不同后台版本若暂时看不到「允许 /v1beta」控件，需在已提供该开关的环境开启后再重试。
:::

## 交互式会话

冒烟成功后：

```bash
agy
```

建议核对三点：

1. 标题栏应显示 **Gemini API key** 相关标识，而不是 Google 账号邮箱
2. 输入 `/model`，列表里应能看到已登记的 `gemini-4-argon`
3. 发一句很短的中文（例如「用一句话介绍你自己」），确认能正常回复

交互过程中不要触发改文件、跑命令等需要授权的操作，避免截图教程被权限弹窗打断。

::: info 截图待补
- `05-agy-header.png`（标题栏）
- `06-agy-model-picker.png`（`/model` 列表）
- `07-agy-chat.png`（短中文问答）
:::

## 用量与价格（核对用）

开通 `/v1beta` 并成功调用后，可在用户控制台查看该 Key 的用量：应能看到模型 `gemini-4-argon`，且费用不为 `$0`。

`gemini-4-argon` 官方价参考（每百万 token）：

| 项目 | 价格 |
|------|------|
| 输入 | $4 |
| 缓存输入 | $0.20 |
| 输出（含 thinking） | $20 |

若模型广场已列出该模型，可对照价格行；广场没有这一行时不要编造。

::: info 截图待补
- `10-usage-billed.png`（控制台用量）
- `11-plaza.png`（模型广场价格行，若有）
:::

## 下一步

遇到报错时看 [常见问题](./faq)。
