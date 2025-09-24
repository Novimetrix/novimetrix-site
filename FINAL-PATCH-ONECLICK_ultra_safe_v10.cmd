@echo off
REM --- Novimetrix FINAL PATCH ULTRA SAFE v10 (double-click) ---
cd /d %~dp0
powershell -ExecutionPolicy Bypass -File ".\FINAL-PATCH-ONECLICK_ultra_safe_v10.ps1" -Root .
echo.
echo --------------------------------------------------------
echo  FINAL-PATCH-ONECLICK (ULTRA SAFE v10) finished.
echo  Log file saved as FINAL-PATCH.log in this folder.
echo --------------------------------------------------------
echo.
pause
