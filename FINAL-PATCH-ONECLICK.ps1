# FINAL-PATCH-ONECLICK.ps1 — all-in-one replacement (patch + clean + restore)
param([string]$Root='.')


$sw = [Diagnostics.Stopwatch]::StartNew()
$utf8 = New-Object System.Text.UTF8Encoding($false)

# Only text-like files (avoid images/fonts/SVG)
$include = @('*.html','*.htm','*.css','*.js','*.xml','*.json','*.txt','*.md')
$exclude = @('*.svg','*.png','*.jpg','*.jpeg','*.webp','*.gif','*.ico','*.woff','*.woff2','*.ttf','*.otf','*.eot','*.pdf','*.zip','*.gz','*.map')

$files = Get-ChildItem -Path $Root -Recurse -File -Include $include | Where-Object {
  $exclude -notcontains ('*' + $_.Extension.TrimStart('.').ToLower())
}

$ts=0; $tc=0; $lf=0; $sr=0; $err=0

# Regex patterns
$reLocal    = [regex]'(?i)https?://(?:localhost|127\.0\.0\.1)(?::\d+)?'
$reLocalENC = [regex]'(?i)https?%3A%2F%2F(?:localhost|127\.0\.0\.1)(?:%3A\d+)?'
$reSrc      = [regex]'(?i)\s+(srcset|sizes|imagesrcset)=(".*?"|''.*?'')'

foreach ($f in $files) {
  try {
    $ts++
    $orig = Get-Content -Raw -Encoding UTF8 -LiteralPath $f.FullName
    $cL = ($reLocal.Matches($orig).Count) + ($reLocalENC.Matches($orig).Count)
    $cS = $reSrc.Matches($orig).Count

    $new = $orig
    $new = $reLocal.Replace($new, '')
    $new = $reLocalENC.Replace($new, '')
    $new = $reSrc.Replace($new, '')

    if ($new -ne $orig) {
      [IO.File]::WriteAllText($f.FullName, $new, $utf8)
      $tc++
      $lf += $cL
      $sr += $cS
    }
  } catch {
    $err++
  }
}

$sw.Stop()

$report = @(
  'FINAL-PATCH-ONECLICK finished.',
  ('Scanned files       : {0}' -f $ts),
  ('Changed files       : {0}' -f $tc),
  ('Localhost fixes     : {0}' -f $lf),
  ('srcset/sizes removed: {0}' -f $sr),
  ('Errors              : {0}' -f $err),
  ('Elapsed             : {0:n1}s' -f $sw.Elapsed.TotalSeconds)
)
$reportText = $report -join [Environment]::NewLine
$reportText | Write-Host

$logPath = Join-Path (Get-Location) 'FINAL-PATCH.log'
[IO.File]::WriteAllText($logPath, $reportText, $utf8)

Write-Host ''
Write-Host ('Report saved to: ' + $logPath)
