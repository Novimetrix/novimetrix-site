# FINAL-PATCH-ONECLICK.ps1 — all-in-one replacement (patch + clean + restore)
# v3: remove Elementor runtime/frontend JS (which dynamically tries to load localhost chunks),
#     plus any localhost <script>/<link> tags, plus previous fixes.
param([string]$Root='.')


$sw = [Diagnostics.Stopwatch]::StartNew()
$utf8 = New-Object System.Text.UTF8Encoding($false)

# Only text-like files (avoid images/fonts/SVG)
$include = @('*.html','*.htm','*.css','*.js','*.xml','*.json','*.txt','*.md')
$exclude = @('*.svg','*.png','*.jpg','*.jpeg','*.webp','*.gif','*.ico','*.woff','*.woff2','*.ttf','*.otf','*.eot','*.pdf','*.zip','*.gz','*.map')

$files = Get-ChildItem -Path $Root -Recurse -File -Include $include | Where-Object {
  $exclude -notcontains ('*' + $_.Extension.TrimStart('.').ToLower())
}

$ts=0; $tc=0; $lf=0; $sr=0; $err=0; $rmScriptLocal=0; $rmLinkLocal=0; $rmElementorSrc=0; $rmElementorInline=0; $rmLinkPreloadElem=0

# Regex patterns
$reLocal    = [regex]'(?i)https?://(?:localhost|127\.0\.0\.1)(?::\d+)?'
$reLocalENC = [regex]'(?i)https?%3A%2F%2F(?:localhost|127\.0\.0\.1)(?:%3A\d+)?'
$reSrcAttr  = [regex]'(?i)\s+(srcset|sizes|imagesrcset)=(".*?"|''.*?'')'

# Remove entire tags that point to localhost
$reScriptLocal = [regex]"(?is)<script[^>]+src\s*=\s*[""'][^""']*(?:localhost|127\.0\.0\.1)[^""']*[""'][^>]*>\s*</script\s*>"
$reLinkLocal   = [regex]"(?is)<link[^>]+href\s*=\s*[""'][^""']*(?:localhost|127\.0\.0\.1)[^""']*[""'][^>]*>"

# Remove Elementor runtime/frontend script tags regardless of domain
$reElementorSrc = [regex]"(?is)<script[^>]+src\s*=\s*[""'][^""']*/wp-content/plugins/elementor/assets/js/[^""']+[""'][^>]*>\s*</script\s*>"

# Remove inline Elementor initialization/runtime blocks that trigger chunk loading
$reElementorInline = [regex]"(?is)<script[^>]*>\s*([^<]*?(elementorFrontend|elementor\.modules|__webpack_require__)[^<]*?)+\s*</script\s*>"

# Remove link preloads that point to Elementor JS (rare but possible)
$reLinkPreloadElem = [regex]"(?is)<link[^>]+rel\s*=\s*[""']preload[""'][^>]+as\s*=\s*[""']script[""'][^>]+href\s*=\s*[""'][^""']*/wp-content/plugins/elementor/assets/js/[^""']+[""'][^>]*>"

foreach ($f in $files) {
  try {
    $ts++
    $orig = Get-Content -Raw -Encoding UTF8 -LiteralPath $f.FullName
    $new = $orig

    # counts before
    $cLocal = ($reLocal.Matches($new).Count) + ($reLocalENC.Matches($new).Count)
    $cSrcA  = $reSrcAttr.Matches($new).Count
    $cScrL  = $reScriptLocal.Matches($new).Count
    $cLnkL  = $reLinkLocal.Matches($new).Count
    $cElemS = $reElementorSrc.Matches($new).Count
    $cElemI = $reElementorInline.Matches($new).Count
    $cElemP = $reLinkPreloadElem.Matches($new).Count

    # replacements (order matters: strip whole tags first, then attributes/urls)
    if ($cScrL -gt 0) { $new = $reScriptLocal.Replace($new, '') }
    if ($cLnkL -gt 0) { $new = $reLinkLocal.Replace($new, '') }
    if ($cElemS -gt 0) { $new = $reElementorSrc.Replace($new, '') }
    if ($cElemI -gt 0) { $new = $reElementorInline.Replace($new, '') }
    if ($cElemP -gt 0) { $new = $reLinkPreloadElem.Replace($new, '') }

    # now clean remaining localhost urls + responsive attrs
    $new = $reLocal.Replace($new, '')
    $new = $reLocalENC.Replace($new, '')
    $new = $reSrcAttr.Replace($new, '')

    if ($new -ne $orig) {
      [IO.File]::WriteAllText($f.FullName, $new, $utf8)
      $tc++
      $lf += $cLocal
      $sr += $cSrcA
      $rmScriptLocal += $cScrL
      $rmLinkLocal   += $cLnkL
      $rmElementorSrc += $cElemS
      $rmElementorInline += $cElemI
      $rmLinkPreloadElem += $cElemP
    }
  } catch {
    $err++
  }
}

$sw.Stop()

$report = @(
  'FINAL-PATCH-ONECLICK finished. (v3)',
  ('Scanned files                   : {0}' -f $ts),
  ('Changed files                   : {0}' -f $tc),
  ('Localhost URL fixes             : {0}' -f $lf),
  ('srcset/sizes removed            : {0}' -f $sr),
  ('localhost <script> removed      : {0}' -f $rmScriptLocal),
  ('localhost <link> removed        : {0}' -f $rmLinkLocal),
  ('Elementor JS <script> removed   : {0}' -f $rmElementorSrc),
  ('Elementor inline <script> removed: {0}' -f $rmElementorInline),
  ('Elementor preload <link> removed: {0}' -f $rmLinkPreloadElem),
  ('Errors                          : {0}' -f $err),
  ('Elapsed                         : {0:n1}s' -f $sw.Elapsed.TotalSeconds)
)
$reportText = $report -join [Environment]::NewLine
$reportText | Write-Host

$logPath = Join-Path (Get-Location) 'FINAL-PATCH.log'
[IO.File]::WriteAllText($logPath, $reportText, $utf8)

Write-Host ''
Write-Host ('Report saved to: ' + $logPath)
