@echo off
title Restore JS from HTTrack export (one-click)

set "SRC=C:\Users\moham\Desktop\Export\Novimetrix\localhost_10010"
set "DST=%~dp0"

echo Source: %SRC%
echo Dest  : %DST%
echo.

if not exist "%SRC%\wp-includes\js\jquery" (
  echo ERROR: "%SRC%\wp-includes\js\jquery" not found. Check the path.
  pause
  exit /b 1
)

echo Copying jQuery...
xcopy /E /I /Y "%SRC%\wp-includes\js\jquery" "%DST%\wp-includes\js\jquery" >nul

if exist "%SRC%\wp-content\plugins\elementor\assets\js" (
  echo Copying Elementor JS...
  xcopy /E /I /Y "%SRC%\wp-content\plugins\elementor\assets\js" "%DST%\wp-content\plugins\elementor\assets\js" >nul
) else (
  echo (Elementor JS folder not found in SRC - skipping)
)

if exist "%SRC%\wp-content\themes\astra\assets\js" (
  echo Copying Astra theme JS...
  xcopy /E /I /Y "%SRC%\wp-content\themes\astra\assets\js" "%DST%\wp-content\themes\astra\assets\js" >nul
) else (
  echo (Astra JS folder not found in SRC - skipping)
)

echo.
echo Done. Now Commit -> Push -> Purge Cloudflare -> Hard Reload (Ctrl+F5).
pause
