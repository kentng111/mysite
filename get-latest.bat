@echo off
REM ==================================================
REM  s.n.u site: get latest changes before editing
REM  Main logic: scripts\update.ps1
REM ==================================================
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\update.ps1"
