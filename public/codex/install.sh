#!/usr/bin/env bash
# Code80 Codex CLI 一键安装配置（macOS / Linux）
# 用法：
#   curl -fsSL https://docs.ai80.vip/codex/install.sh | bash
#   curl -fsSL https://docs.ai80.vip/codex/install.sh | CODE80_API_KEY='你的Key' bash
#   或下载后：bash install.sh
#
# 可用环境变量（必须传给 bash，不能写在 curl 前面）：
#   CODE80_API_KEY / OPENAI_API_KEY   跳过交互输入
#   CODEX_MODEL                       默认 gpt-5.6-terra（覆盖模式才改模型）
#   CODEX_HOME                        默认 ~/.codex
#   CODE80_BASE_URL                   默认 https://code.ai80.vip
#   CODEX_CONFIG_MODE                 keep | replace | abort
#                                     keep=保留 oh-my-codex 等现有配置，只接入 Code80
#                                     replace=用推荐模板覆盖（会先备份）

set -euo pipefail

BASE_URL="${CODE80_BASE_URL:-https://code.ai80.vip}"
MODEL="${CODEX_MODEL:-gpt-5.6-terra}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
DOCS_URL="https://docs.ai80.vip/codex/"
RESTORE_CMD="curl -fsSL https://docs.ai80.vip/codex/restore.sh | bash"

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

node_major() {
  node -v 2>/dev/null | sed 's/^v//' | cut -d. -f1
}

json_escape_write_auth() {
  local key="$1"
  local dest="$2"
  KEY="$key" DEST="$dest" node -e '
    const fs = require("fs");
    const key = process.env.KEY || "";
    if (!key) process.exit(2);
    fs.writeFileSync(process.env.DEST, JSON.stringify({ OPENAI_API_KEY: key }, null, 2) + "\n", { mode: 0o600 });
  '
}

write_replace_config() {
  local dest="$1"
  cat > "$dest" <<EOF
#:schema https://developers.openai.com/codex/config-schema.json

model = "${MODEL}"
model_provider = "codex"
model_reasoning_effort = "medium"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
web_search = "live"
personality = "pragmatic"
forced_login_method = "api"

[model_providers.codex]
name = "codex"
base_url = "${BASE_URL}"
wire_api = "responses"
requires_openai_auth = true
supports_websockets = false

[sandbox_workspace_write]
network_access = true
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

apply_keep_config() {
  local dest="$1"
  DEST="$dest" BASE_URL="$BASE_URL" node - <<'JS'
const fs = require("fs");
const dest = process.env.DEST;
const baseUrl = process.env.BASE_URL;
let text = fs.readFileSync(dest, "utf8");
if (!text.endsWith("\n")) text += "\n";

function esc(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function firstTableIndex(s) {
  const m = s.match(/^\[/m);
  return m ? m.index : s.length;
}

function upsertRootKey(s, key, valueLine) {
  const split = firstTableIndex(s);
  let head = s.slice(0, split);
  const tail = s.slice(split);
  const re = new RegExp("^(\\s*#\\s*)?" + esc(key) + "\\s*=.*$", "m");
  if (re.test(head)) {
    head = head.replace(re, valueLine);
  } else {
    if (head && !head.endsWith("\n")) head += "\n";
    head += valueLine + "\n";
  }
  return head + tail;
}

function upsertTable(s, name, body) {
  const re = new RegExp("^\\[" + esc(name) + "\\][^\\n]*\\n(?:^(?!\\[).*(?:\\n|$))*", "m");
  const block = "[" + name + "]\n" + body + (body.endsWith("\n") ? "" : "\n");
  if (re.test(s)) return s.replace(re, block);
  if (!s.endsWith("\n")) s += "\n";
  return s + "\n" + block;
}

function commentTable(s, name) {
  const re = new RegExp("^\\[" + esc(name) + "\\][^\\n]*\\n(?:^(?!\\[).*(?:\\n|$))*", "m");
  return s.replace(re, (m) =>
    m.split("\n").map((l) => (l && !l.startsWith("#") ? "# " + l : l)).join("\n")
  );
}

function upsertTableKey(s, name, key, valueLine) {
  const tableRe = new RegExp("^\\[" + esc(name) + "\\][^\\n]*\\n(?:^(?!\\[).*(?:\\n|$))*", "m");
  const m = s.match(tableRe);
  if (!m) {
    if (!s.endsWith("\n")) s += "\n";
    return s + "\n[" + name + "]\n" + valueLine + "\n";
  }
  let block = m[0];
  const keyRe = new RegExp("^(\\s*#\\s*)?" + esc(key) + "\\s*=.*$", "m");
  if (keyRe.test(block)) block = block.replace(keyRe, valueLine);
  else {
    const lines = block.split("\n");
    lines.splice(1, 0, valueLine);
    block = lines.join("\n");
  }
  return s.replace(tableRe, block);
}
text = upsertRootKey(text, "model_provider", 'model_provider = "codex"');
text = upsertRootKey(text, "forced_login_method", 'forced_login_method = "api"');
text = upsertRootKey(text, "web_search", 'web_search = "live"');
text = upsertTableKey(text, "sandbox_workspace_write", "network_access", "network_access = true");
text = commentTable(text, "model_providers.Custom");
text = upsertTable(
  text,
  "model_providers.codex",
  [
    'name = "codex"',
    'base_url = "' + baseUrl + '"',
    'wire_api = "responses"',
    "requires_openai_auth = true",
    "supports_websockets = false",
    "",
  ].join("\n")
);
fs.writeFileSync(dest, text);
JS
}

echo ""
echo "=============================================="
echo "  Code80 · Codex CLI 一键安装配置"
echo "=============================================="
echo ""
warn "本脚本会改 ~/.codex/config.toml 以接入 Code80。"
warn "已有配置会先备份。覆盖模式会丢掉 oh-my-codex / MCP / hooks 等自定义内容。"
warn "装完若要改回 OpenAI 官方： ${RESTORE_CMD}"
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

info "4/6 处理 config.toml"
CONFIG_MODE="${CODEX_CONFIG_MODE:-}"
HAS_CONFIG=0
HAS_OMX=0
if [ -f "${CODEX_HOME}/config.toml" ]; then
  HAS_CONFIG=1
  if grep -qi 'oh-my-codex' "${CODEX_HOME}/config.toml" 2>/dev/null; then
    HAS_OMX=1
    warn "检测到 oh-my-codex。"
  else
    warn "检测到已有 ~/.codex/config.toml。"
  fi
  echo "  1) 接入 Code80，保留现有配置（oh-my-codex / MCP / hooks 等）  [推荐有自定义配置时选]"
  echo "  2) 用 Code80 推荐模板覆盖（会先备份，可用恢复脚本还原）"
  echo "  3) 取消"
  if [ -z "$CONFIG_MODE" ]; then
    if [ -r /dev/tty ]; then
      DEFAULT_CHOICE="1"
      prompt_tty "请选择 [1/2/3]（默认 ${DEFAULT_CHOICE}）: " CHOICE
      CHOICE="${CHOICE:-$DEFAULT_CHOICE}"
    else
      CHOICE="1"
      warn "无交互终端，默认 1：保留现有配置，只改 Code80 接入。"
    fi
    case "$CHOICE" in
      1) CONFIG_MODE="keep" ;;
      2) CONFIG_MODE="replace" ;;
      3|q|Q|n|N) CONFIG_MODE="abort" ;;
      *)
        err "无效选择"
        exit 1
        ;;
    esac
  fi
else
  CONFIG_MODE="replace"
fi

case "$CONFIG_MODE" in
  abort)
    warn "已取消。未改 config.toml。"
    exit 0
    ;;
  keep|replace) ;;
  *)
    err "CODEX_CONFIG_MODE 只能是 keep / replace / abort"
    exit 1
    ;;
esac

if [ "$HAS_CONFIG" -eq 1 ]; then
  BACKUP="${CODEX_HOME}/config.toml.bak.$(date +%Y%m%d_%H%M%S)"
  cp "${CODEX_HOME}/config.toml" "${BACKUP}"
  printf '%s\n' "$BACKUP" > "${CODEX_HOME}/.code80-last-backup"
  warn "已备份原配置到 ${BACKUP}"
fi

if [ "$CONFIG_MODE" = "keep" ] && [ "$HAS_CONFIG" -eq 1 ]; then
  apply_keep_config "${CODEX_HOME}/config.toml"
  ok "已保留现有配置，并接入 Code80 provider"
else
  write_replace_config "${CODEX_HOME}/config.toml"
  ok "已写入 Code80 推荐模板"
fi
chmod 600 "${CODEX_HOME}/config.toml" 2>/dev/null || true
ok "provider=codex · ${BASE_URL} · requires_openai_auth=true · supports_websockets=false · web_search=live · network_access=true"

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
    if [ -r /dev/tty ]; then
      printf "请粘贴或输入 Key，屏幕上会显示，核对后再回车。\n" > /dev/tty
    else
      printf "请粘贴或输入 Key，屏幕上会显示，核对后再回车。\n"
    fi
    prompt_tty "请输入 Code80 OpenAI 分组 API Key: " KEY
    KEY="${KEY#"${KEY%%[![:space:]]*}"}"
    KEY="${KEY%"${KEY##*[![:space:]]}"}"
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
echo "  3. 模板已打开 web_search=live 和 network_access=true"
echo "  4. 用新对话测试"
echo ""
echo "改回 OpenAI 官方配置："
echo "  ${RESTORE_CMD}"
echo ""
echo "文档：${DOCS_URL}"
echo ""
