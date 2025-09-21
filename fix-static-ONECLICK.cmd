@echo off
setlocal
cd /d "%~dp0"
set "PSFILE=%~dp0__fix_static_temp.ps1"
> "%PSFILE%" (
echo $ErrorActionPreference = 'Stop'
echo # Work in the folder where this file sits (your repo root)
echo Set-Location -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)
echo $root = Get-Location
echo Write-Host "Fixing export in $root`n"
echo 
echo # --- Part 1: Rewrite localhost asset URLs (safe: only wp-content/wp-includes) ---
echo $files = Get-ChildItem -Recurse -File -Include *.html,*.css,*.js,*.json
echo $patterns = @(
echo   @{ find = 'https?:\/\/(?:localhost|127\.0\.0\.1)(?::\d+)?\/(wp-content|wp-includes)\/'; replace = '/$1/' },
echo   @{ find = '\/\/(?:localhost|127\.0\.0\.1)(?::\d+)?\/(wp-content|wp-includes)\/';         replace = '/$1/' },
echo   @{ find = 'https?:\\\/\\\/(?:localhost|127\.0\.0\.1)(?::\d+)?\\\/(wp-content|wp-includes)\\\/'; replace = '/$1/' },
echo   @{ find = 'https?%%3A%%2F%%2F(?:localhost|127\.0\.0\.1)(?:%%3A\d+)?%%2F(wp-content|wp-includes)%%2F'; replace = '/$1/' }
echo )
echo 
echo [int]$rewrittenA = 0
echo foreach ($f in $files) {
echo   $c = Get-Content -Raw -LiteralPath $f.FullName
echo   $orig = $c
echo   foreach ($p in $patterns) { $c = [regex]::Replace($c, $p.find, $p.replace) }
echo   if ($c -ne $orig) {
echo     Set-Content -NoNewline -Encoding UTF8 -LiteralPath $f.FullName -Value $c
echo     $rewrittenA++
echo   }
echo }
echo $leftLocal = (Select-String -Path $files.FullName -Pattern 'localhost|127\.0\.0\.1' -SimpleMatch).Count
echo Write-Host "Step 1: files rewritten =" $rewrittenA "; leftover 'localhost/127.0.0.1' matches =" $leftLocal "`n"
echo 
echo # --- Part 2: Strip responsive attrs from <img>/<source> in HTML ---
echo $htmlFiles = Get-ChildItem -Recurse -File -Include *.html
echo [int]$rewrittenB = 0
echo foreach ($f in $htmlFiles) {
echo   $c = Get-Content -Raw -LiteralPath $f.FullName
echo   $orig = $c
echo   $c = [regex]::Replace($c, '<(img|source)\b[^>]*>', {
echo     param($m)
echo     $t = $m.Value
echo     # remove srcset/sizes and data- versions
echo     $t = [regex]::Replace($t, '\s(?:data-)?(?:srcset|sizes)=(".*?"|\'.*?\')', '', 'IgnoreCase')
echo     return $t
echo   }, 'IgnoreCase')
echo   if ($c -ne $orig) {
echo     Set-Content -NoNewline -Encoding UTF8 -LiteralPath $f.FullName -Value $c
echo     $rewrittenB++
echo   }
echo }
echo $leftSrcset = (Select-String -Path $htmlFiles.FullName -Pattern 'srcset|data-srcset' -SimpleMatch).Count
echo Write-Host "Step 2: HTML files rewritten =" $rewrittenB "; leftover srcset/data-srcset matches =" $leftSrcset "`n"
echo 
echo if ($leftLocal -eq 0 -and $leftSrcset -eq 0) {
echo   Write-Host "All clean ✅" -ForegroundColor Green
echo } else {
echo   Write-Host "Done. Some leftovers remain (see counts above)." -ForegroundColor Yellow
echo }
echo Read-Host "`nDone. Press Enter to close"
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"
del "%PSFILE%" >nul 2>&1
endlocal
