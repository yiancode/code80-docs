---
description: 使用 xAI 官方 Grok Build 通过 Code80 中转进行安全开发、模型验证和项目规则管理的技巧
---

# 使用技巧

## 从目标仓库启动

在实际项目根目录启动，Grok Build 才能读取 Git 状态、项目规则和相对路径：

```bash
cd /path/to/project
grok
```

也可以显式指定目录：

```bash
grok --cwd /path/to/project
```

## 用 AGENTS.md 固化规则

在仓库根目录创建 `AGENTS.md`，写入构建、测试、目录边界和敏感文件约束。例如：

```markdown
# 项目规则

- 修改前阅读 README.md 和现有测试。
- 完成后运行 pnpm lint 与 pnpm test。
- 不读取、输出或提交 .env、凭据和生产数据。
```

规则应描述可验证的工程约束，而不是把 API Key 或内部密钥写进去。

## 先验证两段链路

中转配置完成后，不要只看 TUI 是否显示了模型名称。分别验证：

1. `GET /v1/models` 是否返回 `200`，确认 Key 有模型目录权限。
2. 最小 `POST /v1/chat/completions` 是否成功，确认目标模型的上游推理服务可用。

完整命令见[Code80 中转配置](./config)。模型列表可用但聊天返回 502/503 时，应按中转上游问题处理，而不是反复进行 xAI 登录。

## 逐步授予权限

默认逐次审批文件修改和命令执行。只有在已审查、可信的仓库中才使用：

```bash
grok --yolo
```

对不熟悉的仓库，先让 Agent 只读分析、列出计划和命令，再逐项确认。不要把 `--yolo` 用于包含生产凭据、未知脚本或不可信代码的目录。

## 一次性任务

适合脚本或快速检查的场景可以使用单轮模式：

```bash
grok --single-turn --prompt "阅读当前 diff，只列出潜在回归风险"
```

在 CI 中注入 `XAI_API_KEY`，不要将 Key 写进工作流文件、命令行参数或构建日志。

## 更新后重新核对

官方更新后检查实际命令来源和版本：

```bash
command -v grok
grok --version
grok --help
```

如果版本、TUI 菜单或模型行为与本文不同，优先相信本机 `--help` 与 `/` 菜单，再对照官方仓库的最新文档。若 `command -v grok` 不是 `~/.grok/bin/grok` 或官方安装位置，先清理同名社区 CLI。
