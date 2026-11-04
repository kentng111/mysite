@echo off
setlocal
cd /d "%~dp0"

echo ==============================
echo  s.n.u site preview
echo  Close this window to stop the preview.
echo ==============================

REM Hugo check (installed with winget, or hugo.exe placed in this folder)
where hugo >nul 2>&1
if errorlevel 1 if not exist "%~dp0hugo.exe" (
  echo.
  echo ERROR: Hugo was not found.
  echo Please see the setup manual, file 02, step 3.
  echo.
  pause
  exit /b 1
)

REM Open the browser a few seconds after the server starts
start "" cmd /c "timeout /t 5 /nobreak >nul & start http://localhost:1313/"

hugo server --disableFastRender --buildDrafts --poll 700ms

pause
