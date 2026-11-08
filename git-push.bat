@echo off
REM ==================================================
REM  snu site publish button
REM  Double-click to review changes and publish.
REM  Main logic: scripts\publish.ps1
REM ==================================================
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\publish.ps1"
