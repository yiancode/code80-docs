---
description: Grok CLI 快捷键与命令速查，涵盖交互按键、slash commands、无头模式和会话恢复
---

# Grok CLI 快捷键

Grok CLI 同时支持全屏交互、slash commands 和命令行参数。日常使用时，先记住发送、中断、切换模式和恢复会话这几类操作即可。

## 常用快捷键

| 场景 | 快捷键 / 操作 | 说明 |
|------|---------------|------|
| 发送消息 | `Enter` | 提交当前输入 |
| 多行输入 | `Shift+Enter` | 在当前输入中换行 |
| 中断任务 / 关闭浮层 | `Esc` | 任务运行时中断；菜单或浮层打开时返回 |
| 清空输入 | `Ctrl+C` | 输入框非空时清除当前输入 |
| 退出会话 | 空输入时按 `Ctrl+C` | 输入框为空时退出 Grok CLI |
| 切换执行模式 | `Tab` | 空闲状态下在可用模式间切换 |
| 输入框 / 菜单导航 | 上 / 下箭头 | 输入框内移动光标；菜单或浮层中移动选项 |
| 打开命令列表 | 输入 `/` | 查看当前版本和上下文支持的 slash commands |

::: tip `Ctrl+C` 与 `Esc` 的区别
`Esc` 更适合中断正在运行的任务；`Ctrl+C` 会根据输入框是否为空执行“清空输入”或“退出”。
:::

## 常用 Slash 入口

输入 `/` 会打开命令菜单。下表有些入口可直接输入，有些由菜单执行；最稳妥的方式是输入 `/`，筛选后按 `Enter` 选择。

| 命令 | 作用 |
|------|------|
| `/help`（菜单） | 查看帮助和可用命令 |
| `new session`（菜单） | 清空当前上下文并开始新会话 |
| `/models` | 选择模型；菜单也可搜索 `/model` 或 `/mode` |
| `/agents` | 查看和使用子代理 |
| `/mcp` | 管理 MCP 服务 |
| `/skills`（菜单） | 查看可用 Skills |
| `/review` | 审查当前代码变更 |
| `/verify` | 运行内置验证流程；仅支持 Shuru 的平台可用 |
| `/commit-push` | 提交并推送当前变更 |
| `/commit-pr` | 提交变更并创建 Pull Request |
| `/recaps` | 查看会话回顾 |
| `/schedule` | 管理计划任务 |
| `/sandbox` | 查看或切换 Shuru 沙箱 |
| `/remote-control` | 管理远程控制能力 |
| `/update`（菜单） | 检查或安装更新；仅脚本安装 |
| `/exit` | 退出 Grok CLI |

不同版本、平台或项目上下文中显示的命令可能略有差异，以 `/help` 的实际输出为准。执行提交、推送和创建 PR 前，应先检查变更内容和目标分支。

## 高频入口命令

| 目的 | 命令 |
|------|------|
| 交互启动 | `grok` |
| 指定工作目录 | `grok -d your-project` |
| 指定模型 | `grok -m grok-4.3` |
| 一次性无头任务 | `grok -p "解释这个项目的入口"` |
| 逐行 JSON 事件流 | `grok -p "总结改动" --format json` |
| 恢复最近会话 | `grok --session latest` |
| 恢复指定会话 | `grok -s <session-id>` |
| 查看本地模型目录 | `grok models` |
| 更新 CLI | `grok update`（仅脚本安装） |

<figure>
  <img src="/grok/grok-models-terminal.svg" alt="Grok CLI 1.1.7 本地模型目录和 grok-code-fast-1 别名" loading="lazy" />
  <figcaption>本机 Grok CLI 1.1.7 的模型目录示例；别名存在于本地目录，不等于中转站一定开放该模型。</figcaption>
</figure>

## 自动化注意事项

无头模式适合脚本和 CI：

```bash
grok -m grok-4.3 -p "检查当前改动并只输出风险清单" --format json
```

`--format json` 输出的是 NDJSON 事件流，而不是单个 JSON 对象。脚本应逐行解析，并根据事件类型提取最终结果或错误。

Code80 当前没有提供 Grok CLI `--batch-api` 所需的 `/batches` 端点。需要自动化时请使用普通的 `-p` 无头模式，不要启用 `--batch-api`。

## 相关阅读

- [配置详解](./config)
- [使用技巧](./tips)
- [常见问题](./faq)
