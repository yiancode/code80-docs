@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo Codex 恢复 OpenAI 官方配置
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0restore.ps1"
if errorlevel 1 (
  echo.
  echo 恢复失败，请到 https://docs.ai80.vip/codex/faq 查看。
)
echo.
pause
