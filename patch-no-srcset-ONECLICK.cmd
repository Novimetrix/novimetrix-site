@echo off
setlocal
cd /d "%~dp0"
set "PSFILE=%~dp0__patch_no_srcset_temp.ps1"
> "%PSFILE%" (
echo $ErrorActionPreference = 'Stop'
echo Set-Location -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)
echo $root = Get-Location
echo Write-Host "Injecting no-srcset runtime patch in $root`n"
echo 
echo # 1) Ensure assets/js folder exists
echo $assets = Join-Path $root "assets\js"
echo New-Item -ItemType Directory -Force -Path $assets | Out-Null
echo 
echo # 2) Write the runtime script that removes srcset/sizes/imagesrcset after DOM ready & on load
echo $jsPath = Join-Path $assets "no-srcset.js"
echo $js = @"
echo (() => {
echo   const wipe = () => {
echo     document.querySelectorAll('img[srcset],source[srcset],link[imagesrcset]').forEach(el => {
echo       el.removeAttribute('srcset');
echo       if (el.hasAttribute('imagesrcset')) el.removeAttribute('imagesrcset');
echo       if (el.hasAttribute('sizes')) el.removeAttribute('sizes');
echo       if (el.hasAttribute('data-srcset')) el.removeAttribute('data-srcset');
echo       if (el.hasAttribute('data-sizes')) el.removeAttribute('data-sizes');
echo     });
echo   };
echo   if (document.readyState === 'loading') {
echo     document.addEventListener('DOMContentLoaded', wipe, { once: true });
echo     window.addEventListener('load', wipe, { once: true });
echo   } else {
echo     wipe();
echo     window.addEventListener('load', wipe, { once: true });
echo   }
echo })();
echo "@
echo Set-Content -LiteralPath $jsPath -Value $js -Encoding UTF8
echo 
echo # 3) Inject <script> tag before </head> in all HTML files that don't already have it
echo $snippet = '<script src="/assets/js/no-srcset.js"></script>'
echo $files = Get-ChildItem -Recurse -File -Include *.html
echo [int]$patched = 0
echo foreach ($f in $files) {
echo   $c = Get-Content -Raw -LiteralPath $f.FullName
echo   if ($c -notmatch [regex]::Escape($snippet)) {
echo     if ($c -match '</head>') {
echo       $c = $c -replace '</head>', "  $snippet`r`n</head>"
echo       Set-Content -NoNewline -LiteralPath $f.FullName -Value $c -Encoding UTF8
echo       $patched++
echo     }
echo   }
echo }
echo Write-Host "Injected script into $patched HTML file(s)."
echo 
echo Write-Host "`nDone. Commit & push your changes."
echo Read-Host "Press Enter to close"
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"
del "%PSFILE%" >nul 2>&1
endlocal
