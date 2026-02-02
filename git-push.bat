@echo off
setlocal
cd /d "%~dp0"

echo ==============================
echo Git Push (Hugo / GitHub Pages)
echo Working directory:
echo %cd%
echo ==============================

REM --- Gitリポジトリ確認 ---
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo ERROR: This is not a git repository.
  pause
  exit /b 1
)

REM --- 変更確認 ---
git status --porcelain > temp_git_status.txt

for %%A in (temp_git_status.txt) do (
  echo Changes detected. Committing...

  git add .
  git commit -m "update site"
  git push

  del temp_git_status.txt
  echo.
  echo Push completed.
  pause
  exit /b
)

echo No changes to commit.
del temp_git_status.txt
pause
