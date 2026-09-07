# Code80 Codex CLI 一键安装配置（Windows）
# 用法（PowerShell）：
#   irm https://docs.ai80.vip/codex/install.ps1 | iex
#   或下载后：powershell -ExecutionPolicy Bypass -File install.ps1
#
# 可用环境变量：
#   CODE80_API_KEY / OPENAI_API_KEY   跳过交互输入
#   CODEX_MODEL                       默认 gpt-5.6-terra
#   CODE80_BASE_URL                   默认 https://code.ai80.vip

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

$BaseUrl = if ($env:CODE80_BASE_URL) { $env:CODE80_BASE_URL } else { "https://code.ai80.vip" }
$Model = if ($env:CODEX_MODEL) { $env:CODEX_MODEL } else { "gpt-5.6-terra" }
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$DocsUrl = "https://docs.ai80.vip/codex/"

function Write-Info([string]$Message) { Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Ok([string]$Message) { Write-Host "[OK]   $Message" -ForegroundColor Green }
function Write-Warn([string]$Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err([string]$Message) { Write-Host "[ERR]  $Message" -ForegroundColor Red }

function Refresh-Path {
    $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $user = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($machine -and $user) {
        $env:Path = "$machine;$user"
    } elseif ($machine) {
        $env:Path = $machine
    } elseif ($user) {
        $env:Path = $user
    }
}

function Get-NodeMajor {
    $raw = (& node -v 2>$null)
    if (-not $raw) { return 0 }
    $t = $raw.Trim().TrimStart("v")
    $major = ($t -split "\.")[0]
    [int]$major
}

function Write-CodexConfig([string]$Path) {
    $content = @"
#:schema https://developers.openai.com/codex/config-schema.json

model = "$Model"
model_provider = "codex"
model_reasoning_effort = "medium"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
web_search = "cached"
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
"@
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $content, $utf8NoBom)
}

function Write-AuthJson([string]$Path, [string]$Key) {
    $obj = @{ OPENAI_API_KEY = $Key }
    $json = $obj | ConvertTo-Json -Compress:$false
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $json + "`n", $utf8NoBom)
}

Write-Host ""
Write-Host "=============================================="
Write-Host "  Code80 · Codex CLI 一键安装配置"
Write-Host "=============================================="
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

Write-Info "4/6 写入 config.toml（Code80 推荐配置）"
$configPath = Join-Path $CodexHome "config.toml"
if (Test-Path $configPath) {
    $backup = Join-Path $CodexHome ("config.toml.bak." + (Get-Date -Format "yyyyMMdd_HHmmss"))
    Copy-Item $configPath $backup
    Write-Warn "已备份原配置到 $backup"
}
Write-CodexConfig $configPath
Write-Ok "模型 $Model · provider=codex · $BaseUrl"
Write-Ok "requires_openai_auth=true · supports_websockets=false"

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
        $secure = Read-Host "请输入 Code80 OpenAI 分组 API Key" -AsSecureString
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
        try {
            $key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        } finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
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
Write-Host "  1. 彻底退出已打开的 Codex（任务管理器结束进程），不要只关窗口"
Write-Host "  2. 新开终端：  cd 你的项目;  codex"
Write-Host "  3. 用新对话测试。日常模型是 $Model"
Write-Host "     复杂任务 gpt-5.6-sol · 图快 gpt-5.6-luna"
Write-Host "     不要写 gpt-5.6 或 gpt-luna"
Write-Host ""
Write-Host "文档：$DocsUrl"
Write-Host ""
