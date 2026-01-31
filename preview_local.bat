@echo off
setlocal
cd /d "%~dp0"

echo ==============================
echo Hugo Local Server
echo %cd%
echo ==============================

hugo server --disableFastRender --buildDrafts
pause
