# publish-article.ps1  (No Lost AI site)
# JOB: safely take a finished article from articles\pending\ to LIVE.
#   1. Checks the article (title, description, canonical URL, schema, trial link, no junk).
#   2. ONLY with -Go: moves it to articles\, adds it to the articles index + sitemap,
#      commits, and pushes to GitHub. Netlify then deploys it automatically (~1 min).
#
# CHECK ONLY: .\tools\publish-article.ps1 -Slug my-article -Blurb "One sentence summary."
# GO LIVE   : .\tools\publish-article.ps1 -Slug my-article -Blurb "One sentence summary." -Go
#   (Slug = the file name without .html)

param(
  [Parameter(Mandatory=$true)][string]$Slug,
  [Parameter(Mandatory=$true)][string]$Blurb,
  [switch]$Go
)
$ErrorActionPreference = 'Stop'
$utf8   = New-Object System.Text.UTF8Encoding($false)
$site   = (Resolve-Path (Join-Path $PSScriptRoot '..\nolostai-site')).Path
$base   = 'https://trial.makkoguy.com'
$pending = Join-Path $site "articles\pending\$Slug.html"
$final   = Join-Path $site "articles\$Slug.html"
$indexF  = Join-Path $site 'articles\index.html'
$mapF    = Join-Path $site 'sitemap.xml'

function RunGit {
  # Runs git inside the site folder; stops the script if git reports an error.
  $old = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
  $out = & git.exe -C $site @args 2>&1 | ForEach-Object { "$_" }
  $code = $LASTEXITCODE; $ErrorActionPreference = $old
  $out | ForEach-Object { Write-Host "   $_" }
  if ($code -ne 0) { throw "git $($args -join ' ') failed (exit $code)" }
}

# ---- Basic safety ----
if ($Slug -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') { throw 'Slug must be lowercase letters, numbers and dashes only.' }
if (-not (Test-Path $pending)) { throw "Not found: $pending" }
if (Test-Path $final) { throw "Already published: $final" }
if ($Blurb.Length -lt 20 -or $Blurb.Length -gt 220) { throw 'Blurb should be one sentence, 20-220 characters.' }

# ---- Quality + security checks ----
$html = [IO.File]::ReadAllText($pending, $utf8)
$problems = @()
if (-not $html.Contains("rel=`"canonical`" href=`"$base/articles/$Slug.html`"")) { $problems += "Canonical URL must be $base/articles/$Slug.html" }
if ($html -notmatch '<title>.{10,}</title>') { $problems += 'Missing <title>' }
if ($html -notmatch 'name="description" content="[^"]{50,170}"') { $problems += 'Meta description missing or not 50-170 characters' }
if ($html -notmatch '<h1>.+?</h1>') { $problems += 'Missing <h1>' }
if (-not $html.Contains('href="/#trial"')) { $problems += 'No link to the 14-day trial (/#trial)' }
if ($html -match '(?i)TODO|lorem ipsum|\[INSERT|PLACEHOLDER') { $problems += 'Contains placeholder text' }
if ($html -match '(?i)<script[^>]+src=') { $problems += 'External scripts are not allowed (zero-trust rule)' }
if ($html -match '(?i)href="http://') { $problems += 'Insecure http:// link found' }
$ld = [regex]::Matches($html, '<script type="application/ld\+json">(.*?)</script>', 'Singleline')
if ($ld.Count -lt 1) { $problems += 'Missing JSON-LD FAQ schema' }
foreach ($m in $ld) { try { $null = $m.Groups[1].Value | ConvertFrom-Json } catch { $problems += 'JSON-LD schema is not valid JSON' } }
$idx = [IO.File]::ReadAllText($indexF, $utf8)
$map = [IO.File]::ReadAllText($mapF, $utf8)
if ($idx.Contains("/articles/$Slug.html")) { $problems += 'Already listed in articles index' }
if ($map.Contains("/articles/$Slug.html")) { $problems += 'Already listed in sitemap' }

if ($problems.Count -gt 0) {
  Write-Host 'CHECKS FAILED:' -ForegroundColor Red
  $problems | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
  exit 1
}
Write-Host "Checks passed for $Slug." -ForegroundColor Green
if (-not $Go) { Write-Host 'Nothing changed. Add -Go to publish it live.'; exit 0 }

# ---- Go live ----
$branch = (& git.exe -C $site rev-parse --abbrev-ref HEAD).Trim()
if ($branch -ne 'main') { throw "You are on branch '$branch'. Switch to main first." }
Write-Host 'Syncing with GitHub...'; RunGit pull --ff-only

$h1 = [regex]::Match($html, '<h1>(.*?)</h1>').Groups[1].Value
$blurbSafe = [System.Net.WebUtility]::HtmlEncode($Blurb)
$nl = if ($idx.Contains("`r`n")) { "`r`n" } else { "`n" }

$li = "<li><a href=`"/articles/$Slug.html`">$h1</a><p>$blurbSafe</p></li>$nl"
$i = $idx.LastIndexOf('</ul>'); if ($i -lt 0) { throw 'Could not find </ul> in articles index.' }
[IO.File]::WriteAllText($indexF, $idx.Insert($i, $li), $utf8)

$entry = "  <url><loc>$base/articles/$Slug.html</loc></url>$nl"
$j = $map.LastIndexOf('</urlset>'); if ($j -lt 0) { throw 'Could not find </urlset> in sitemap.' }
[IO.File]::WriteAllText($mapF, $map.Insert($j, $entry), $utf8)

Move-Item $pending $final

Write-Host 'Committing + pushing...'
RunGit add -- "articles/$Slug.html" articles/index.html sitemap.xml
RunGit commit -m "Publish article: $Slug"
RunGit push origin main
Write-Host "LIVE in about a minute: $base/articles/$Slug.html" -ForegroundColor Green
