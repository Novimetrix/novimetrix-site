@echo off
setlocal
set SCRIPT=%~dp0localhost-clean.ps1
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
echo.
echo --- Report saved to "%CD%\localhost-clean.log" ---
echo.
pause
