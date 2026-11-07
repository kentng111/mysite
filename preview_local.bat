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

REM Open the browser when the server is ready (waits up to 2 minutes)
start "" /min powershell -NoProfile -WindowStyle Hidden -Command "for($i=0;$i -lt 120;$i++){try{$c=New-Object Net.Sockets.TcpClient;$c.Connect('127.0.0.1',1313);$c.Close();Start-Process 'http://localhost:1313/';break}catch{Start-Sleep -Seconds 1}}"

hugo server --disableFastRender --buildDrafts --poll 700ms

pause
