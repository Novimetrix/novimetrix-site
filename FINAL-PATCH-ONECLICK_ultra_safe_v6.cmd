@echo off
REM --- Novimetrix FINAL PATCH ULTRA SAFE v6 (double-click) ---
cd /d %~dp0
powershell -ExecutionPolicy Bypass -File ".\FINAL-PATCH-ONECLICK_ultra_safe_v6.ps1" -Root .
echo.
echo --------------------------------------------------------
echo  FINAL-PATCH-ONECLICK (ULTRA SAFE v6) finished.
echo  Log file saved as FINAL-PATCH.log in this folder.
echo --------------------------------------------------------
echo.
pause
