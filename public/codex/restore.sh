#!/usr/bin/env bash
# 从 Code80 中转改回 OpenAI 官方配置（macOS / Linux）
# 用法：
#   curl -fsSL https://docs.ai80.vip/codex/restore.sh | bash
#   或下载后：bash restore.sh
#
# 可用环境变量（必须传给 bash，不能写在 curl 前面）：
#   CODEX_HOME              默认 ~/.codex
#   CODEX_RESTORE_MODE      backup | official | abort
#                           backup=恢复安装脚本留下的备份
#                           official=保留其他配置，只切回官方 openai provider

set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
DOCS_URL="https://docs.ai80.vip/codex/"
CONFIG="${CODEX_HOME}/config.toml"

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

latest_backup() {
  local marker="${CODEX_HOME}/.code80-last-backup"
  if [ -f "$marker" ]; then
    local p
    p=$(tr -d '\r\n' < "$marker")
    if [ -n "$p" ] && [ -f "$p" ]; then
      printf '%s\n' "$p"
      return 0
    fi
  fi
  ls -1t "${CODEX_HOME}"/config.toml.bak.* 2>/dev/null | head -1 || true
}

switch_official() {
  local dest="$1"
  DEST="$dest" node - <<'JS'
const fs = require("fs");
const dest = process.env.DEST;
let text = fs.readFileSync(dest, "utf8");
if (!text.endsWith("\n")) text += "\n";

function firstTableIndex(s) {
  const m = s.match(/^\[/m);
  return m ? m.index : s.length;
}

function upsertRootKey(s, key, valueLine) {
  const split = firstTableIndex(s);
  let head = s.slice(0, split);
  const tail = s.slice(split);
  const re = new RegExp("^(\\s*#\\s*)?" + key.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + "\\s*=.*$", "m");
  if (re.test(head)) head = head.replace(re, valueLine);
  else {
    if (head && !head.endsWith("\n")) head += "\n";
    head += valueLine + "\n";
  }
  return head + tail;
}

function commentRootKey(s, key) {
  const split = firstTableIndex(s);
  let head = s.slice(0, split);
  const tail = s.slice(split);
  const re = new RegExp("^(\\s*#\\s*)?" + key.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + "\\s*=.*$", "m");
  if (re.test(head)) head = head.replace(re, (m) => (m.trim().startsWith("#") ? m : "# " + m));
  return head + tail;
}

function commentTable(s, name) {
  const esc = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const re = new RegExp("^\\[" + esc + "\\][^\\n]*\\n(?:^(?!\\[).*(?:\\n|$))*", "m");
  return s.replace(re, (m) =>
    m.split("\n").map((l) => (l && !l.startsWith("#") ? "# " + l : l)).join("\n")
  );
}

text = upsertRootKey(text, "model_provider", 'model_provider = "openai"');
text = commentRootKey(text, "openai_base_url");
text = commentRootKey(text, "forced_login_method");
text = commentTable(text, "model_providers.codex");
text = commentTable(text, "model_providers.Custom");
fs.writeFileSync(dest, text);
JS
}

echo ""
echo "=============================================="
echo "  Codex · 恢复 OpenAI 官方配置"
echo "=============================================="
echo ""
warn "这会改 ~/.codex/config.toml，把 Code80 中转切回官方 OpenAI。"
warn "不会卸载 Codex CLI，也不会删除 auth.json。"
warn "Code80 的 API Key 不能打官方 api.openai.com，切回后请改用 ChatGPT 登录或官方 Key。"
echo ""

if [ ! -f "$CONFIG" ]; then
  err "没有 ${CONFIG}，无需恢复。"
  exit 0
fi

if ! command -v node >/dev/null 2>&1; then
  err "需要 node 来改 TOML。请先安装 Node.js。"
  exit 1
fi

BACKUP_FILE="$(latest_backup || true)"
RESTORE_MODE="${CODEX_RESTORE_MODE:-}"

echo "  1) 恢复安装前的备份（完整还原，oh-my-codex 等也会回来）"
if [ -n "$BACKUP_FILE" ]; then
  echo "     备份：${BACKUP_FILE}"
else
  echo "     （未找到安装脚本备份）"
fi
echo "  2) 只切回官方 openai provider，保留其他配置"
echo "  3) 取消"

if [ -z "$RESTORE_MODE" ]; then
  if [ -r /dev/tty ]; then
    DEFAULT_CHOICE="1"
    if [ -z "$BACKUP_FILE" ]; then DEFAULT_CHOICE="2"; fi
    prompt_tty "请选择 [1/2/3]（默认 ${DEFAULT_CHOICE}）: " CHOICE
    CHOICE="${CHOICE:-$DEFAULT_CHOICE}"
  else
    if [ -n "$BACKUP_FILE" ]; then CHOICE="1"; else CHOICE="2"; fi
    warn "无交互终端，默认选项 ${CHOICE}"
  fi
  case "$CHOICE" in
    1) RESTORE_MODE="backup" ;;
    2) RESTORE_MODE="official" ;;
    3|q|Q|n|N) RESTORE_MODE="abort" ;;
    *)
      err "无效选择"
      exit 1
      ;;
  esac
fi

case "$RESTORE_MODE" in
  abort)
    warn "已取消。"
    exit 0
    ;;
  backup|official) ;;
  *)
    err "CODEX_RESTORE_MODE 只能是 backup / official / abort"
    exit 1
    ;;
esac

SAFETY="${CONFIG}.code80.bak.$(date +%Y%m%d_%H%M%S)"
cp "$CONFIG" "$SAFETY"
warn "当前配置已另存为 ${SAFETY}"

if [ "$RESTORE_MODE" = "backup" ]; then
  if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
    err "没有可用备份。改用 official 模式，或手动从 ${CODEX_HOME}/config.toml.bak.* 复制。"
    exit 1
  fi
  cp "$BACKUP_FILE" "$CONFIG"
  chmod 600 "$CONFIG" 2>/dev/null || true
  ok "已从备份恢复：${BACKUP_FILE}"
else
  switch_official "$CONFIG"
  chmod 600 "$CONFIG" 2>/dev/null || true
  ok "已切回 model_provider = openai，并注释掉 Code80 provider"
fi

echo ""
echo "=============================================="
ok "恢复完成"
echo "=============================================="
echo ""
echo "下一步："
echo "  1. 彻底退出 Codex 再打开（Cmd+Q）"
echo "  2. 用 ChatGPT 登录，或把官方 OpenAI Key 放进 auth.json"
echo "  3. 用新对话测试"
echo ""
echo "文档：${DOCS_URL}"
echo ""
