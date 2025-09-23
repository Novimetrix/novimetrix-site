$ErrorActionPreference = 'Stop'

# Start a transcript so there's always a saved report
try {
  $logPath = Join-Path (Get-Location) "localhost-clean.log"
  Start-Transcript -Path $logPath -Append -ErrorAction SilentlyContinue | Out-Null
} catch {}

# Helper encodings
$Utf8Bom    = New-Object System.Text.UTF8Encoding($true)
$Utf8NoBom  = New-Object System.Text.UTF8Encoding($false)

# File set
$files = Get-ChildItem -Recurse -File -Include *.html,*.htm,*.js,*.css,*.json,*.xml,*.svg

foreach ($f in $files) {
  $t = Get-Content -LiteralPath $f.FullName -Raw

  # Remove HTTrack "Mirrored from ..." comments (HTML only)
  if ($f.Extension -in '.html','.htm') {
    $patHT = @'
(?is)<!--\s*Mirrored from .*?-->
'@
    $t = [Regex]::Replace($t, $patHT, '')
  }

  # Remove inline emoji script blocks
  if ($f.Extension -in '.html','.htm') {
    $patEmoji = @'
(?is)<script[^>]*>.*?(wp-emoji-release|_wpemojiSettings).*?</script>
'@
    $t = [Regex]::Replace($t, $patEmoji, '')
  }

  # Normalize <meta charset> to UTF-8 (HTML only)
  if ($f.Extension -in '.html','.htm') {
    $patMeta1 = @'
(?is)<meta[^>]+charset\s*=\s*["'][^"']+["'][^>]*>
'@
    $t = [Regex]::Replace($t, $patMeta1, '<meta charset="utf-8">')

    $patMeta2 = @'
(?is)<meta[^>]+http-equiv\s*=\s*["']content-type["'][^>]*>
'@
    $t = [Regex]::Replace($t, $patMeta2, '<meta charset="utf-8">')

    if ($t -notmatch '(?is)<meta[^>]+charset\s*=\s*["'']?utf-?8["'']?') {
      $t = [Regex]::Replace($t, '(?is)<head([^>]*)>', '<head$1><meta charset="utf-8">', 1)
    }
  }

  # Localhost cleanups (escaped, encoded, plain, protocol-relative, over-escaped)
  $t = $t -replace 'https?:\\/\\/(localhost|127\.0\.0\.1)(?::\d+)?\/', '/'
  $t = $t -replace 'https?%3A%2F%2F(localhost|127%2E0%2E0%2E1)(?:%3A\d+)?%2F', '/'
  $t = $t -replace 'https?:\/\/(localhost|127\.0\.0\.1)(?::\d+)?\/', '/'
  $t = $t -replace '\/\/(localhost|127\.0\.0\.1)(?::\d+)?\/', '/'
  $t = $t -replace 'https?:\\\/\\\/(localhost|127\.0\.0\.1)(?::\d+)?', ''

  # Normalize escaped slashes inside JSON strings
  $t = $t -replace '\\\/', '/'

  # Save with correct encoding (HTML with BOM, others without)
  if ($f.Extension -in '.html','.htm') {
    [IO.File]::WriteAllText($f.FullName, $t, $Utf8Bom)
  } else {
    [IO.File]::WriteAllText($f.FullName, $t, $Utf8NoBom)
  }
}

# Post-run reports
$leftA = Get-ChildItem -Recurse -File -Include *.html,*.htm,*.js,*.css,*.json,*.xml,*.svg | Select-String -SimpleMatch 'http:\/\/localhost'
$leftB = Get-ChildItem -Recurse -File -Include *.html,*.htm,*.js,*.css,*.json,*.xml,*.svg | Select-String -SimpleMatch 'wp-emoji-release'
$leftC = Get-ChildItem -Recurse -File -Include *.html,*.htm,*.js,*.css,*.json,*.xml,*.svg | Select-String -SimpleMatch 'localhost'

if ($leftA -or $leftB -or $leftC) {
  if ($leftA) { Write-Host 'LEFTOVERS (http:\/\/localhost):' -ForegroundColor Yellow; $leftA | ForEach-Object { Write-Host ("  {0}: {1}" -f $_.Path, $_.Line.Trim()) } }
  if ($leftB) { Write-Host 'LEFTOVERS (wp-emoji-release):' -ForegroundColor Yellow; $leftB | ForEach-Object { Write-Host ("  {0}: {1}" -f $_.Path, $_.Line.Trim()) } }
  if ($leftC) { Write-Host 'LEFTOVERS (localhost):' -ForegroundColor Yellow; $leftC | ForEach-Object { Write-Host ("  {0}: {1}" -f $_.Path, $_.Line.Trim()) } }
} else {
  Write-Host 'All clean.' -ForegroundColor Green
  Write-Output 'All clean.'
}

try { Stop-Transcript | Out-Null } catch {}
