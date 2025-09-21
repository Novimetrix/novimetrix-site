@echo off
setlocal
cd /d "%~dp0"
set "PSFILE=%~dp0__patch_no_srcset_v2_temp.ps1"
> "%PSFILE%" (
echo $ErrorActionPreference = 'Stop'
echo Set-Location -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)
echo $root = Get-Location
echo Write-Host "Injecting stronger no-srcset runtime patch in $root`n"
echo ^# 1^) Ensure assets/js folder exists
echo $assets = Join-Path $root "assets\js"
echo New-Item -ItemType Directory -Force -Path $assets ^| Out-Null
echo ^# 2^) Write the runtime script (mutation observer + sanitizer)
echo $jsPath = Join-Path $assets "no-srcset.js"
echo $js = @"
echo (() => {
echo   if (window.__noSrcsetPatched) return; // avoid double-run
echo   window.__noSrcsetPatched = true;
echo
echo   const rxLocal = /https?:\/\/(?:localhost^|127\.0\.0\.1)(?::\d+)?\//i;
echo
echo   const sanitizeUrl = (u) => {
echo     try { return u.replace(rxLocal, '/'); } catch(e) { return u; }
echo   };
echo
echo   const cleanEl = (el) => {
echo     if (el.tagName === 'IMG' ^|^| el.tagName === 'SOURCE') {
echo       const s = el.getAttribute('src');
echo       if (s ^&^& rxLocal.test(s)) el.setAttribute('src', sanitizeUrl(s));
echo     }
echo     if (el.tagName === 'LINK') {
echo       if (el.rel === 'preload' ^&^& (el.as === 'image' ^|^| el.getAttribute('as') === 'image')) {
echo         const h = el.getAttribute('href');
echo         if (h ^&^& rxLocal.test(h)) el.setAttribute('href', sanitizeUrl(h));
echo       }
echo       const is = el.getAttribute('imagesrcset');
echo       if (is ^&^& rxLocal.test(is)) el.setAttribute('imagesrcset', sanitizeUrl(is));
echo     }
echo
echo     const ssAttr = el.getAttribute('srcset') ^|^| el.getAttribute('data-srcset');
echo     if (ssAttr) {
echo       const parts = ssAttr.split(',').map(p => {
echo         const [u, d] = p.trim().split(/\s+/, 2);
echo         return (sanitizeUrl(u) + (d ? (' ' + d) : ''));
echo       });
echo       el.setAttribute('srcset', parts.join(', '));
echo       el.removeAttribute('data-srcset');
echo     }
echo
echo     if (el.hasAttribute('srcset')) el.removeAttribute('srcset');
echo     if (el.hasAttribute('sizes')) el.removeAttribute('sizes');
echo     if (el.hasAttribute('data-sizes')) el.removeAttribute('data-sizes');
echo     if (el.hasAttribute('imagesrcset')) el.removeAttribute('imagesrcset');
echo
echo     if (el.tagName === 'IMG') {
echo       try {
echo         const current = el.currentSrc ^|^| el.src;
echo         if (current) el.src = current;
echo       } catch(e){}
echo     }
echo   };
echo
echo   const sweep = () => {
echo     document.querySelectorAll('img, source, link[imagesrcset], link[rel="preload"][as="image"]').forEach(cleanEl);
echo   };
echo
echo   const mo = new MutationObserver((muts) => {
echo     muts.forEach(m => {
echo       if (m.type === 'attributes') {
echo         const t = m.target;
echo         if (t ^&^& (t.tagName === 'IMG' ^|^| t.tagName === 'SOURCE' ^|^| t.tagName === 'LINK')) {
echo           cleanEl(t);
echo         }
echo       } else if (m.type === 'childList') {
echo         m.addedNodes.forEach(n => {
echo           if (n.nodeType === 1) {
echo             if (n.tagName === 'IMG' ^|^| n.tagName === 'SOURCE' ^|^| n.tagName === 'LINK') cleanEl(n);
echo             n.querySelectorAll ^&^& n.querySelectorAll('img, source, link[imagesrcset], link[rel="preload"][as="image"]').forEach(cleanEl);
echo           }
echo         });
echo       }
echo     });
echo   });
echo   mo.observe(document.documentElement, { attributes: true, attributeFilter: ['src','srcset','sizes','data-src','data-srcset','imagesrcset','href'], childList: true, subtree: true });
echo
echo   if (document.readyState === 'loading') {
echo     document.addEventListener('DOMContentLoaded', sweep, { once: true });
echo     window.addEventListener('load', sweep, { once: true });
echo   } else {
echo     sweep();
echo     window.addEventListener('load', sweep, { once: true });
echo   }
echo
echo   window.__noSrcsetActive = true;
echo })();
echo "@
echo Set-Content -LiteralPath $jsPath -Value $js -Encoding UTF8
echo ^# 3^) Inject ^<script^> tag before ^</head^> in all HTML files
echo $snippet = '^<script src="/assets/js/no-srcset.js"^>^</script^>'
echo $files = Get-ChildItem -Recurse -File -Include *.html
echo [int]$patched = 0
echo foreach ($f in $files) {
echo   $c = Get-Content -Raw -LiteralPath $f.FullName
echo   if ($c -notmatch [regex]::Escape($snippet)) {
echo     if ($c -match '^</head^>') {
echo       $c = $c -replace '^</head^>', "  $snippet`r`n</head>"
echo       Set-Content -NoNewline -LiteralPath $f.FullName -Value $c -Encoding UTF8
echo       $patched++
echo     } else {
echo       $c = $c -replace '</head>', "  $snippet`r`n</head>"
echo       Set-Content -NoNewline -LiteralPath $f.FullName -Value $c -Encoding UTF8
echo       $patched++
echo     }
echo   }
echo }
echo Write-Host "Injected script into $patched HTML file(s)."
echo Write-Host "`nDone. Commit & push your changes."
echo Read-Host "Press Enter to close"
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"
del "%PSFILE%" >nul 2>&1
endlocal
