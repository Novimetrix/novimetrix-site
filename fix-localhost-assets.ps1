# fix-localhost-assets.ps1
# Usage: Place this file in your HTTrack export ROOT (same folder as index.html),
# then right‑click → "Run with PowerShell". It rewrites only asset URLs under
# /wp-content and /wp-includes that still point at localhost/127.0.0.1.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "Working in $root"

# 1) Find text files to rewrite
$files = Get-ChildItem -Path $root -Recurse -Include *.html,*.css,*.js,*.json

# 2) Patterns (safe & targeted)
$patterns = @(
  @{ find = 'https?:\/\/(?:localhost|127\.0\.0\.1)(?::\d+)?\/(wp-content|wp-includes)\/'; replace = '/$1/' },
  @{ find = '\/\/(?:localhost|127\.0\.0\.1)(?::\d+)?\/(wp-content|wp-includes)\/';         replace = '/$1/' },
  @{ find = 'https?:\\\/\\\/(?:localhost|127\.0\.0\.1)(?::\d+)?\\\/(wp-content|wp-includes)\\\/'; replace = '/$1/' },
  @{ find = 'https?%3A%2F%2F(?:localhost|127\.0\.0\.1)(?:%3A\d+)?%2F(wp-content|wp-includes)%2F'; replace = '/$1/' }
)

# 3) Rewrite in-place
foreach ($f in $files) {
  $c = Get-Content -Raw -LiteralPath $f.FullName
  foreach ($p in $patterns) {
    $c = [System.Text.RegularExpressions.Regex]::Replace($c, $p.find, $p.replace)
  }
  Set-Content -NoNewline -LiteralPath $f.FullName -Value $c
}

# 4) Report leftovers
$left = Select-String -Path $files.FullName -Pattern 'localhost|127\.0\.0\.1' -SimpleMatch
Write-Host "Leftover 'localhost/127.0.0.1' matches:" $left.Count
if ($left.Count -gt 0) {
  Write-Host "Tip: open one of the files above and search for 'localhost' to see the context."
} else {
  Write-Host "All clean ✅"
}
