@echo off
:: RUN-FINAL-PATCH.cmd — launcher (v4)
setlocal EnableExtensions
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0FINAL-PATCH-ONECLICK.ps1" "."
echo.
echo (Window will stay open. Press any key to close.)
pause >nul
endlocal
