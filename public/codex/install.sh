#!/usr/bin/env bash
# Code80 Codex CLI 一键安装配置（macOS / Linux）
# 用法：
#   curl -fsSL https://docs.ai80.vip/codex/install.sh | bash
#   curl -fsSL https://docs.ai80.vip/codex/install.sh | CODE80_API_KEY='你的Key' bash
#   或下载后：bash install.sh
#
# 可用环境变量（必须传给 bash，不能写在 curl 前面）：
#   CODE80_API_KEY / OPENAI_API_KEY   跳过交互输入
#   CODEX_MODEL                       默认 gpt-5.6-terra
#   CODEX_HOME                        默认 ~/.codex
#   CODE80_BASE_URL                   默认 https://code.ai80.vip

set -euo pipefail

BASE_URL="${CODE80_BASE_URL:-https://code.ai80.vip}"
MODEL="${CODEX_MODEL:-gpt-5.6-terra}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
DOCS_URL="https://docs.ai80.vip/codex/"

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
ok() { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
err() { printf "${RED}[ERR]${NC} %s\n" "$1" >&2; }

prompt_tty() {
  if [ -r /dev/tty ]; then
    printf "%s" "$1" > /dev/tty
    IFS= read -r "$2" < /dev/tty
  else
    printf "%s" "$1"
    IFS= read -r "$2"
  fi
}

prompt_secret() {
  if [ -r /dev/tty ]; then
    printf "%s" "$1" > /dev/tty
    IFS= read -r -s "$2" < /dev/tty
    printf "\n" > /dev/tty
  else
    printf "%s" "$1"
    IFS= read -r -s "$2"
    printf "\n"
  fi
}

node_major() {
  node -v 2>/dev/null | sed 's/^v//' | cut -d. -f1
}

json_escape_write_auth() {
  local key="$1"
  local dest="$2"
  if command -v node >/dev/null 2>&1; then
    KEY="$key" DEST="$dest" node -e '
      const fs = require("fs");
      const key = process.env.KEY || "";
      if (!key) process.exit(2);
      fs.writeFileSync(process.env.DEST, JSON.stringify({ OPENAI_API_KEY: key }, null, 2) + "\n", { mode: 0o600 });
    '
    return
  fi
  if command -v python3 >/dev/null 2>&1; then
    KEY="$key" DEST="$dest" python3 - <<'PY'
import json, os
key = os.environ.get("KEY", "")
dest = os.environ["DEST"]
if not key:
    raise SystemExit(2)
with open(dest, "w", encoding="utf-8") as f:
    json.dump({"OPENAI_API_KEY": key}, f, indent=2)
    f.write("\n")
os.chmod(dest, 0o600)
PY
    return
  fi
  err "需要 node 或 python3 来安全写入 auth.json"
  exit 1
}

write_config() {
  local dest="$1"
  cat > "$dest" <<EOF
#:schema https://developers.openai.com/codex/config-schema.json

model = "${MODEL}"
model_provider = "codex"
model_reasoning_effort = "medium"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
web_search = "cached"
personality = "pragmatic"
forced_login_method = "api"

[model_providers.codex]
name = "codex"
base_url = "${BASE_URL}"
wire_api = "responses"
requires_openai_auth = true
supports_websockets = false

[sandbox_workspace_write]
network_access = false
writable_roots = []

[features]
memories = false
multi_agent = true
shell_snapshot = true
hooks = true

[history]
persistence = "save-all"

[tui]
notifications = true
animations = true
EOF
}

echo ""
echo "=============================================="
echo "  Code80 · Codex CLI 一键安装配置"
echo "=============================================="
echo ""

OS_NAME=$(uname -s)
case "$OS_NAME" in
  Darwin|Linux) ;;
  *)
    err "当前系统是 ${OS_NAME}。Windows 请用：irm https://docs.ai80.vip/codex/install.ps1 | iex"
    exit 1
    ;;
esac

info "1/6 检查 Node.js 22+"
if ! command -v node >/dev/null 2>&1; then
  if [ "$OS_NAME" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
    warn "未找到 node，使用 Homebrew 安装"
    brew install node
  else
    err "未找到 Node.js。macOS 可先安装 Homebrew 再运行本脚本，或从 https://nodejs.org 安装 22+"
    exit 1
  fi
fi

MAJOR="$(node_major || true)"
if [ -z "${MAJOR}" ] || [ "${MAJOR}" -lt 22 ]; then
  err "Codex CLI 需要 Node.js 22+，当前是 $(node -v 2>/dev/null || echo unknown)"
  if command -v nvm >/dev/null 2>&1; then
    warn "检测到 nvm，可执行：nvm install 22 && nvm use 22"
  fi
  exit 1
fi
ok "Node $(node -v)"

if ! command -v npm >/dev/null 2>&1; then
  err "未找到 npm，请重装 Node.js 22+"
  exit 1
fi

if [ "$OS_NAME" = "Linux" ]; then
  if ! command -v bwrap >/dev/null 2>&1; then
    warn "Linux 需要 bubblewrap 沙箱。尝试安装..."
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update -y && sudo apt-get install -y bubblewrap
    else
      err "请先安装 bubblewrap（Debian/Ubuntu: sudo apt-get install bubblewrap）"
      exit 1
    fi
  fi
  ok "bubblewrap 已就绪"
fi

info "2/6 安装官方 @openai/codex"
if ! npm install -g @openai/codex; then
  err "npm 全局安装失败。常见原因是目录权限。可改用 nvm，或："
  echo "    mkdir -p \"\$HOME/.npm-global\" && npm config set prefix \"\$HOME/.npm-global\""
  echo "    export PATH=\"\$HOME/.npm-global/bin:\$PATH\""
  exit 1
fi
ok "Codex $(codex --version 2>/dev/null || echo 已安装)"

info "3/6 准备 ${CODEX_HOME}"
mkdir -p "${CODEX_HOME}"
chmod 700 "${CODEX_HOME}" 2>/dev/null || true

info "4/6 写入 config.toml（Code80 推荐配置）"
if [ -f "${CODEX_HOME}/config.toml" ]; then
  BACKUP="${CODEX_HOME}/config.toml.bak.$(date +%Y%m%d_%H%M%S)"
  cp "${CODEX_HOME}/config.toml" "${BACKUP}"
  warn "已备份原配置到 ${BACKUP}"
fi
write_config "${CODEX_HOME}/config.toml"
chmod 600 "${CODEX_HOME}/config.toml" 2>/dev/null || true
ok "模型 ${MODEL} · provider=codex · ${BASE_URL}"
ok "requires_openai_auth=true · supports_websockets=false"

info "5/6 配置 API Key（只写入 auth.json，不会打印）"
KEY="${CODE80_API_KEY:-${OPENAI_API_KEY:-}}"
if [ -z "$KEY" ] && [ -f "${CODEX_HOME}/auth.json" ]; then
  KEEP="Y"
  prompt_tty "已存在 auth.json，保留其中的 Key？[Y/n] " KEEP
  case "$KEEP" in
    n|N|no|NO)
      KEY=""
      ;;
    *)
      ok "保留现有 auth.json"
      KEY="__KEEP__"
      ;;
  esac
fi
if [ "$KEY" != "__KEEP__" ]; then
  if [ -z "$KEY" ]; then
    prompt_secret "请输入 Code80 OpenAI 分组 API Key: " KEY
  fi
  if [ -z "$KEY" ]; then
    err "未提供 API Key。可设置 CODE80_API_KEY 后重跑，或稍后编辑 ${CODEX_HOME}/auth.json"
    exit 1
  fi
  json_escape_write_auth "$KEY" "${CODEX_HOME}/auth.json"
  chmod 600 "${CODEX_HOME}/auth.json"
  ok "已写入 auth.json"
fi
unset KEY CODE80_API_KEY OPENAI_API_KEY 2>/dev/null || true

info "6/6 验证命令"
if ! command -v codex >/dev/null 2>&1; then
  warn "当前 shell 找不到 codex。新开一个终端，或检查 npm 全局 bin 是否在 PATH"
else
  ok "$(command -v codex)"
  ok "$(codex --version)"
fi

echo ""
echo "=============================================="
ok "安装配置完成"
echo "=============================================="
echo ""
echo "下一步："
echo "  1. 彻底退出已打开的 Codex（Cmd+Q），不要只关窗口"
echo "  2. 新开终端执行：  cd 你的项目 && codex"
echo "  3. 用新对话测试。日常模型是 ${MODEL}"
echo "     复杂任务 gpt-5.6-sol · 图快 gpt-5.6-luna"
echo "     不要写 gpt-5.6 或 gpt-luna"
echo ""
echo "文档：${DOCS_URL}"
echo ""
