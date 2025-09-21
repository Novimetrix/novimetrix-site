@echo off
setlocal
cd /d "%~dp0"
set "PSFILE=%~dp0__strip_srcset_temp.ps1"
> "%PSFILE%" (
echo $ErrorActionPreference = 'Stop'
echo Set-Location -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)
echo $root = Get-Location
echo Write-Host "Stripping srcset/sizes in $root"
echo 
echo # 1) HTML files only
echo $files = Get-ChildItem -Recurse -Include *.html
echo 
echo # 2) For each file, remove srcset/sizes/data-srcset/data-sizes ONLY inside <img> or <source> tags
echo foreach ($f in $files) {
echo   $c = Get-Content -Raw -LiteralPath $f.FullName
echo 
echo   $c = [regex]::Replace($c, '<(img|source)\b[^>]*>', {
echo     param($m)
echo     $t = $m.Value
echo     $t = [regex]::Replace($t, '\s(?:data-)?(?:srcset|sizes)=(".*?"|\'.*?\')', '', 'IgnoreCase')
echo     return $t
echo   }, 'IgnoreCase')
echo 
echo   Set-Content -NoNewline -Encoding UTF8 -LiteralPath $f.FullName -Value $c
echo }
echo 
echo # 3) Report leftovers
echo $left = Select-String -Path $files.FullName -Pattern 'srcset|data-srcset' -SimpleMatch
echo Write-Host "Leftover 'srcset' matches:" $left.Count
echo if ($left.Count -gt 0) {
echo   $left | Select-Object -First 5 | ForEach-Object { Write-Host $_.Path ':' $_.Line.Trim() }
echo } else {
echo   Write-Host "All img/srcset stripped ✅"
echo }
echo 
echo Read-Host "`nDone. Press Enter to close"
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"
del "%PSFILE%" >nul 2>&1
endlocal
