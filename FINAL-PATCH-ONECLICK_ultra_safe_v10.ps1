# FINAL-PATCH-ONECLICK (ULTRA SAFE) — v10
# Keeps: localhost scrub, remove srcset/sizes, emoji cleanup, UTF-8 (no BOM).
# Does NOT remove any Elementor JS.
# Injects CSS visibility guards and tablet-only fixes for iphone.webp.
# Removes *tablet-only* hide classes in files that reference iphone.webp.
param([string]$Root='.')

$sw = [Diagnostics.Stopwatch]::StartNew()
$utf8 = New-Object System.Text.UTF8Encoding($false)

$include = @('*.html','*.htm','*.css','*.js','*.xml','*.json','*.txt','*.md')
$exclude = @('*.svg','*.png','*.jpg','*.jpeg','*.webp','*.gif','*.woff','*.woff2','*.ttf','*.otf','*.eot','*.pdf','*.zip','*.gz','*.map')

$ts=0; $tc=0; $lf=0; $sr=0; $err=0; $guard=0; $norm=0; $casefix=0; $iphoneFix=0; $tabletUnhide=0
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

# CSS guard (images visible) + TABLET-only iphone.webp fixes
$cssGuard = @'
<style id="nm-image-visibility-guard">
.elementor-widget-image img, img.wp-image{opacity:1!important;visibility:visible!important}
@media (min-width:768px) and (max-width:1024.98px){
  /* Ensure iphone.webp always paints on tablet */
  img[src*="iphone.webp"]{display:block!important;opacity:1!important;visibility:visible!important;max-width:100%!important;height:auto!important}
  /* If any link wraps iphone.webp, disable on tablet to avoid accidental redirect */
  a:has(img[src*="iphone.webp"]){pointer-events:none!important}
  /* Make sure the immediate containers render on tablet */
  .elementor-column:has(img[src*="iphone.webp"]),
  .elementor-container:has(img[src*="iphone.webp"]),
  .e-con:has(img[src*="iphone.webp"]){
    display:block!important;opacity:1!important;visibility:visible!important;min-height:560px!important
  }
}
</style>
'@
$reHeadClose = [regex]'(?is)</head>'

# Normalize ANY absolute host to root-relative when path is /wp-content/...
$reAbsToRoot = [regex]'(?i)https?://[^""'']+(/wp-content/[^""'')\s>]+)'
$reAbsToRootENC = [regex]'(?i)https?%3A%2F%2F[^&]+(%2Fwp-content%2F[^&""'']+)'
$reCssUrlAbs = [regex]'(?is)url\((["'']?)https?://[^)]+(/wp-content/[^)]+)\1\)'

# Find all /wp-content/uploads paths in a file
$reUploadsPath = [regex]'(?i)(/wp-content/uploads/[^""''\s\)]+)'

# Targeted iphone.webp <img> tag matcher (adds explicit attributes/styles)
$reIphoneImg = [regex]'(?is)<img\b([^>]*?)\bsrc\s*=\s*["''][^"''>]*iphone\.webp["'']([^>]*)>'

# Classes that hide on tablet (remove only in files that reference iphone.webp)
$tabletHideClasses = @('elementor-hidden-tablet','e-hide-tablet')

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
    $cIph   = $reIphoneImg.Matches($new).Count

    # strip whole tags first (localhost + emoji only)
    if ($cScrL -gt 0) { $new = $reScriptLocal.Replace($new, '') }
    if ($cLnkL -gt 0) { $new = $reLinkLocal.Replace($new, '') }
    if ($cEmoS  -gt 0) { $new = $reEmojiSrc.Replace($new, '') }
    if ($cEmoI  -gt 0) { $new = $reEmojiInline.Replace($new, '') }

    # then clean localhost urls + responsive attrs
    $new = $reLocal.Replace($new, '')
    $new = $reLocalENC.Replace($new, '')
    $new = $reSrcAttr.Replace($new, '')

    # normalize absolute dev/live hosts to root-relative
    $pre = $new
    $new = $reAbsToRoot.Replace($new, '$1')
    $new = $reAbsToRootENC.Replace($new, '$1')
    $new = $reCssUrlAbs.Replace($new, 'url($1$2)')
    if ($new -ne $pre) { $norm++ }

    # Inject CSS guard into HTML once
    if ($f.Extension -match '^\.(html|htm)$') {
      if ($new -notmatch 'nm-image-visibility-guard') {
        $new = $reHeadClose.Replace($new, $cssGuard + '</head>', 1)
        if ($new -ne $orig) { $guard++ }
      }
    }

    # Case-fix: ensure the case in URLs matches actual disk filenames (important for Linux hosting)
    # Only for /wp-content/uploads
    $matches = $reUploadsPath.Matches($new)
    if ($matches.Count -gt 0) {
      $unique = @{}  # dictionary of unique paths
      foreach ($m in $matches) {
        $unique[$m.Groups[1].Value] = $true
      }
      foreach ($relPath in $unique.Keys) {
        $diskPath = Join-Path $Root ($relPath.TrimStart('/').Replace('/', [IO.Path]::DirectorySeparatorChar))
        $dir = Split-Path $diskPath -Parent
        $name = Split-Path $diskPath -Leaf
        if (Test-Path -LiteralPath $dir) {
          $items = Get-ChildItem -LiteralPath $dir -File -ErrorAction SilentlyContinue
          $hit = $items | Where-Object { $_.Name -ieq $name } | Select-Object -First 1
          if ($null -ne $hit) {
            if ($hit.Name -cne $name) {
              $fileNamePattern = [Regex]::Escape($name)
              $new = [Regex]::Replace($new, "(?i)(/wp-content/uploads/[^""'\s\)*/\\\]+/)$fileNamePattern", ('$1' + [Regex]::Escape($hit.Name)))
              $casefix++
            }
          }
        }
      }
    }

    # Targeted iphone.webp fix: add explicit attributes to its <img>
    if ($cIph -gt 0) {
      $before = $new
      $new = $reIphoneImg.Replace($new, { param($m)
          $pre = $m.Groups[1].Value
          $post = $m.Groups[2].Value
          # Merge/ensure styles
          $styleInject = 'display:block;max-width:100%;height:auto;opacity:1;visibility:visible'
          if ($pre -notmatch '(?i)\bstyle\s*=' -and $post -notmatch '(?i)\bstyle\s*=') {
            $post = $post + ' style="' + $styleInject + '"'
          } else {
            $pre = [Regex]::Replace($pre, '(?is)\bstyle\s*=\s*["'']([^"'']*)["'']', { param($s) ' style="' + $s.Groups[1].Value + '; ' + $styleInject + '"'})
            $post = [Regex]::Replace($post, '(?is)\bstyle\s*=\s*["'']([^"'']*)["'']', { param($s) ' style="' + $s.Groups[1].Value + '; ' + $styleInject + '"'})
          }
          # Force eager load
          if ($pre -notmatch '(?i)\bloading\s*=' -and $post -notmatch '(?i)\bloading\s*=') {
            $post = $post + ' loading="eager"'
          }
          # Ensure decoding is not "async"
          $pre = [Regex]::Replace($pre, '(?is)\bdecoding\s*=\s*["'']async["'']', ' decoding="auto"')
          $post = [Regex]::Replace($post, '(?is)\bdecoding\s*=\s*["'']async["'']', ' decoding="auto"')
          return '<img' + $pre + ' src="iphone.webp"' + $post + '>'
        })
      if ($new -ne $before) { $iphoneFix++ }

      # Remove tablet-hide classes only in this file (safe, scoped)
      foreach ($cls in $tabletHideClasses) {
        $before2 = $new
        # remove class tokens while preserving other classes (handles quotes and whitespace)
        $new = [Regex]::Replace($new, '(?i)\b' + [Regex]::Escape($cls) + '\b', '')
        if ($new -ne $before2) { $tabletUnhide++ }
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
  'FINAL-PATCH-ONECLICK finished. (ULTRA SAFE v10)',
  ('Scanned files                         : {0}' -f $ts),
  ('Changed files                         : {0}' -f $tc),
  ('Localhost URL fixes                   : {0}' -f $lf),
  ('srcset/sizes removed                  : {0}' -f $sr),
  ('localhost <script> removed            : {0}' -f $rmScriptLocal),
  ('localhost <link> removed              : {0}' -f $rmLinkLocal),
  ('wp-emoji-release <script> removed     : {0}' -f $rmEmojiSrc),
  ('wp-emoji inline settings removed      : {0}' -f $rmEmojiInline),
  ('CSS guard injected into HTML          : {0}' -f $guard),
  ('Absolute host -> root-relative        : {0}' -f $norm),
  ('Case-fixed /wp-content/uploads names  : {0}' -f $casefix),
  ('iphone.webp explicit attributes added : {0}' -f $iphoneFix),
  ('Tablet-only hide classes removed      : {0}' -f $tabletUnhide),
  ('Errors                                : {0}' -f $err),
  ('Elapsed                               : {0:n1}s' -f $sw.Elapsed.TotalSeconds)
)
$reportText = $report -join [Environment]::NewLine
$reportText | Write-Host

$logPath = Join-Path (Get-Location) 'FINAL-PATCH.log'
[IO.File]::WriteAllText($logPath, $reportText, $utf8)

Write-Host ''
Write-Host ('Report saved to: ' + $logPath)
