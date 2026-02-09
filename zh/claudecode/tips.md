# Claude Code 使用技巧

## 基础操作

### 启动和退出

```bash
# 在项目目录下启动
cd your-project
claude

# 退出（在 Claude Code 内输入）
/exit
```

### 常用命令

| 命令 | 说明 |
|------|------|
| `/help` | 查看帮助信息 |
| `/clear` | 清除当前对话 |
| `/exit` | 退出 Claude Code |
| `/compact` | 压缩对话历史，节省上下文 |

## 高效使用

### 项目初始化

在项目根目录创建 `CLAUDE.md` 文件，写入项目说明和编码规范，Claude Code 会自动读取作为上下文：

```markdown
# 项目说明
这是一个使用 React + TypeScript 的前端项目。

## 编码规范
- 使用函数式组件
- 使用 TypeScript strict 模式
- 组件文件使用 PascalCase 命名
```

### 善用上下文

- 在项目目录下启动，Claude Code 会自动了解项目结构
- 提问时提供具体的文件路径和行号
- 使用 `@文件名` 引用特定文件

### 大型项目建议

- 使用 `/compact` 定期压缩对话，避免上下文溢出
- 分拆复杂任务为多个小步骤
- 让 Claude Code 先分析再实现，避免一次性生成大量代码

## IDE 集成

Claude Code 支持与主流 IDE 集成：

### VS Code

安装 Claude Code 扩展后，可以直接在编辑器内使用。

### JetBrains

通过终端面板直接使用 Claude Code。

## 性能优化

- **减少不必要的上下文**：保持对话聚焦，定期清理历史
- **精确描述需求**：提供具体的需求描述，减少反复沟通
- **利用文件引用**：直接指定文件而非让 Claude Code 搜索
