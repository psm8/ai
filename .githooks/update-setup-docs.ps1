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

function ExtractSkillDependencies {
    param([string]$FilePath, [string]$SkillName)
    $content = Get-Content $FilePath -Raw
    $dependencies = @()
    
    # Extract the description to scan for skill references
    if ($content -match '(?s)^---\s*\n(.*?)\n---') {
        $frontmatter = $matches[1]
        if ($frontmatter -match 'description:\s*(.+?)(?=\n\w+:|$)') {
            $description = $matches[1] -replace '^["'']|["'']$'
            
            # Find ps-* and rs-* references in description
            $skillPattern = '(?:ps-[a-z0-9\-]+|rs-[a-z0-9\-]+)'
            $refs = [regex]::Matches($description, $skillPattern)
            foreach ($match in $refs) {
                $ref = $match.Value
                # Avoid adding self-reference
                if ($ref -ne $SkillName) {
                    $dependencies += $ref
                }
            }
        }
    }
    
    # Also scan the body for skill references in code blocks and mentions
    if ($content -match '(?s)---\s*\n.*?\n---\s*\n(.+)') {
        $body = $matches[1]
        $skillPattern = '`(ps-[a-z0-9\-]+|rs-[a-z0-9\-]+)`|(?:use|Use)\s+(?:the\s+)?(ps-[a-z0-9\-]+|rs-[a-z0-9\-]+)'
        $refs = [regex]::Matches($body, $skillPattern)
        foreach ($match in $refs) {
            # Group 1 has backtick refs, groups 2-3 have use-based refs
            $ref = if ($match.Groups[1].Value) { $match.Groups[1].Value } else { $match.Groups[2].Value -or $match.Groups[3].Value }
            if ($ref -and $ref -ne $SkillName -and $dependencies -notcontains $ref) {
                $dependencies += $ref
            }
        }
    }
    
    return $dependencies | Select-Object -Unique
}

function GetSkillScope {
    param([string]$SkillName)
    if ($SkillName -like "ps-*") {
        return "global"
    } elseif ($SkillName -like "rs-*") {
        return "local"
    }
    return "local"  # default to local for unknown prefixes
}

$skillsDir = Join-Path $RepoRoot "skills"
$localSkills = @()
if (Test-Path $skillsDir) {
    Get-ChildItem -Path $skillsDir -Directory | ForEach-Object {
        $skillFile = Join-Path $_.FullName "SKILL.md"
        if (Test-Path $skillFile) {
            $parsed = ParseSkillFrontmatter $skillFile
            if ($parsed -and $parsed.name) {
                $deps = ExtractSkillDependencies $skillFile $parsed.name
                $scope = GetSkillScope $parsed.name
                $localSkills += @{ 
                    name = $parsed.name
                    dir = $_.Name
                    description = $parsed.description
                    dependencies = $deps
                    scope = $scope
                }
            }
        }
    }
}

if ($localSkills.Count -eq 0) { exit 0 }

# Separate skills by scope
$globalSkills = @($localSkills | Where-Object { $_.scope -eq "global" } | Sort-Object name)
$localOnlySkills = @($localSkills | Where-Object { $_.scope -eq "local" } | Sort-Object name)

# Build install commands with a set to track processed skills (case-insensitive)
$installLines = @()
$processedSkills = @{}  # Dictionary to track which skills have been added (lowercase keys)

# Global (personal) skills section
if ($globalSkills.Count -gt 0) {
    $installLines += "# Global (Personal) Skills"
    $installLines += ""
    
    # Process each skill with its dependencies
    foreach ($skill in $globalSkills) {
        $skillKey = $skill.name.ToLower()
        if (-not $processedSkills.ContainsKey($skillKey)) {
            $installLines += "skg psm8/ai -s $($skill.name)"
            $processedSkills[$skillKey] = $true
        }
        
        # Add global dependencies
        if ($skill.dependencies) {
            foreach ($dep in $skill.dependencies) {
                $depScope = GetSkillScope $dep
                if ($depScope -eq "global") {
                    $depKey = $dep.ToLower()
                    if (-not $processedSkills.ContainsKey($depKey)) {
                        # Check if this dependency is in our local skills repo
                        $depSkill = $localSkills | Where-Object { $_.name -eq $dep }
                        if ($depSkill) {
                            $installLines += "skg psm8/ai -s $dep  # (dependency)"
                        }
                        $processedSkills[$depKey] = $true
                    }
                }
            }
        }
    }
    
    $installLines += ""
}


# Local (repo) skills section
if ($localOnlySkills.Count -gt 0) {
    $installLines += "# Local (Repository) Skills"
    $installLines += ""
    foreach ($skill in $localOnlySkills) {
        $skillKey = $skill.name.ToLower()
        if (-not $processedSkills.ContainsKey($skillKey)) {
            $installLines += "skl psm8/ai -s $($skill.name)"
            $processedSkills[$skillKey] = $true
        }
        
        # Add local dependencies
        if ($skill.dependencies) {
            foreach ($dep in $skill.dependencies) {
                $depScope = GetSkillScope $dep
                if ($depScope -eq "local") {
                    $depKey = $dep.ToLower()
                    if (-not $processedSkills.ContainsKey($depKey)) {
                        $installLines += "skl psm8/ai -s $dep  # (dependency)"
                        $processedSkills[$depKey] = $true
                    }
                }
            }
        }
    }
}

$installSection = "`n#### This Repository`n`nSkills developed in this repository:`n``````bash`n"
$installSection += ($installLines -join "`n")
$installSection += "`n``````"

$setupPath = Join-Path -Path $RepoRoot -ChildPath "docs" | Join-Path -ChildPath "setup.md"
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
        $newContent | Out-File -FilePath $setupPath -Encoding UTF8 -NoNewline
    }
}