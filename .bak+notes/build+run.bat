@echo off
setlocal
cd /d "%~dp0"

echo ==============================
echo Hugo Build & Local Server
echo Working directory:
echo %cd%
echo ==============================

REM --- public フォルダ削除 ---
if exist public (
  echo Cleaning public...
  rmdir /s /q public
)

REM --- 本番ビルド ---
echo.
echo Building site (PROD)...
hugo --printPathWarnings --printI18nWarnings

if errorlevel 1 (
  echo.
  echo Build failed. Exiting.
  pause
  exit /b 1
)

echo Build completed successfully.

REM --- ローカルサーバー起動 ---
echo.
echo Starting Hugo server...
hugo server --disableFastRender --buildDrafts

pause
