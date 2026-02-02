@echo off
setlocal EnableExtensions

cd /d "%~dp0"

:: Gitが動くか確認
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo [ERROR] このフォルダはGitリポジトリではないか、Gitが実行できません。
  pause
  exit /b 1
)

:: 変更があるかチェック（1行でもあれば変更扱い）
set "CHANGED="
for /f "delims=" %%A in ('git status --porcelain') do (
  set "CHANGED=1
)

if not defined CHANGED (
  echo 変更はありません。
  pause
  exit /b 0
)

echo 変更を検出しました。アップロードを開始します...

git add -A
git commit -m "update site" >nul 2>&1

git push
if errorlevel 1 (
  echo.
  echo [ERROR] アップロードに失敗しました。上記のエラーメッセージを確認してください。
  pause
  exit /b 1
)

echo.
echo アップロードが正常に完了しました！
pause
