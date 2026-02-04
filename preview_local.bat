@echo off
setlocal
cd /d "%~dp0"

echo ==============================
echo Hugo Local Server (Polling Mode)
echo %cd%
echo ==============================

REM Hugo ローカルサーバー起動（--poll を追加）
hugo server --disableFastRender --buildDrafts --poll 700ms

pause