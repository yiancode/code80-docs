# 从 Code80 中转改回 OpenAI 官方配置（Windows）
#   irm https://docs.ai80.vip/codex/restore.ps1 | iex
#   或：powershell -ExecutionPolicy Bypass -File restore.ps1
#
# CODEX_HOME
# CODEX_RESTORE_MODE   backup | official | abort
# CODEX_RESTORE_AUTH   replace | chatgpt | keep
#
# 不要加 [CmdletBinding()]/param()。iex 下载执行时它们不能出现在注释后面。

$ErrorActionPreference = "Stop"

if (-not $PSCommandPath) {
    $probe = ([char]0x5B89).ToString() + [char]0x88C5
    if ('安装' -ne $probe -and -not $env:CODE80_PS1_UTF8) {
        $env:CODE80_PS1_UTF8 = "1"
        $url = "https://docs.ai80.vip/codex/restore.ps1"
        $bytes = (Invoke-WebRequest -UseBasicParsing -Uri $url).RawContentStream.ToArray()
        $text = [Text.Encoding]::UTF8.GetString($bytes).TrimStart([char]0xFEFF)
        Invoke-Expression $text
        return
    }
}

try {
    cmd /c "chcp 65001 >nul"
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [Console]::InputEncoding = $utf8
    [Console]::OutputEncoding = $utf8
    $OutputEncoding = $utf8
} catch {}

$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$DocsUrl = "https://docs.ai80.vip/codex/"
$Config = Join-Path $CodexHome "config.toml"

function Write-Info([string]$Message) { Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Ok([string]$Message) { Write-Host "[OK]   $Message" -ForegroundColor Green }
function Write-Warn([string]$Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err([string]$Message) { Write-Host "[ERR]  $Message" -ForegroundColor Red }

function Invoke-NodeJs([string]$JavaScript) {
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("code80-codex-" + [guid]::NewGuid().ToString("N") + ".js")
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($tmp, $JavaScript, $utf8NoBom)
    try {
        & node $tmp
        if ($LASTEXITCODE -ne 0) {
            throw "node 执行失败（退出码 $LASTEXITCODE）"
        }
    } finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}

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
    Invoke-NodeJs @'
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
function commentCode80Model(s) {
  const split = firstTableIndex(s);
  let head = s.slice(0, split);
  const tail = s.slice(split);
  const re = /^(\s*#\s*)?model\s*=\s*"([^"]*)".*$/m;
  const m = head.match(re);
  if (!m || m[1]) return s;
  if (/^(gpt-5\.6-(terra|sol|luna)|gpt-luna)$/.test(m[2])) {
    head = head.replace(re, (line) => "# " + line);
  }
  return head + tail;
}
text = upsertRootKey(text, "model_provider", "model_provider = \"openai\"");
text = commentRootKey(text, "openai_base_url");
text = commentRootKey(text, "forced_login_method");
text = commentTable(text, "model_providers.codex");
text = commentTable(text, "model_providers.Custom");
text = commentCode80Model(text);
fs.writeFileSync(dest, text);
'@
}

function Backup-Auth {
    $auth = Join-Path $CodexHome "auth.json"
    if (-not (Test-Path $auth)) { return $false }
    $bak = Join-Path $CodexHome ("auth.json.code80.bak." + (Get-Date -Format "yyyyMMdd_HHmmss"))
    Copy-Item $auth $bak
    Write-Warn "已备份 auth.json 到 $bak"
    return $true
}

function Write-OfficialAuth([string]$Key) {
    $dest = Join-Path $CodexHome "auth.json"
    $env:KEY = $Key
    $env:DEST = $dest
    try {
        Invoke-NodeJs @'
const fs = require("fs");
const key = process.env.KEY || "";
if (!key) process.exit(2);
fs.writeFileSync(process.env.DEST, JSON.stringify({ OPENAI_API_KEY: key }, null, 2) + "\n");
'@
        return $true
    } catch {
        return $false
    } finally {
        $env:KEY = $null
    }
}

function Strip-OpenAiApiKey {
    $dest = Join-Path $CodexHome "auth.json"
    $env:DEST = $dest
    try {
        Invoke-NodeJs @'
const fs = require("fs");
const dest = process.env.DEST;
let obj = {};
try { obj = JSON.parse(fs.readFileSync(dest, "utf8")); } catch (e) { process.exit(2); }
delete obj.OPENAI_API_KEY;
fs.writeFileSync(dest, JSON.stringify(obj, null, 2) + "\n");
'@
        return $true
    } catch {
        return $false
    }
}

function Invoke-AuthAfterRestore {
    $auth = Join-Path $CodexHome "auth.json"
    Write-Host ""
    Write-Warn "切回官方后，请求会打到 api.openai.com。"
    Write-Warn "auth.json 里如果还是 Code80 Key，必须先 /logout 再登录，直接提问会 401。"
    Write-Host "  1) 输入官方 OpenAI API Key（替换 auth.json）"
    Write-Host "  2) 去掉 auth.json 里的 OPENAI_API_KEY，下次用 ChatGPT 登录  [推荐]"
    Write-Host "  3) 先不改文件，稍后在 Codex 里 /logout 再登录"

    $mode = $env:CODEX_RESTORE_AUTH
    $choice = ""
    if ($mode) {
        switch ($mode) {
            "replace" { $choice = "1" }
            "chatgpt" { $choice = "2" }
            "keep" { $choice = "3" }
            default { Write-Err "CODEX_RESTORE_AUTH 只能是 replace / chatgpt / keep"; exit 1 }
        }
    } else {
        $choice = Read-Host "请选择 [1/2/3]（默认 2）"
        if (-not $choice) { $choice = "2" }
    }

    switch ($choice) {
        "1" {
            Write-Host "请粘贴或输入官方 OpenAI API Key，屏幕上会显示，核对后再回车。"
            $key = (Read-Host "官方 OpenAI API Key").Trim()
            if (-not $key) {
                Write-Err "未提供 Key。已保留现有 auth.json。直接跑 Codex 很可能 401。"
                return
            }
            Backup-Auth | Out-Null
            if (Write-OfficialAuth $key) {
                Write-Ok "已写入官方 Key 到 auth.json"
            } else {
                Write-Err "写入 auth.json 失败。请手动把官方 Key 写进 $auth"
            }
            $key = $null
        }
        "2" {
            if (Test-Path $auth) {
                Backup-Auth | Out-Null
                if (Strip-OpenAiApiKey) {
                    Write-Ok "已去掉 OPENAI_API_KEY。下次启动 Codex 请用 ChatGPT 登录"
                } else {
                    Write-Err "无法改 auth.json。请手动删除其中的 OPENAI_API_KEY，否则跑 Codex 会 401"
                }
            } else {
                Write-Ok "没有 auth.json，下次启动 Codex 请用 ChatGPT 登录"
            }
        }
        "3" {
            Write-Warn "已保留现有 auth.json。打开 Codex 后先输入 /logout，再按提示登录。"
        }
        default { Write-Err "无效选择"; exit 1 }
    }
}

Write-Host ""
Write-Host "=============================================="
Write-Host "  Codex · 恢复 OpenAI 官方配置"
Write-Host "=============================================="
Write-Host ""
Write-Warn "这会改 config.toml，把 Code80 中转切回官方 OpenAI。"
Write-Warn "不会卸载 Codex CLI，也不会删除 auth.json。"
Write-Warn "切回后请打开 Codex，先输入 /logout，再按提示登录 ChatGPT。"
Write-Warn "带着 Code80 Key 直接提问会 401（api.openai.com）。"
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
    Write-Ok "已切回 model_provider = openai，并注释掉 Code80 provider / Code80 模型 ID"
}

$raw = Get-Content -Raw $Config
if ($raw -match '(?m)^\s*model_provider\s*=\s*"openai"' -or $raw -notmatch '(?m)^\s*model_provider\s*=') {
    Invoke-AuthAfterRestore
}

Write-Host ""
Write-Host "=============================================="
Write-Ok "恢复完成"
Write-Host "=============================================="
Write-Host ""
Write-Host "下一步："
Write-Host "  1. 打开 Codex，输入 /logout（必须先登出，清掉 Code80 凭据）"
Write-Host "  2. 按提示用 ChatGPT 登录"
Write-Host "  3. 用新对话测试。不要用 gpt-5.6-terra / sol / luna（Code80 模型 ID）"
Write-Host "  4. 若其实还想用 Code80：把刚才另存的 config.toml.code80.bak.* 拷回，或重跑安装脚本"
Write-Host "文档：$DocsUrl"
Write-Host ""
