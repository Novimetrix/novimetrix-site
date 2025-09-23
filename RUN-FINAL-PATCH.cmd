@echo off
:: RUN-FINAL-PATCH.cmd — launcher for the all-in-one fix (v3, removes Elementor runtime/frontend JS)
setlocal EnableExtensions
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0FINAL-PATCH-ONECLICK.ps1" "."
echo.
echo (Window will stay open. Press any key to close.)
pause >nul
endlocal
