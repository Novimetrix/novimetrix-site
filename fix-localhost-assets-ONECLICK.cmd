@echo off
setlocal
cd /d "%~dp0"
set "PSFILE=%~dp0__fix_localhost_assets_temp.ps1"
> "%PSFILE%" (
echo $ErrorActionPreference = 'Stop'
echo # Work in the folder where this file sits
echo Set-Location -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)
echo $root = Get-Location
echo Write-Host "Working in $root"
echo 
echo # 1) Target files
echo $files = Get-ChildItem -Recurse -Include *.html,*.css,*.js,*.json
echo 
echo # 2) Safe patterns: only assets under wp-content / wp-includes
echo $patterns = @(
echo   @{ find = 'https?:\/\/(?:localhost|127\.0\.0\.1)(?::\d+)?\/(wp-content|wp-includes)\/'; replace = '/$1/' },
echo   @{ find = '\/\/(?:localhost|127\.0\.0\.1)(?::\d+)?\/(wp-content|wp-includes)\/';         replace = '/$1/' },
echo   @{ find = 'https?:\\\/\\\/(?:localhost|127\.0\.0\.1)(?::\d+)?\\\/(wp-content|wp-includes)\\\/'; replace = '/$1/' },
echo   @{ find = 'https?%%3A%%2F%%2F(?:localhost|127\.0\.0\.1)(?:%%3A\d+)?%%2F(wp-content|wp-includes)%%2F'; replace = '/$1/' }
echo )
echo 
echo # 3) Rewrite
echo foreach ($f in $files) {
echo   $c = Get-Content -Raw -LiteralPath $f.FullName
echo   foreach ($p in $patterns) {
echo     $c = [regex]::Replace($c, $p.find, $p.replace)
echo   }
echo   Set-Content -NoNewline -Encoding UTF8 -LiteralPath $f.FullName -Value $c
echo }
echo 
echo # 4) Report leftovers
echo $left = Select-String -Path $files.FullName -Pattern 'localhost|127\.0\.0\.1' -SimpleMatch
echo Write-Host "`nLeftover 'localhost/127.0.0.1' matches:" $left.Count
echo if ($left.Count -gt 0) {
echo   $left | Select-Object -First 5 | ForEach-Object { Write-Host $_.Path ':' $_.Line.Trim() }
echo } else {
echo   Write-Host 'All clean ✅'
echo }
echo Read-Host "`nDone. Press Enter to close"
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"
del "%PSFILE%" >nul 2>&1
endlocal
