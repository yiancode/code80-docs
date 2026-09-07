@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo Code80 Codex CLI 一键安装配置
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "iex ([IO.File]::ReadAllText((Join-Path (Get-Location) 'install.ps1'), [Text.Encoding]::UTF8).TrimStart([char]0xFEFF))"
if errorlevel 1 (
  echo.
  echo 安装失败，请把上面的报错截图后到 https://docs.ai80.vip/codex/faq 查看。
)
echo.
pause
