# FINAL-PATCH-ONECLICK (ULTRA SAFE) — v6
# Keeps: localhost scrub, remove srcset/sizes, emoji cleanup, UTF-8 (no BOM).
# Does NOT remove any Elementor JS. Also injects a CSS visibility guard into HTML.
param([string]$Root='.')

$sw = [Diagnostics.Stopwatch]::StartNew()
$utf8 = New-Object System.Text.UTF8Encoding($false)

$include = @('*.html','*.htm','*.css','*.js','*.xml','*.json','*.txt','*.md')
$exclude = @('*.svg','*.png','*.jpg','*.jpeg','*.webp','*.gif','*.woff','*.woff2','*.ttf','*.otf','*.eot','*.pdf','*.zip','*.gz','*.map')

$ts=0; $tc=0; $lf=0; $sr=0; $err=0; $guard=0
$rmScriptLocal=0; $rmLinkLocal=0
$rmEmojiSrc=0; $rmEmojiInline=0

# Base fixes
$reLocal    = [regex]'(?i)https?://(?:localhost|127\.0\.0\.1)(?::\d+)?'
$reLocalENC = [regex]'(?i)https?%3A%2F%2F(?:localhost|127\.0\.0\.1)(?:%3A\d+)?'
$reSrcAttr  = [regex]'(?i)\s+(srcset|sizes|imagesrcset)=(".*?"|''.*?'')'

# Remove tags hitting localhost
$reScriptLocal = [regex]"(?is)<script[^>]+src\s*=\s*[""'][^""']*(?:localhost|127\.0\.0\.1)[^""']*[""'][^>]*>\s*</script\s*>"
$reLinkLocal   = [regex]"(?is)<link[^>]+href\s*=\s*[""'][^""']*(?:localhost|127\.0\.0\.1)[^""']*[""'][^>]*>"

# Emoji script & inline settings
$reEmojiSrc    = [regex]"(?is)<script\b[^>]*\bsrc\s*=\s*[""'][^""']*/wp-includes/js/wp-emoji-release\.min\.js[^""']*[""'][^>]*>\s*</script\s*>"
$reEmojiInline = [regex]"(?is)<script\b[^>]*>\s*[^<]*(wp-emoji|twemoji|emojiSettings)[\s\S]*?</script\s*>"

# CSS guard (ensures images render even if JS is blocked)
$cssGuard = '<style id="nm-image-visibility-guard">.elementor-widget-image img,img.wp-image{opacity:1!important;visibility:visible!important}</style>'
$reHeadClose = [regex]'(?is)</head>'

$files = Get-ChildItem -Path $Root -Recurse -File -Include $include | Where-Object {
  $exclude -notcontains ('*' + $_.Extension.TrimStart('.').ToLower())
}

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
    $cEmoS  = $reEmojiSrc.Matches($new).Count
    $cEmoI  = $reEmojiInline.Matches($new).Count

    # strip whole tags first (localhost + emoji only)
    if ($cScrL -gt 0) { $new = $reScriptLocal.Replace($new, '') }
    if ($cLnkL -gt 0) { $new = $reLinkLocal.Replace($new, '') }
    if ($cEmoS  -gt 0) { $new = $reEmojiSrc.Replace($new, '') }
    if ($cEmoI  -gt 0) { $new = $reEmojiInline.Replace($new, '') }

    # then clean localhost urls + responsive attrs
    $new = $reLocal.Replace($new, '')
    $new = $reLocalENC.Replace($new, '')
    $new = $reSrcAttr.Replace($new, '')

    # Inject CSS guard into HTML once
    if ($f.Extension -match '^\.(html|htm)$') {
      if ($new -notmatch 'nm-image-visibility-guard') {
        $new = $reHeadClose.Replace($new, $cssGuard + '</head>', 1)
        if ($new -ne $orig) { $guard++ }
      }
    }

    if ($new -ne $orig) {
      [IO.File]::WriteAllText($f.FullName, $new, $utf8)
      $tc++
      $lf += $cLocal
      $sr += $cSrcA
      $rmScriptLocal += $cScrL
      $rmLinkLocal   += $cLnkL
      $rmEmojiSrc += $cEmoS
      $rmEmojiInline += $cEmoI
    }
  } catch {
    $err++
  }
}

$sw.Stop()

$report = @(
  'FINAL-PATCH-ONECLICK finished. (ULTRA SAFE v6)',
  ('Scanned files                         : {0}' -f $ts),
  ('Changed files                         : {0}' -f $tc),
  ('Localhost URL fixes                   : {0}' -f $lf),
  ('srcset/sizes removed                  : {0}' -f $sr),
  ('localhost <script> removed            : {0}' -f $rmScriptLocal),
  ('localhost <link> removed              : {0}' -f $rmLinkLocal),
  ('wp-emoji-release <script> removed     : {0}' -f $rmEmojiSrc),
  ('wp-emoji inline settings removed      : {0}' -f $rmEmojiInline),
  ('CSS guard injected into HTML          : {0}' -f $guard),
  ('Errors                                : {0}' -f $err),
  ('Elapsed                               : {0:n1}s' -f $sw.Elapsed.TotalSeconds)
)
$reportText = $report -join [Environment]::NewLine
$reportText | Write-Host

$logPath = Join-Path (Get-Location) 'FINAL-PATCH.log'
[IO.File]::WriteAllText($logPath, $reportText, $utf8)

Write-Host ''
Write-Host ('Report saved to: ' + $logPath)
