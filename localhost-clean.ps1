$ErrorActionPreference = 'Stop'

# Begin transcript to a log file in the current directory
try {
  $logPath = Join-Path (Get-Location) "localhost-clean.log"
  Start-Transcript -Path $logPath -Append -ErrorAction SilentlyContinue | Out-Null
} catch {}


# Scan common exported file types
$files = Get-ChildItem -Recurse -File -Include *.html,*.htm,*.js,*.css,*.json,*.xml,*.svg

foreach ($f in $files) {
  $t = Get-Content $f -Raw
# Remove HTTrack "Mirrored from ..." HTML comment in .html/.htm
if ($f.Extension -in '.html','.htm') {
  $t = [Regex]::Replace($t, '(?is)<!--\s*Mirrored from .*?-->', '')
}


  # Escaped: http:\/\/localhost or 127.0.0.1 (optional port)
  $t = $t -replace 'https?:\\/\\/(localhost|127\.0\.0\.1)(?::\d+)?\/', '/'

  # Percent-encoded: http%3A%2F%2Flocalhost...
  $t = $t -replace 'https?%3A%2F%2F(localhost|127%2E0%2E0%2E1)(?:%3A\d+)?%2F', '/'

  # Plain: http://localhost...
  $t = $t -replace 'https?:\/\/(localhost|127\.0\.0\.1)(?::\d+)?\/', '/'

  # Protocol-relative: //localhost...
  $t = $t -replace '\/\/(localhost|127\.0\.0\.1)(?::\d+)?\/', '/'

  # Blunt strip for http(s):\/\/localhost prefix
  $t = $t -replace 'https?:\\\/\\\/(localhost|127\.0\.0\.1)(?::\d+)?', ''

  # Normalize escaped slashes in JSON strings
  $t = $t -replace '\\\/', '/'

  [IO.File]::WriteAllText($f.FullName, $t, [Text.UTF8Encoding]::new($false))
}

# Report leftovers
$left = Get-ChildItem -Recurse -File -Include *.html,*.htm,*.js,*.css,*.json,*.xml,*.svg |
        Select-String -SimpleMatch 'localhost'

if ($left) {
  Write-Host 'LEFTOVERS:' -ForegroundColor Yellow; Write-Output 'LEFTOVERS:'
  $left | ForEach-Object { Write-Host ("  {0}: {1}" -f $_.Path, $_.Line.Trim()) }
} else {
  Write-Host 'All clean.' -ForegroundColor Green; Write-Output 'All clean.'
}


# Stop transcript if it started
try { Stop-Transcript | Out-Null } catch {}

