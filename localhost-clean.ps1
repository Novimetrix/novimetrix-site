<#
  localhost-clean.ps1
  Safely rewrites any localhost/127.0.0.1 URLs to root-relative paths **only** in HTML/HTM/CSS.
  - Skips JS/SVG entirely to avoid breaking regex/icons.
  - Forces UTF-8 (no BOM) when saving to prevent garbled characters.
  - Writes a simple log: localhost-clean.log
#>

param(
  [string]$Path = "."
)

$root = Resolve-Path -LiteralPath $Path
$log  = Join-Path $root "localhost-clean.log"

# Start log
"=== localhost-clean.ps1 @ $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" | Out-File -FilePath $log -Encoding utf8

# Patterns to replace -> '/'
$patterns = @(
  @{ Name = "abs-http(s)-localhost"; Pattern = '(?i)https?:\/\/(?:localhost|127\.0\.0\.1)(?::\d+)?\/'; Replacement = '/' },
  @{ Name = "proto-relative-localhost"; Pattern = '(?i)\/\/(?:localhost|127\.0\.0\.1)(?::\d+)?\/'; Replacement = '/' },
  @{ Name = "urlencoded-http-localhost"; Pattern = '(?i)http%3A%2F%2F(?:localhost|127\.0\.0\.1)(?:%3A\d+)?%2F'; Replacement = '/' },
  @{ Name = "urlencoded-https-localhost"; Pattern = '(?i)https%3A%2F%2F(?:localhost|127\.0\.0\.1)(?:%3A\d+)?%2F'; Replacement = '/' }
)

# Only touch HTML/HTM/CSS
$targets = Get-ChildItem -Path $root -Recurse -File | Where-Object { $_.Extension -in '.html', '.htm', '.css' }

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

foreach ($f in $targets) {
  try {
    $bytes   = [System.IO.File]::ReadAllBytes($f.FullName)
    $text    = [System.Text.Encoding]::UTF8.GetString($bytes)

    $beforeLen = $text.Length
    $totalRepl = 0

    foreach ($p in $patterns) {
      $matches = [System.Text.RegularExpressions.Regex]::Matches($text, $p.Pattern).Count
      if ($matches -gt 0) {
        $text = [System.Text.RegularExpressions.Regex]::Replace($text, $p.Pattern, $p.Replacement)
        $totalRepl += $matches
      }
    }

    if ($totalRepl -gt 0) {
      # Save as UTF-8 without BOM
      [System.IO.File]::WriteAllText($f.FullName, $text, $utf8NoBom)
      "Changed: $($f.FullName) (replacements=$totalRepl)" | Out-File -FilePath $log -Append -Encoding utf8
    }
  }
  catch {
    "ERROR: $($f.FullName) -> $($_.Exception.Message)" | Out-File -FilePath $log -Append -Encoding utf8
  }
}

"Done. Files scanned: $($targets.Count)" | Out-File -FilePath $log -Append -Encoding utf8
