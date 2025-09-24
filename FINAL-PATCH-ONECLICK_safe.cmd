@echo off
REM --- Novimetrix FINAL PATCH SAFE (double-click version) ---
cd /d %~dp0
powershell -ExecutionPolicy Bypass -File ".\FINAL-PATCH-ONECLICK_safe.ps1" -Root .
echo.
echo --------------------------------------------------------
echo  FINAL-PATCH-ONECLICK (SAFE) has finished running.
echo  Log file saved as FINAL-PATCH.log in this folder.
echo --------------------------------------------------------
echo.
pause
