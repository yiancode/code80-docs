# Codex CLI 常见问题

## 安装问题

### Node.js 版本需要 22+，比其他工具要求更高

Codex CLI 确实需要更高的 Node.js 版本。建议使用 nvm 管理多个版本：

```bash
nvm install 22
nvm use 22
```

### Linux 上报 bubblewrap 错误

安装 bubblewrap 沙箱工具：

```bash
sudo apt-get install bubblewrap
```

## 配置问题

### 配置后连接失败

检查以下几点：
1. `base_url` 末尾是否有 `/v1`（Codex CLI 需要）
2. API Key 是否正确
3. API Key 对应的分组是否是 OpenAI 平台

### config.toml 格式报错

TOML 格式比较严格，注意：
- 字符串值要用双引号
- `[section]` 标记要独占一行
- 布尔值用 `true` / `false`

## 使用问题

### 运行时报权限错误

确认 `network_access` 设置为 `"enabled"`。

### 如何查看当前使用的模型？

查看 `~/.codex/config.toml` 中的 `model` 字段。

## 错误码对照

| 错误码 | 说明 | 解决方法 |
|--------|------|----------|
| 401 | 认证失败 | 检查 auth.json 中的 API Key |
| 403 | 无权限 | 确认分组权限 |
| 429 | 请求过多 | 等待后重试 |
| 500 | 服务器错误 | 稍后重试 |
