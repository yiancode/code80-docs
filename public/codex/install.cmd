@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo Code80 Codex CLI 一键安装配置
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
if errorlevel 1 (
  echo.
  echo 安装失败，请把上面的报错截图后到 https://docs.ai80.vip/codex/faq 查看。
)
echo.
pause
