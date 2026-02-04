@echo off
setlocal
cd /d "%~dp0"

echo ==============================
echo Hugo Local Server
echo %cd%
echo ==============================

REM --- public フォルダをクリーン ---
if exist public (
  echo Cleaning public folder...
  rmdir /s /q public
)

REM --- Hugo ローカルサーバー起動 ---
hugo server --disableFastRender --buildDrafts

pause
