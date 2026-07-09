---
description: Grok CLI 使用技巧，涵盖项目上下文、AGENTS.md、无头调用、会话恢复、子代理、搜索和安全验证
---

# Grok CLI 使用技巧

## 从项目目录启动

在真正要处理的仓库中启动，Grok CLI 才能获得正确的文件和 Git 上下文：

```bash
cd your-project
grok -m grok-4.3
```

也可以从其他目录显式指定工作区：

```bash
grok -d /path/to/your-project -m grok-4.3
```

## 用 AGENTS.md 固化项目规则

Grok CLI 会读取项目中的 `AGENTS.md`。可以把构建命令、目录边界、编码规范和验证要求写进去，让每次会话都遵循同一套约定。

```markdown
# AGENTS.md

## 项目约定
- 修改前先阅读 README.md
- 业务逻辑放在 src/services
- 完成后运行 pnpm lint 和 pnpm test
- 不要提交 .env 或任何 API Key
```

需要对某个子目录覆盖规则时，可以在更近的目录使用 `AGENTS.override.md`。规则越具体，越应该靠近对应代码。

## 一次性任务使用无头模式

不需要持续对话时，用 `-p` 更适合脚本、CI 和批量检查：

```bash
grok -m grok-4.3 -p "阅读当前 diff，列出可能的回归风险"
```

需要机器读取结果时增加逐行 JSON 输出：

```bash
grok -m grok-4.3 -p "总结当前仓库结构" --format json
```

`--format json` 返回 NDJSON 事件流，自动化程序应逐行解析，同时检查进程退出状态和错误事件，不要把完整输出当成单个 JSON 对象。

## 恢复已有会话

继续最近一次任务：

```bash
grok --session latest
```

知道会话 ID 时：

```bash
grok -s <session-id>
```

长任务优先恢复原会话，可以保留之前的分析和决策；目标已经改变时，输入 `/` 打开菜单，再选择 `new session` 开始干净上下文。

## 善用子代理、搜索和 Skills

- `/agents`：把调研、测试或代码审查拆给不同子代理
- Web / X 搜索：查阅新版本文档、Issue 和实时资料
- `/skills`：复用已安装的工作流和领域能力
- `/mcp`：连接外部工具或数据源

多代理适合相互独立的任务。会同时修改同一个文件的工作应保持单一负责人，避免覆盖彼此的改动。

## 先用稳定模型打通链路

首次接入 Code80 时建议显式使用：

```bash
grok -m grok-4.3 -p "只回复 OK"
```

确认密钥、Base URL 和模型都能正常调用后，再尝试其他模型。`grok models` 显示的是 CLI 内置目录，某个模型是否可用仍取决于当前 Code80 API Key 的分组权限。

## 修改后主动验证

在 macOS 14+ Apple Silicon 上，可以使用 `/verify` 或 `--verify` 运行内置验证流程。该流程强制依赖 Shuru 沙箱，不会自动降级到主机模式。

Linux、Windows 和 Intel Mac 不要使用内置 verify；请在普通会话中明确要求 Grok CLI 以主机模式运行仓库自己的 lint、类型检查和测试。提交前仍应阅读 diff，确认没有意外修改或敏感信息，并通过 Git、容器或最小权限账号控制风险。

## 了解 Code80 接入边界

- 普通对话和代码任务优先使用 `grok-4.3`，链路最简单
- Responses、Web / X 搜索是否可用，取决于当前 Grok 上游账号与分组能力
- 图片、视频等媒体能力还需要对应模型和媒体权限
- `--batch-api` 依赖 `/batches`，Code80 当前未提供该端点
- Telegram 语音依赖 Grok CLI 的 `/stt` 端点，Code80 当前未提供该端点

遇到扩展能力报错时，先用普通 `grok-4.3` 文本请求区分“基础配置问题”和“特定能力不支持”。

## 保持版本一致

定期检查版本：

```bash
grok --version
grok update
```

`grok update` 只适用于官方脚本安装。通过 Bun 安装时，请使用 Bun 管理和更新 `grok-dev` 包。

如果终端界面、模型名或命令与教程明显不同，先运行 `type -a grok`，确认没有命中旧的同名程序。

## 与其他工具对比

查看 [工具功能对比](/guide/comparison)，了解 Grok CLI 与 Claude Code、Codex CLI、Gemini CLI 的差异。
