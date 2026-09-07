# Code80 Codex CLI 一键安装配置（Windows）
# 用法（PowerShell）：
#   irm https://docs.ai80.vip/codex/install.ps1 | iex
#   $env:CODE80_API_KEY='你的Key'; irm https://docs.ai80.vip/codex/install.ps1 | iex
#   或下载后：powershell -ExecutionPolicy Bypass -File install.ps1
#
# 环境变量：
#   CODE80_API_KEY / OPENAI_API_KEY
#   CODEX_MODEL            默认 gpt-5.6-terra（覆盖模式才改模型）
#   CODEX_HOME
#   CODE80_BASE_URL
#   CODEX_CONFIG_MODE      keep | replace | abort
#
# 注意：不要加 [CmdletBinding()]/param()。iex 下载执行时它们不能出现在注释后面。

$ErrorActionPreference = "Stop"

# Windows PowerShell 5.1 的 `irm | iex` 常把 UTF-8 按 Latin-1 解码，中文会乱码。
# 用码点拼出「安装」做探针：对不上就按 UTF-8 字节重新加载。
if (-not $PSCommandPath) {
    $probe = ([char]0x5B89).ToString() + [char]0x88C5
    if ('安装' -ne $probe -and -not $env:CODE80_PS1_UTF8) {
        $env:CODE80_PS1_UTF8 = "1"
        $url = "https://docs.ai80.vip/codex/install.ps1"
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

$BaseUrl = if ($env:CODE80_BASE_URL) { $env:CODE80_BASE_URL } else { "https://code.ai80.vip" }
$Model = if ($env:CODEX_MODEL) { $env:CODEX_MODEL } else { "gpt-5.6-terra" }
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$DocsUrl = "https://docs.ai80.vip/codex/"
$RestoreCmd = "irm https://docs.ai80.vip/codex/restore.ps1 | iex"

function Write-Info([string]$Message) { Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Ok([string]$Message) { Write-Host "[OK]   $Message" -ForegroundColor Green }
function Write-Warn([string]$Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err([string]$Message) { Write-Host "[ERR]  $Message" -ForegroundColor Red }

function Refresh-Path {
    $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $user = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($machine -and $user) { $env:Path = "$machine;$user" }
    elseif ($machine) { $env:Path = $machine }
    elseif ($user) { $env:Path = $user }
}

function Get-NodeMajor {
    $raw = (& node -v 2>$null)
    if (-not $raw) { return 0 }
    $t = $raw.Trim().TrimStart("v")
    [int](($t -split "\.")[0])
}

function Write-Utf8([string]$Path, [string]$Content) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

# Windows PowerShell 5.1 调用 node -e 会剥掉参数里的双引号，改写成临时 .js 再执行。
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

function Write-CodexConfig([string]$Path) {
    $content = @"
#:schema https://developers.openai.com/codex/config-schema.json

model = "$Model"
model_provider = "codex"
model_reasoning_effort = "medium"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
web_search = "live"
personality = "pragmatic"
forced_login_method = "api"
windows_wsl_setup_acknowledged = true

[model_providers.codex]
name = "codex"
base_url = "$BaseUrl"
wire_api = "responses"
requires_openai_auth = true
supports_websockets = false

[windows]
sandbox = "elevated"

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
"@
    Write-Utf8 $Path $content
}

function Ensure-Code80WebsocketOff([string]$Path) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    $text = [IO.File]::ReadAllText($Path, $utf8NoBom)
    if (-not $text.EndsWith("`n")) { $text += "`n" }

    if ($text -match '(?m)^(\s*#\s*)?model_provider\s*=') {
        $text = [regex]::Replace($text, '(?m)^(\s*#\s*)?model_provider\s*=.*$', 'model_provider = "codex"', 1)
    } else {
        $text = "model_provider = `"codex`"`n" + $text
    }

    if ($text -match '(?m)^(\s*#\s*)?web_search\s*=') {
        $text = [regex]::Replace($text, '(?m)^(\s*#\s*)?web_search\s*=.*$', 'web_search = "live"', 1)
    } else {
        $text = $text -replace '(?m)^(\s*model_provider\s*=.*)$', "`$1`nweb_search = `"live`""
        if ($text -notmatch '(?m)^\s*web_search\s*=') {
            $text = "web_search = `"live`"`n" + $text
        }
    }

    if ($text -match '(?m)^\[sandbox_workspace_write\]') {
        if ($text -match '(?m)^(\s*#\s*)?network_access\s*=') {
            $text = [regex]::Replace($text, '(?m)^(\s*#\s*)?network_access\s*=.*$', 'network_access = true')
        } else {
            $text = [regex]::Replace($text, '(?m)^(\[sandbox_workspace_write\][^\r\n]*\r?\n)', "`$1network_access = true`n")
        }
    } else {
        $text = $text.TrimEnd() + "`n`n[sandbox_workspace_write]`nnetwork_access = true`nwritable_roots = []`n"
    }

    if ($text -match '(?m)^\[model_providers\.codex\]') {
        if ($text -match '(?m)^(\s*#\s*)?supports_websockets\s*=') {
            $text = [regex]::Replace($text, '(?m)^(\s*#\s*)?supports_websockets\s*=.*$', 'supports_websockets = false')
        } else {
            $text = [regex]::Replace($text, '(?m)^(\[model_providers\.codex\][^\r\n]*\r?\n)', "`$1supports_websockets = false`n")
        }
        if ($text -match '(?m)^(\s*#\s*)?requires_openai_auth\s*=') {
            $text = [regex]::Replace($text, '(?m)^(\s*#\s*)?requires_openai_auth\s*=.*$', 'requires_openai_auth = true')
        }
    } else {
        $text = $text.TrimEnd() + @"

[model_providers.codex]
name = "codex"
base_url = "$BaseUrl"
wire_api = "responses"
requires_openai_auth = true
supports_websockets = false

"@
    }

    Write-Utf8 $Path $text
    $verify = [IO.File]::ReadAllText($Path, $utf8NoBom)
    if ($verify -notmatch '(?m)^\s*supports_websockets\s*=\s*false') {
        throw "未能写入 supports_websockets = false，请手动编辑 $Path"
    }
    if ($verify -notmatch '(?m)^\s*model_provider\s*=\s*"codex"') {
        throw "未能写入 model_provider = `"codex`"，请手动编辑 $Path"
    }
}

function Apply-KeepConfig([string]$Path) {
    $env:DEST = $Path
    $env:BASE_URL = $BaseUrl
    Invoke-NodeJs @'
const fs = require("fs");
const dest = process.env.DEST;
const baseUrl = process.env.BASE_URL;
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
function upsertTable(s, name, body) {
  const re = new RegExp("^\\[" + esc(name) + "\\][^\\n]*\\n(?:^(?!\\[).*(?:\\n|$))*", "m");
  const block = "[" + name + "]\n" + body + (body.endsWith("\n") ? "" : "\n");
  if (re.test(s)) return s.replace(re, block);
  if (!s.endsWith("\n")) s += "\n";
  return s + "\n" + block;
}
function commentTable(s, name) {
  const re = new RegExp("^\\[" + esc(name) + "\\][^\\n]*\\n(?:^(?!\\[).*(?:\\n|$))*", "m");
  return s.replace(re, (m) => m.split("\n").map((l) => (l && !l.startsWith("#") ? "# " + l : l)).join("\n"));
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
text = upsertRootKey(text, "model_provider", "model_provider = \"codex\"");
text = upsertRootKey(text, "forced_login_method", "forced_login_method = \"api\"");
text = upsertRootKey(text, "web_search", "web_search = \"live\"");
text = upsertTableKey(text, "sandbox_workspace_write", "network_access", "network_access = true");
text = commentTable(text, "model_providers.Custom");
text = upsertTable(text, "model_providers.codex", [
  "name = \"codex\"",
  "base_url = \"" + baseUrl + "\"",
  "wire_api = \"responses\"",
  "requires_openai_auth = true",
  "supports_websockets = false",
  ""
].join("\n"));
fs.writeFileSync(dest, text);
'@
}

function Write-AuthJson([string]$Path, [string]$Key) {
    $obj = @{ OPENAI_API_KEY = $Key }
    $json = $obj | ConvertTo-Json -Compress:$false
    Write-Utf8 $Path ($json + "`n")
}

Write-Host ""
Write-Host "=============================================="
Write-Host "  Code80 · Codex CLI 一键安装配置"
Write-Host "=============================================="
Write-Host ""
Write-Warn "本脚本会改 ~/.codex/config.toml 以接入 Code80。"
Write-Warn "已有配置会先备份。覆盖模式会丢掉 oh-my-codex / MCP / hooks 等自定义内容。"
Write-Warn "装完若要改回 OpenAI 官方： $RestoreCmd"
Write-Host ""

Write-Info "1/6 检查 Node.js 22+"
Refresh-Path
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
    Write-Warn "未找到 node，尝试用 winget 安装 LTS"
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-Err "未找到 winget。请从 https://nodejs.org 安装 Node.js 22+ 后重跑。"
        exit 1
    }
    winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements
    Refresh-Path
    $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
    if (-not $nodeCmd) {
        Write-Err "Node.js 安装后仍不在 PATH。请关闭本窗口，新开 PowerShell 再运行本脚本。"
        exit 1
    }
}

$major = Get-NodeMajor
if ($major -lt 22) {
    Write-Err "Codex CLI 需要 Node.js 22+，当前是 $((node -v) 2>$null)"
    exit 1
}
Write-Ok "Node $(node -v)"

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Err "未找到 npm。请重装 Node.js 22+。"
    exit 1
}

Write-Info "2/6 安装官方 @openai/codex"
npm install -g @openai/codex
Refresh-Path
$codexVer = ""
try { $codexVer = (codex --version 2>$null | Out-String).Trim() } catch {}
if ($codexVer) { Write-Ok "Codex $codexVer" } else { Write-Ok "Codex 已安装（新开终端后 codex --version）" }

Write-Info "3/6 准备 $CodexHome"
New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null

Write-Info "4/6 处理 config.toml"
$configPath = Join-Path $CodexHome "config.toml"
$configMode = $env:CODEX_CONFIG_MODE
$hasConfig = Test-Path $configPath
if ($hasConfig) {
    $raw = Get-Content -Raw $configPath
    if ($raw -match "oh-my-codex") { Write-Warn "检测到 oh-my-codex。" }
    else { Write-Warn "检测到已有 config.toml。" }
    Write-Host "  1) 接入 Code80，保留现有配置（oh-my-codex / MCP / hooks 等）"
    Write-Host "  2) 用 Code80 推荐模板覆盖（会先备份）"
    Write-Host "  3) 取消"
    if (-not $configMode) {
        $choice = Read-Host "请选择 [1/2/3]（默认 1）"
        if (-not $choice) { $choice = "1" }
        switch ($choice) {
            "1" { $configMode = "keep" }
            "2" { $configMode = "replace" }
            "3" { $configMode = "abort" }
            default { Write-Err "无效选择"; exit 1 }
        }
    }
} else {
    $configMode = "replace"
}

if ($configMode -eq "abort") {
    Write-Warn "已取消。未改 config.toml。"
    exit 0
}

if ($hasConfig) {
    $backup = Join-Path $CodexHome ("config.toml.bak." + (Get-Date -Format "yyyyMMdd_HHmmss"))
    Copy-Item $configPath $backup
    Write-Utf8 (Join-Path $CodexHome ".code80-last-backup") ($backup + "`n")
    Write-Warn "已备份原配置到 $backup"
}

if ($configMode -eq "keep" -and $hasConfig) {
    Apply-KeepConfig $configPath
    Write-Ok "已保留现有配置，并接入 Code80 provider"
} else {
    Write-CodexConfig $configPath
    Write-Ok "已写入 Code80 推荐模板"
}
Ensure-Code80WebsocketOff $configPath
Write-Ok "provider=codex · $BaseUrl · requires_openai_auth=true · supports_websockets=false · web_search=live · network_access=true"

Write-Info "5/6 配置 API Key（只写入 auth.json，不会打印）"
$authPath = Join-Path $CodexHome "auth.json"
$key = $env:CODE80_API_KEY
if (-not $key) { $key = $env:OPENAI_API_KEY }
$keepExisting = $false
if (-not $key -and (Test-Path $authPath)) {
    $answer = Read-Host "已存在 auth.json，保留其中的 Key？[Y/n]"
    if ($answer -notmatch '^[nN]') {
        $keepExisting = $true
        Write-Ok "保留现有 auth.json"
    }
}
if (-not $keepExisting) {
    if (-not $key) {
        Write-Host "请粘贴或输入 Key，屏幕上会显示，核对后再回车。"
        $key = (Read-Host "请输入 Code80 OpenAI 分组 API Key").Trim()
    }
    if (-not $key) {
        Write-Err "未提供 API Key。可设置 CODE80_API_KEY 后重跑，或稍后编辑 $authPath"
        exit 1
    }
    Write-AuthJson $authPath $key
    $key = $null
    $env:CODE80_API_KEY = $null
    $env:OPENAI_API_KEY = $null
    Write-Ok "已写入 auth.json"
}

Write-Info "6/6 验证命令"
Refresh-Path
$codexCmd = Get-Command codex -ErrorAction SilentlyContinue
if ($codexCmd) {
    Write-Ok $codexCmd.Source
    try { Write-Ok ((codex --version | Out-String).Trim()) } catch {}
} else {
    Write-Warn "当前窗口找不到 codex。请新开 PowerShell 后再运行。"
}

Write-Host ""
Write-Host "=============================================="
Write-Ok "安装配置完成"
Write-Host "=============================================="
Write-Host ""
Write-Host "下一步："
Write-Host "  1. 彻底退出已打开的 Codex（任务管理器结束进程）"
Write-Host "  2. 新开终端：  cd 你的项目;  codex"
Write-Host "     不要在 C:\WINDOWS\system32 里跑（管理员 PowerShell 的默认目录）"
Write-Host "  3. 不要在 config.toml 写 service_tier = fast / priority，写了会 Reconnecting"
Write-Host "  4. 模板已打开 web_search=live 和 network_access=true（可搜新闻、抓网页、装依赖）"
Write-Host "  5. 用新对话测试。Google / Reddit 在国内仍可能连不上，和 Key 无关"
Write-Host ""
Write-Host "改回 OpenAI 官方配置："
Write-Host "  $RestoreCmd"
Write-Host ""
Write-Host "文档：$DocsUrl"
Write-Host ""
