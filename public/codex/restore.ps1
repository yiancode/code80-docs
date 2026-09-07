# 从 Code80 中转改回 OpenAI 官方配置（Windows）
#   irm https://docs.ai80.vip/codex/restore.ps1 | iex
#   或：powershell -ExecutionPolicy Bypass -File restore.ps1
#
# CODEX_HOME
# CODEX_RESTORE_MODE   backup | official | abort

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$DocsUrl = "https://docs.ai80.vip/codex/"
$Config = Join-Path $CodexHome "config.toml"

function Write-Info([string]$Message) { Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Ok([string]$Message) { Write-Host "[OK]   $Message" -ForegroundColor Green }
function Write-Warn([string]$Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err([string]$Message) { Write-Host "[ERR]  $Message" -ForegroundColor Red }

function Get-LatestBackup {
    $marker = Join-Path $CodexHome ".code80-last-backup"
    if (Test-Path $marker) {
        $p = (Get-Content -Raw $marker).Trim()
        if ($p -and (Test-Path $p)) { return $p }
    }
    $files = Get-ChildItem -Path $CodexHome -Filter "config.toml.bak.*" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending
    if ($files) { return $files[0].FullName }
    return $null
}

function Switch-Official([string]$Path) {
    $env:DEST = $Path
    node -e @'
const fs = require("fs");
const dest = process.env.DEST;
let text = fs.readFileSync(dest, "utf8");
if (!text.endsWith("\n")) text += "\n";
function esc(s) { return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); }
function firstTableIndex(s) { const m = s.match(/^\[/m); return m ? m.index : s.length; }
function upsertRootKey(s, key, valueLine) {
  const split = firstTableIndex(s);
  let head = s.slice(0, split);
  const tail = s.slice(split);
  const re = new RegExp("^(\\s*#\\s*)?" + esc(key) + "\\s*=.*$", "m");
  if (re.test(head)) head = head.replace(re, valueLine);
  else { if (head && !head.endsWith("\n")) head += "\n"; head += valueLine + "\n"; }
  return head + tail;
}
function commentRootKey(s, key) {
  const split = firstTableIndex(s);
  let head = s.slice(0, split);
  const tail = s.slice(split);
  const re = new RegExp("^(\\s*#\\s*)?" + esc(key) + "\\s*=.*$", "m");
  if (re.test(head)) head = head.replace(re, (m) => (m.trim().startsWith("#") ? m : "# " + m));
  return head + tail;
}
function commentTable(s, name) {
  const re = new RegExp("^\\[" + esc(name) + "\\][^\\n]*\\n(?:^(?!\\[).*(?:\\n|$))*", "m");
  return s.replace(re, (m) => m.split("\n").map((l) => (l && !l.startsWith("#") ? "# " + l : l)).join("\n"));
}
text = upsertRootKey(text, "model_provider", "model_provider = \"openai\"");
text = commentRootKey(text, "openai_base_url");
text = commentRootKey(text, "forced_login_method");
text = commentTable(text, "model_providers.codex");
text = commentTable(text, "model_providers.Custom");
fs.writeFileSync(dest, text);
'@
}

Write-Host ""
Write-Host "=============================================="
Write-Host "  Codex · 恢复 OpenAI 官方配置"
Write-Host "=============================================="
Write-Host ""
Write-Warn "这会改 config.toml，把 Code80 中转切回官方 OpenAI。"
Write-Warn "不会卸载 Codex CLI，也不会删除 auth.json。"
Write-Warn "Code80 的 API Key 不能打官方 api.openai.com，切回后请改用 ChatGPT 登录或官方 Key。"
Write-Host ""

if (-not (Test-Path $Config)) {
    Write-Err "没有 $Config，无需恢复。"
    exit 0
}
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Err "需要 node 来改 TOML。"
    exit 1
}

$backupFile = Get-LatestBackup
$restoreMode = $env:CODEX_RESTORE_MODE

Write-Host "  1) 恢复安装前的备份（完整还原）"
if ($backupFile) { Write-Host "     备份：$backupFile" } else { Write-Host "     （未找到安装脚本备份）" }
Write-Host "  2) 只切回官方 openai provider，保留其他配置"
Write-Host "  3) 取消"

if (-not $restoreMode) {
    $default = if ($backupFile) { "1" } else { "2" }
    $choice = Read-Host "请选择 [1/2/3]（默认 $default）"
    if (-not $choice) { $choice = $default }
    switch ($choice) {
        "1" { $restoreMode = "backup" }
        "2" { $restoreMode = "official" }
        "3" { $restoreMode = "abort" }
        default { Write-Err "无效选择"; exit 1 }
    }
}

if ($restoreMode -eq "abort") {
    Write-Warn "已取消。"
    exit 0
}

$safety = Join-Path $CodexHome ("config.toml.code80.bak." + (Get-Date -Format "yyyyMMdd_HHmmss"))
Copy-Item $Config $safety
Write-Warn "当前配置已另存为 $safety"

if ($restoreMode -eq "backup") {
    if (-not $backupFile -or -not (Test-Path $backupFile)) {
        Write-Err "没有可用备份。"
        exit 1
    }
    Copy-Item $backupFile $Config -Force
    Write-Ok "已从备份恢复：$backupFile"
} else {
    Switch-Official $Config
    Write-Ok "已切回 model_provider = openai，并注释掉 Code80 provider"
}

Write-Host ""
Write-Host "=============================================="
Write-Ok "恢复完成"
Write-Host "=============================================="
Write-Host ""
Write-Host "下一步：彻底退出 Codex，用 ChatGPT 登录或官方 Key，再用新对话测试。"
Write-Host "文档：$DocsUrl"
Write-Host ""
