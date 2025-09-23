$ErrorActionPreference = 'Stop'

# Always log to a file in the working folder
$Log = Join-Path (Get-Location) 'localhost-clean.log'
try { "=== Run: $(Get-Date) ===" | Out-File -FilePath $Log -Append -Encoding UTF8 } catch {}

function Read-WithOriginalEncoding($Path) {
  $sr = New-Object System.IO.StreamReader($Path, [System.Text.Encoding]::Default, $true)
  try {
    $text = $sr.ReadToEnd()
    $enc  = $sr.CurrentEncoding
    [PSCustomObject]@{ Text=$text; Encoding=$enc }
  } finally {
    $sr.Close()
  }
}

function Write-WithEncoding($Path, $Text, $Encoding) {
  $sw = New-Object System.IO.StreamWriter($Path, $false, $Encoding)
  try { $sw.Write($Text) } finally { $sw.Close() }
}

$files = Get-ChildItem -Recurse -File -Include *.html,*.htm,*.js,*.css,*.json,*.xml,*.svg

foreach ($f in $files) {
  $r = Read-WithOriginalEncoding -Path $f.FullName
  $t = $r.Text
  $enc = $r.Encoding

  $isHtml = $f.Extension -in '.html','.htm'

  # Remove HTTrack header comment (HTML only)
  if ($isHtml) {
    $t = [Regex]::Replace($t, '(?is)<!--\s*Mirrored from .*?-->', '')
    # Remove inline emoji settings blocks if present
    $t = [Regex]::Replace($t, '(?is)<script[^>]*>.*?(wp-emoji-release|_wpemojiSettings).*?</script>', '')
  }

  # Localhost cleanups (escaped, percent-encoded, plain, protocol-relative)
  $t = $t -replace 'https?:\\/\\/(localhost|127\.0\.0\.1)(?::\d+)?\/', '/'
  $t = $t -replace 'https?%3A%2F%2F(localhost|127%2E0%2E0%2E1)(?:%3A\d+)?%2F', '/'
  $t = $t -replace 'https?:\/\/(localhost|127\.0\.0\.1)(?::\d+)?\/', '/'
  $t = $t -replace '\/\/(localhost|127\.0\.0\.1)(?::\d+)?\/', '/'
  $t = $t -replace 'https?:\\\/\\\/(localhost|127\.0\.0\.1)(?::\d+)?', ''

  # Normalize escaped slashes
  $t = $t -replace '\\\/', '/'

  Write-WithEncoding -Path $f.FullName -Text $t -Encoding $enc
}

# Reports
$leftA = Get-ChildItem -Recurse -File -Include *.html,*.htm,*.js,*.css,*.json,*.xml,*.svg | Select-String -SimpleMatch 'http:\/\/localhost'
$leftB = Get-ChildItem -Recurse -File -Include *.html,*.htm,*.js,*.css,*.json,*.xml,*.svg | Select-String -SimpleMatch 'wp-emoji-release'
$leftC = Get-ChildItem -Recurse -File -Include *.html,*.htm,*.js,*.css,*.json,*.xml,*.svg | Select-String -SimpleMatch 'localhost'

if ($leftA -or $leftB -or $leftC) {
  if ($leftA) { 'LEFTOVERS (http:\/\/localhost):' | Tee-Object -FilePath $Log -Append | Write-Host -ForegroundColor Yellow; $leftA | ForEach-Object { ("  {0}: {1}" -f $_.Path, $_.Line.Trim()) | Tee-Object -FilePath $Log -Append | Write-Host } }
  if ($leftB) { 'LEFTOVERS (wp-emoji-release):' | Tee-Object -FilePath $Log -Append | Write-Host -ForegroundColor Yellow; $leftB | ForEach-Object { ("  {0}: {1}" -f $_.Path, $_.Line.Trim()) | Tee-Object -FilePath $Log -Append | Write-Host } }
  if ($leftC) { 'LEFTOVERS (localhost):' | Tee-Object -FilePath $Log -Append | Write-Host -ForegroundColor Yellow; $leftC | ForEach-Object { ("  {0}: {1}" -f $_.Path, $_.Line.Trim()) | Tee-Object -FilePath $Log -Append | Write-Host } }
} else {
  'All clean.' | Tee-Object -FilePath $Log -Append | Write-Host -ForegroundColor Green
}

# Keep window open if user ran the .ps1 directly
if ($Host.Name -notmatch 'ConsoleHost') { } else { Read-Host 'Press Enter to close' | Out-Null }
