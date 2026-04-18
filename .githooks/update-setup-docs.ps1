#Requires -Version 5.1
param([string]$RepoRoot = (git rev-parse --show-toplevel 2>$null))
if (-not $RepoRoot) { exit 1 }

function ParseSkillFrontmatter {
    param([string]$FilePath)
    $content = Get-Content $FilePath -Raw
    if ($content -match '(?s)^---\s*\n(.*?)\n---') {
        $parsed = @{ name = ""; description = "" }
        $matches[1] -split '\n' | ForEach-Object {
            if ($_ -match '^\s*name:\s*(.+)$') { $parsed.name = ($matches[1] -replace '^["'']|["'']$').Trim() }
            elseif ($_ -match '^\s*description:\s*(.+)$') { $parsed.description = ($matches[1] -replace '^["'']|["'']$').Trim() }
        }
        return $parsed
    }
    return $null
}

$skillsDir = Join-Path $RepoRoot "skills"
$localSkills = @()
if (Test-Path $skillsDir) {
    Get-ChildItem -Path $skillsDir -Directory | ForEach-Object {
        $skillFile = Join-Path $_.FullName "SKILL.md"
        if (Test-Path $skillFile) {
            $parsed = ParseSkillFrontmatter $skillFile
            if ($parsed -and $parsed.name) {
                $localSkills += @{ name = $parsed.name; dir = $_.Name; description = $parsed.description }
            }
        }
    }
}

if ($localSkills.Count -eq 0) { exit 0 }

$installSection = "`n#### This Repository`n`nSkills developed in this repository:`n``````bash`n"
foreach ($skill in $localSkills | Sort-Object name) {
    $installSection += "npx skills add psm8/ai --skill $($skill.name)`n"
}
$installSection += "``````"

$setupPath = Join-Path $RepoRoot "docs" "setup.md"
if (Test-Path $setupPath) {
    $content = Get-Content $setupPath -Raw
    $newContent = $null
    if ($content -like "*#### This Repository*") {
        $pattern = "(?s)(\n#### This Repository.*?)(?=#### |\z)"
        if ($content -match $pattern) {
            $newContent = $content -replace $pattern, $installSection
        }
    } else {
        if ($content -like "*## Agents Setup*") {
            $newContent = $content -replace "(## Agents Setup)", ($installSection + "`n`n`$1")
        } else {
            $newContent = $content + $installSection
        }
    }
    if ($newContent -and $newContent -ne $content) {
        $newContent | Out-File -Path $setupPath -Encoding UTF8 -NoNewline
    }
}