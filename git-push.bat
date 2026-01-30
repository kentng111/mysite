@echo off
cd /d "%~dp0"

git status --porcelain > temp_git_status.txt

if %errorlevel% neq 0 (
  echo Git error.
  pause
  exit /b
)

for %%A in (temp_git_status.txt) do (
  git add .
  git commit -m "update site"
  git push
  del temp_git_status.txt
  pause
  exit /b
)

echo No changes to commit.
del temp_git_status.txt
pause
