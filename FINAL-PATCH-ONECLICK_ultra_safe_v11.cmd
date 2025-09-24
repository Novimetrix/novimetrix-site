@echo off
REM --- Novimetrix FINAL PATCH ULTRA SAFE v11 (double-click) ---
cd /d %~dp0
powershell -ExecutionPolicy Bypass -File ".\FINAL-PATCH-ONECLICK_ultra_safe_v11.ps1" -Root .
echo.
echo --------------------------------------------------------
echo  FINAL-PATCH-ONECLICK (ULTRA SAFE v11) finished.
echo  Log file saved as FINAL-PATCH.log in this folder.
echo --------------------------------------------------------
echo.
pause
