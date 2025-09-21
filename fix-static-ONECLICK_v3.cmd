@echo off
setlocal
cd /d "%~dp0"
set "PSFILE=%~dp0__fix_static_v3_temp.ps1"
> "%PSFILE%" (
echo $ErrorActionPreference = 'Stop'
echo # Work in the folder where this file sits (repo root with index.html)
echo Set-Location -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)
echo $root = Get-Location
echo Write-Host "Fixing static export in $root`n"
echo 
echo # --- Step 1: Rewrite ALL localhost/127 URLs to root-relative (safe: only affects localhost hosts) ---
echo $files = Get-ChildItem -Recurse -File -Include *.html,*.css,*.js,*.json
echo [int]$rewrittenA = 0
echo foreach ($f in $files) {
echo   $c = Get-Content -Raw -LiteralPath $f.FullName
echo   $orig = $c
echo 
echo   # http(s)://localhost[:PORT]/...  →  /...
echo   $c = [regex]::Replace($c, 'https?:\/\/(?:localhost|127\.0\.0\.1)(?::\d+)?\/', '/', 'IgnoreCase')
echo   # protocol-relative //localhost[:PORT]/...  →  /...
echo   $c = [regex]::Replace($c, '\/\/(?:localhost|127\.0\.0\.1)(?::\d+)?\/', '/', 'IgnoreCase')
echo   # JSON-escaped http:\/\/localhost[:PORT]\/...  →  /...
echo   $c = [regex]::Replace($c, 'https?:\\\\/\\\\/(?:localhost|127\.0\.0\.1)(?::\d+)?\\\\/', '/', 'IgnoreCase')
echo   # URL-encoded https%%3A%%2F%%2Flocalhost[:PORT]%%2F...  →  /...
echo   $c = [regex]::Replace($c, 'https?%%3A%%2F%%2F(?:localhost|127\.0\.0\.1)(?:%%3A\d+)?%%2F', '/', 'IgnoreCase')
echo 
echo   if ($c -ne $orig) {
echo     Set-Content -NoNewline -Encoding UTF8 -LiteralPath $f.FullName -Value $c
echo     $rewrittenA++
echo   }
echo }
echo $leftLocal = (Select-String -Path $files.FullName -Pattern 'localhost|127\.0\.0\.1' -SimpleMatch).Count
echo Write-Host "Step 1: files rewritten =" $rewrittenA "; leftover 'localhost/127.0.0.1' matches =" $leftLocal "`n"
echo 
echo # --- Step 2: Remove all srcset/sizes on <img>/<source> to avoid device-specific picks ---
echo $htmlFiles = Get-ChildItem -Recurse -File -Include *.html
echo [int]$rewrittenB = 0
echo foreach ($f in $htmlFiles) {
echo   $c = Get-Content -Raw -LiteralPath $f.FullName
echo   $orig = $c
echo   $c = [regex]::Replace($c, '<(img|source)\b[^>]*>', {
echo     param($m)
echo     $t = $m.Value
echo     $t = [regex]::Replace($t, '\s(?:data-)?(?:srcset|sizes)=(".*?"|\'.*?\')', '', 'IgnoreCase')
echo     return $t
echo   }, 'IgnoreCase')
echo   if ($c -ne $orig) {
echo     Set-Content -NoNewline -Encoding UTF8 -LiteralPath $f.FullName -Value $c
echo     $rewrittenB++
echo   }
echo }
echo $leftSrcset = (Select-String -Path $htmlFiles.FullName -Pattern '\s(?:data-)?(?:srcset|sizes)=').Count
echo Write-Host "Step 2: HTML files rewritten =" $rewrittenB "; leftover srcset/sizes attributes =" $leftSrcset "`n"
echo 
echo # --- Step 3: Show any remaining lines still containing localhost (first 5) ---
echo $left = Select-String -Path $files.FullName -Pattern 'localhost|127\.0\.0\.1' -AllMatches
echo if ($left) {
echo   Write-Host "Remaining localhost hits (first 5):" -ForegroundColor Yellow
echo   $left | Select-Object -First 5 | ForEach-Object { Write-Host $_.Path ':' $_.Line.Trim() }
echo } else {
echo   Write-Host "All localhost references removed ✅" -ForegroundColor Green
echo }
echo 
echo Write-Host "`nDone."
echo Read-Host "Press Enter to close"
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"
del "%PSFILE%" >nul 2>&1
endlocal
