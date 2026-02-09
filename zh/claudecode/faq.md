# Claude Code 常见问题

## 安装问题

### 安装时提示 Node.js 版本过低

Claude Code 需要 Node.js 18+。请升级 Node.js：

```bash
# 使用 nvm 升级
nvm install 18
nvm use 18
```

### npm install 报权限错误

- **macOS/Linux**：使用 `sudo npm install -g @anthropic-ai/claude-code`
- **Windows**：以管理员身份运行终端

## 配置问题

### 配置后启动报 401 错误

检查以下几点：
1. API Key 是否正确复制（完整的 `sk-` 开头字符串）
2. API Base URL 是否正确（不要加 `/v1` 后缀）
3. API Key 对应的分组是否是 Anthropic 平台
4. API Key 是否已过期或被禁用

### 配置文件在哪里？

| 平台 | 路径 |
|------|------|
| macOS/Linux | `~/.claude/settings.json` |
| Windows | `%USERPROFILE%\.claude\settings.json` |

如果文件不存在，手动创建即可。

## 使用问题

### 响应速度慢

- 检查网络连接是否正常
- 确认 Code80 服务是否正常运行
- 考虑使用代理优化网络

### 上下文过长导致报错

使用 `/compact` 命令压缩对话历史，释放上下文空间。

### 如何切换模型？

在 Code80 平台中，Claude Code 默认使用分组内配置的模型。如需切换，请联系管理员调整分组的模型配置。

## 错误码对照

| 错误码 | 说明 | 解决方法 |
|--------|------|----------|
| 401 | 认证失败 | 检查 API Key 配置 |
| 403 | 无权限 | 确认 API Key 分组权限 |
| 429 | 请求过多 | 等待后重试，或联系管理员提升配额 |
| 500 | 服务器错误 | 稍后重试，如持续出现请联系管理员 |
| 503 | 服务不可用 | 上游服务暂时不可用，请稍后重试 |
