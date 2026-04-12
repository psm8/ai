<#
Install Skills with Glob Matching
Wraps `npx skills add` to support wildcard patterns for --skill.
Usage:
  .\install-skills-glob.ps1 -RepoUrl "ssh://git@gitlab.xxx.com:7999/fwk/ai-tools.git" -Skill "core-*" -Adapter codex
  .\install-skills-glob.ps1 -RepoUrl "..." -Skill "core-*","citools-*" -Adapter codex -DryRun
#>
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$RepoUrl,

    [Parameter(Mandatory)]
    [Alias('s')]
    [string[]]$Skill,

    [Alias('a')]
    [string[]]$Adapter = @(),

    [Alias('y')]
    [switch]$Yes,

    [Alias('g')]
    [switch]$Global,

    [switch]$DryRun,

    [Parameter(ValueFromRemainingArguments)]
    [string[]]$ExtraArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info  { param([string]$Msg) Write-Host "[info]  $Msg" -ForegroundColor Cyan }
function Write-Match { param([string]$Msg) Write-Host "[match] $Msg" -ForegroundColor Green }
function Write-Skip  { param([string]$Msg) Write-Host "[skip]  $Msg" -ForegroundColor DarkGray }
function Write-Err   { param([string]$Msg) Write-Host "[error] $Msg" -ForegroundColor Red }

# ── 1. Discover available skills from the repo ──────────────────────────

Write-Info "Listing skills from $RepoUrl ..."

$listRaw = $null
try {
    $listRaw = & npx skills add $RepoUrl --list 2>&1 | Out-String
} catch {
    Write-Err "Failed to list skills: $_"
    exit 1
}

if (-not $listRaw -or $listRaw.Trim().Length -eq 0) {
    Write-Err "No output from --list. Check that the repo URL is correct and accessible."
    exit 1
}

# ── 2. Parse skill names from the list output ───────────────────────────
# Strip ANSI escape codes so regexes can match clean text.
$listRaw = $listRaw -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
$listRaw = $listRaw -replace '\[\?25[lh]', ''
$listRaw = $listRaw -replace '\[999D', ''
$listRaw = $listRaw -replace '\[J', ''

# Strategy: extract tokens that look like skill identifiers.
# Handles table output, one-per-line, and key: value formats.

$skillNames = @()
foreach ($line in ($listRaw -split "`r?`n")) {
    $trimmed = $line.Trim()
    # skip blanks, ascii-art dividers, and header-looking lines
    if (-not $trimmed) { continue }
    if ($trimmed -match '^[\-=+|]+$') { continue }
    if ($trimmed -match '(?i)^(name|skill|available|listing|─)') { continue }

    # Try common formats:
    #   "  skill-name   some description"
    #   "- skill-name"
    #   "* skill-name"
    #   "skill-name: description"
    #   "| skill-name | ... |"
    $candidate = $null

    # Match lines that contain ONLY a skill-like identifier (possibly indented)
    # This avoids capturing description lines which have spaces/sentences.
    # Format from `npx skills`: "|    skill-name"
    if ($trimmed -match '^\|?\s*([a-zA-Z0-9][\w\-\.]+)\s*$') {
        $candidate = $Matches[1]
    }
    elseif ($trimmed -match '^[\-\*]\s+([a-zA-Z0-9][\w\-\.]+)$') {
        $candidate = $Matches[1]
    }

    if ($candidate -and $candidate -notmatch '^(name|skill|id|description|version|type|status|Use|Found|Source|Repository|Available)$') {
        $skillNames += $candidate
    }
}

$skillNames = @($skillNames | Select-Object -Unique)

if ($skillNames.Count -eq 0) {
    Write-Err "Could not parse any skill names from the listing output."
    Write-Info "Raw output was:"
    Write-Host $listRaw
    exit 1
}

Write-Info "Found $($skillNames.Count) skill(s) in repo: $($skillNames -join ', ')"

# ── 3. Match skill names against the glob patterns ──────────────────────

$matched = [System.Collections.Generic.List[string]]::new()

foreach ($pattern in $Skill) {
    $hits = $skillNames | Where-Object { $_ -like $pattern }
    if ($hits) {
        foreach ($h in $hits) {
            if (-not $matched.Contains($h)) { $matched.Add($h) }
        }
    } else {
        Write-Skip "Pattern '$pattern' matched no skills."
    }
}

if ($matched.Count -eq 0) {
    Write-Err "No skills matched the given pattern(s): $($Skill -join ', ')"
    Write-Info "Available skills: $($skillNames -join ', ')"
    exit 1
}

Write-Host ""
Write-Info "Matched $($matched.Count) skill(s):"
foreach ($m in $matched) { Write-Match "  $m" }
Write-Host ""

# ── 4. Dry-run gate ─────────────────────────────────────────────────────

if ($DryRun) {
    Write-Info "[dry-run] No skills were installed. Remove -DryRun to install."
    exit 0
}

# ── 5. Install each matched skill ───────────────────────────────────────

$failed  = @()
$success = @()

foreach ($name in $matched) {
    Write-Info "Installing skill: $name ..."
    $cmd = @('skills', 'add', $RepoUrl, '--skill', $name)
    foreach ($adp in $Adapter) {
        foreach ($a in ($adp -split ',')) {
            if ($a.Trim()) { $cmd += @('-a', $a.Trim()) }
        }
    }
    if ($Global)   { $cmd += '-g' }
    if ($Yes)      { $cmd += '-y' }
    if ($ExtraArgs) { $cmd += $ExtraArgs }

    try {
        & npx @cmd 2>&1 | ForEach-Object { Write-Host "  $_" }
        if ($LASTEXITCODE -ne 0) { throw "npx exited with code $LASTEXITCODE" }
        $success += $name
    } catch {
        Write-Err "Failed to install '$name': $_"
        $failed += $name
    }
}

# ── 6. Summary ──────────────────────────────────────────────────────────

Write-Host ""
Write-Info "Done. Installed: $($success.Count)/$($matched.Count)"
if ($success.Count -gt 0) { Write-Match "  OK:     $($success -join ', ')" }
if ($failed.Count  -gt 0) { Write-Err   "  FAILED: $($failed -join ', ')" }
if ($failed.Count  -gt 0) { exit 1 }
