<#
Resume Agent Script
Purpose: resume CPA for a specific session only when actionable GitHub issues exist,
the session is not actively running, and rate-limit cooldown has expired.

Usage:
  powershell -NoProfile -ExecutionPolicy Bypass -File resume_agent.ps1 -SessionId <session-id>
  powershell -NoProfile -ExecutionPolicy Bypass -File resume_agent.ps1 -SessionId <session-id> -Prompt "..."
  powershell -NoProfile -ExecutionPolicy Bypass -File resume_agent.ps1 -SessionId <session-id> -DryRun
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SessionId,

    [string]$Prompt,

    [switch]$DryRun,

    [string]$AgentPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$logFile = Join-Path $scriptDir 'resume_agent.log'
$defaultPrompt = '/fleet continue with remaining github issues, use ps-solid-agent for implementation and review, verify and document ui changes with screenshots, test frequenty, iterate until everything looks fine, comment in github, when you think the issue is implemented, then commit the changes after each issue finished'
$cooldownFallback = [TimeSpan]::FromHours(2)
$activeHeartbeatThreshold = [TimeSpan]::FromMinutes(15)
$activeChildProcessThreshold = [TimeSpan]::FromMinutes(30)
$eventTailLineCount = 400
$stalledShutdownTimeout = [TimeSpan]::FromSeconds(20)
$processPollIntervalMs = 500
$excludedTitlePrefixes = @('PRD:', 'Spec:', 'RFC:')
$excludedLabels = @('prd', 'spec', 'design-doc')
$terminalEventTypes = @('session.end', 'session.ended')
$ignoredInfrastructureProcesses = @('conhost', 'openconsole', 'windowsterminal', 'cmd', 'pwsh', 'powershell')
$ignoredBackgroundProcesses = @('emulator', 'qemu-system-x86_64', 'netsimd', 'crashpad_handler')
$sessionHome = if ([string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
    [Environment]::GetFolderPath('UserProfile')
} else {
    $env:USERPROFILE
}
$sessionRoot = Join-Path $sessionHome (Join-Path '.copilot\session-state' $SessionId)

function Append-ResumeLogEntry {
    param([string]$Text)

    [System.IO.File]::AppendAllText($logFile, $Text + [Environment]::NewLine)
}

function Write-ResumeLog {
    param([string]$Message)

    $line = '[{0}] {1}' -f (Get-Date -Format o), $Message
    Append-ResumeLogEntry -Text $line
    Write-Host $line
}

function Format-TimeSpan {
    param([TimeSpan]$Duration)

    if ($Duration -lt [TimeSpan]::Zero) {
        $Duration = [TimeSpan]::Zero
    }

    $parts = @()
    if ($Duration.Days -gt 0) {
        $parts += ('{0}d' -f $Duration.Days)
    }
    if ($Duration.Hours -gt 0) {
        $parts += ('{0}h' -f $Duration.Hours)
    }
    if ($Duration.Minutes -gt 0) {
        $parts += ('{0}m' -f $Duration.Minutes)
    }
    if ($parts.Count -eq 0) {
        $parts += ('{0}s' -f [Math]::Max($Duration.Seconds, 0))
    }

    return ($parts -join ' ')
}

function Get-ResolvedPrompt {
    param([string]$RequestedPrompt)

    if ([string]::IsNullOrWhiteSpace($RequestedPrompt)) {
        return $defaultPrompt
    }

    return $RequestedPrompt
}

function Normalize-YamlValue {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $Value
    }

    $trimmed = $Value.Trim()
    if ($trimmed.Length -ge 2) {
        if (($trimmed.StartsWith('"') -and $trimmed.EndsWith('"')) -or ($trimmed.StartsWith("'") -and $trimmed.EndsWith("'"))) {
            return $trimmed.Substring(1, $trimmed.Length - 2)
        }
    }

    return $trimmed
}

function Get-SessionMetadata {
    param([string]$WorkspaceFilePath)

    $metadata = [ordered]@{
        Repository = $null
        GitRoot = $null
        Cwd = $null
    }

    if (-not (Test-Path -LiteralPath $WorkspaceFilePath)) {
        return [pscustomobject]$metadata
    }

    foreach ($line in Get-Content -LiteralPath $WorkspaceFilePath -ErrorAction SilentlyContinue) {
        if ($line -match '^(?<key>[A-Za-z0-9_]+):\s*(?<value>.*)$') {
            $key = $Matches['key']
            $value = Normalize-YamlValue -Value $Matches['value']

            switch ($key) {
                'repository' { $metadata.Repository = $value }
                'git_root' { $metadata.GitRoot = $value }
                'cwd' { $metadata.Cwd = $value }
            }
        }
    }

    return [pscustomobject]$metadata
}

function Get-RepositoryFromGitRemote {
    param([string]$GitRoot)

    if ([string]::IsNullOrWhiteSpace($GitRoot) -or -not (Test-Path -LiteralPath $GitRoot)) {
        return $null
    }

    $gitCommand = Get-Command git -ErrorAction SilentlyContinue
    if (-not $gitCommand) {
        return $null
    }

    try {
        $remoteUrl = & $gitCommand.Path -C $GitRoot remote get-url origin 2>$null
        if ($LASTEXITCODE -ne 0) {
            return $null
        }

        $remoteUrlText = ($remoteUrl | Out-String).Trim()
        if ([string]::IsNullOrWhiteSpace($remoteUrlText)) {
            return $null
        }

        foreach ($pattern in @(
            'github\.com[:/](?<owner>[^/:\s]+)/(?<repo>[^/\s]+?)(?:\.git)?$',
            'github\.com/(?<owner>[^/:\s]+)/(?<repo>[^/\s]+?)(?:\.git)?$'
        )) {
            if ($remoteUrlText -match $pattern) {
                return [pscustomobject]@{
                    Owner = $Matches['owner']
                    Repo = $Matches['repo']
                }
            }
        }
    } catch {
        return $null
    }

    return $null
}

function Get-RepositoryContext {
    param([string]$SessionFolder)

    $workspaceFile = Join-Path $SessionFolder 'workspace.yaml'
    $metadata = Get-SessionMetadata -WorkspaceFilePath $workspaceFile
    $owner = $null
    $repoName = $null

    if (-not [string]::IsNullOrWhiteSpace($metadata.Repository) -and $metadata.Repository -match '^(?<owner>[^/\s]+)/(?<repo>[^/\s]+)$') {
        $owner = $Matches['owner']
        $repoName = $Matches['repo']
    } else {
        $gitRepository = Get-RepositoryFromGitRemote -GitRoot $metadata.GitRoot
        if ($null -ne $gitRepository) {
            $owner = $gitRepository.Owner
            $repoName = $gitRepository.Repo
        }
    }

    $workingDirectory = $metadata.GitRoot
    if ([string]::IsNullOrWhiteSpace($workingDirectory)) {
        $workingDirectory = $metadata.Cwd
    }
    if (-not [string]::IsNullOrWhiteSpace($workingDirectory) -and -not (Test-Path -LiteralPath $workingDirectory)) {
        $workingDirectory = $null
    }

    return [pscustomobject]@{
        Owner = $owner
        Repo = $repoName
        WorkingDirectory = $workingDirectory
        Metadata = $metadata
    }
}

function Convert-LineToJsonObject {
    param([string]$Line)

    try {
        return $Line | ConvertFrom-Json
    } catch {
        return $null
    }
}

function Read-SessionEvents {
    param(
        [string]$EventsFilePath,
        [int]$TailCount = $eventTailLineCount
    )

    $events = @()
    if (-not (Test-Path -LiteralPath $EventsFilePath)) {
        return $events
    }

    $lines = @()
    try {
        $lines = @(Get-Content -LiteralPath $EventsFilePath -Tail $TailCount -ErrorAction Stop)
    } catch {
        try {
            $lines = @(Get-Content -LiteralPath $EventsFilePath -ErrorAction SilentlyContinue | Select-Object -Last $TailCount)
        } catch {
            return $events
        }
    }

    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $eventObject = Convert-LineToJsonObject -Line $line
        if ($null -eq $eventObject) {
            continue
        }

        $timestamp = $null
        if ($eventObject.PSObject.Properties.Name -contains 'timestamp' -and -not [string]::IsNullOrWhiteSpace([string]$eventObject.timestamp)) {
            try {
                $timestamp = [DateTimeOffset]::Parse([string]$eventObject.timestamp)
            } catch {
                $timestamp = $null
            }
        }

        $eventType = $null
        if ($eventObject.PSObject.Properties.Name -contains 'type') {
            $eventType = [string]$eventObject.type
        }

        $eventData = $null
        if ($eventObject.PSObject.Properties.Name -contains 'data') {
            $eventData = $eventObject.data
        }

        $events += [pscustomobject]@{
            Type = $eventType
            Timestamp = $timestamp
            Data = $eventData
        }
    }

    return $events
}

function Get-CooldownTimestampFromMessage {
    param([string]$Message)

    if ([string]::IsNullOrWhiteSpace($Message)) {
        return $null
    }

    foreach ($match in [regex]::Matches($Message, '(?<timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+\-]\d{2}:\d{2}))')) {
        try {
            return [DateTimeOffset]::Parse($match.Groups['timestamp'].Value)
        } catch {
        }
    }

    return $null
}

function Get-CooldownDurationFromMessage {
    param([string]$Message)

    if ([string]::IsNullOrWhiteSpace($Message)) {
        return $null
    }

    $hours = 0
    $minutes = 0
    foreach ($match in [regex]::Matches($Message, '(?i)(?<value>\d+)\s+(?<unit>hours?|minutes?)')) {
        $value = [int]$match.Groups['value'].Value
        $unit = $match.Groups['unit'].Value.ToLowerInvariant()

        if ($unit.StartsWith('hour')) {
            $hours += $value
        } elseif ($unit.StartsWith('minute')) {
            $minutes += $value
        }
    }

    if ($hours -eq 0 -and $minutes -eq 0) {
        return $null
    }

    return [TimeSpan]::FromHours($hours) + [TimeSpan]::FromMinutes($minutes)
}

function Get-RateLimitStatus {
    param([object[]]$Events)

    $rateLimitEvents = @(
        $Events |
            Where-Object {
                $_.Type -eq 'session.error' -and
                $null -ne $_.Data -and
                $_.Data.PSObject.Properties.Name -contains 'errorType' -and
                [string]$_.Data.errorType -eq 'rate_limit' -and
                $null -ne $_.Timestamp
            } |
            Sort-Object -Property Timestamp -Descending
    )

    if ($rateLimitEvents.Count -eq 0) {
        return [pscustomobject]@{
            IsActive = $false
            CooldownUntil = $null
            Remaining = $null
            Message = $null
            EventTimestamp = $null
        }
    }

    $latest = $rateLimitEvents[0]
    $supersedingEvent = $Events |
        Where-Object {
            $null -ne $_.Timestamp -and
            $_.Timestamp -gt $latest.Timestamp -and
            ($_.Type -ne 'session.error' -or $null -eq $_.Data -or $_.Data.PSObject.Properties.Name -notcontains 'errorType' -or [string]$_.Data.errorType -ne 'rate_limit')
        } |
        Sort-Object -Property Timestamp -Descending |
        Select-Object -First 1

    if ($null -ne $supersedingEvent) {
        return [pscustomobject]@{
            IsActive = $false
            CooldownUntil = $null
            Remaining = [TimeSpan]::Zero
            Message = $null
            EventTimestamp = $latest.Timestamp
            Source = 'superseded'
        }
    }

    $message = $null
    if ($latest.Data.PSObject.Properties.Name -contains 'message') {
        $message = [string]$latest.Data.message
    }
    $cooldownUntil = Get-CooldownTimestampFromMessage -Message $message
    $source = 'message-duration'
    if ($null -eq $cooldownUntil) {
        $duration = Get-CooldownDurationFromMessage -Message $message
        if ($null -eq $duration) {
            $duration = $cooldownFallback
            $source = 'fallback-duration'
        }

        $cooldownUntil = $latest.Timestamp.Add($duration)
    }

    $now = [DateTimeOffset]::UtcNow
    $remaining = [TimeSpan]::Zero
    if ($cooldownUntil -gt $now) {
        $remaining = $cooldownUntil - $now
    }

    return [pscustomobject]@{
        IsActive = $cooldownUntil -gt $now
        CooldownUntil = $cooldownUntil
        Remaining = $remaining
        Message = $message
        EventTimestamp = $latest.Timestamp
        Source = $source
    }
}

function Get-LockProcessId {
    param([System.IO.FileInfo]$LockFile)

    if ($null -eq $LockFile) {
        return $null
    }

    if ($LockFile.BaseName -match '(?i)\.(?<pid>\d+)$') {
        return [int]$Matches['pid']
    }

    try {
        $content = (Get-Content -LiteralPath $LockFile.FullName -TotalCount 1 -ErrorAction Stop | Out-String).Trim()
        if ($content -match '^(?<pid>\d+)$') {
            return [int]$Matches['pid']
        }
    } catch {
    }

    return $null
}

function Test-ProcessIdRunning {
    param([int]$ProcessId)

    if ($ProcessId -le 0) {
        return $false
    }

    try {
        $process = Get-Process -Id $ProcessId -ErrorAction Stop
        return $null -ne $process
    } catch {
        return $false
    }
}

function Get-NormalizedProcessName {
    param([string]$Name)

    if ([string]::IsNullOrWhiteSpace($Name)) {
        return $null
    }

    return ([System.IO.Path]::GetFileNameWithoutExtension($Name)).ToLowerInvariant()
}

function Get-DescendantProcesses {
    param([int]$RootProcessId)

    if ($RootProcessId -le 0) {
        return @()
    }

    $allProcesses = @()
    try {
        $allProcesses = @(Get-CimInstance Win32_Process -ErrorAction Stop)
    } catch {
        return @()
    }

    $childrenByParent = @{}
    foreach ($process in $allProcesses) {
        $parentId = [int]$process.ParentProcessId
        if (-not $childrenByParent.ContainsKey($parentId)) {
            $childrenByParent[$parentId] = New-Object System.Collections.ArrayList
        }

        [void]$childrenByParent[$parentId].Add($process)
    }

    $descendants = New-Object System.Collections.Generic.List[object]
    $stack = New-Object System.Collections.Stack
    if ($childrenByParent.ContainsKey($RootProcessId)) {
        foreach ($child in $childrenByParent[$RootProcessId]) {
            [void]$stack.Push($child)
        }
    }

    while ($stack.Count -gt 0) {
        $current = $stack.Pop()
        [void]$descendants.Add($current)

        $currentId = [int]$current.ProcessId
        if ($childrenByParent.ContainsKey($currentId)) {
            foreach ($child in $childrenByParent[$currentId]) {
                [void]$stack.Push($child)
            }
        }
    }

    return $descendants.ToArray()
}

function Get-ProcessTreeStatus {
    param([int]$RootProcessId)

    $descendants = @(Get-DescendantProcesses -RootProcessId $RootProcessId)
    $recentChildCutoff = [DateTimeOffset]::UtcNow.Subtract($activeChildProcessThreshold)
    $activeChildProcesses = @(
        $descendants |
            Where-Object {
                $normalizedName = Get-NormalizedProcessName -Name $_.Name
                if ([string]::IsNullOrWhiteSpace($normalizedName)) {
                    return $false
                }
                if ($ignoredInfrastructureProcesses -contains $normalizedName -or $ignoredBackgroundProcesses -contains $normalizedName) {
                    return $false
                }

                if ($_.PSObject.Properties.Name -notcontains 'CreationDate' -or [string]::IsNullOrWhiteSpace([string]$_.CreationDate)) {
                    return $true
                }

                try {
                    $creationTime = [DateTimeOffset][System.Management.ManagementDateTimeConverter]::ToDateTime([string]$_.CreationDate)
                    return $creationTime -ge $recentChildCutoff
                } catch {
                    return $true
                }
            }
    )

    return [pscustomobject]@{
        RootProcessId = $RootProcessId
        Descendants = $descendants
        ActiveChildProcesses = $activeChildProcesses
        HasActiveChildWork = $activeChildProcesses.Count -gt 0
    }
}

function Wait-ForProcessExit {
    param(
        [int]$ProcessId,
        [TimeSpan]$Timeout
    )

    $deadline = [DateTimeOffset]::UtcNow.Add($Timeout)
    while ([DateTimeOffset]::UtcNow -lt $deadline) {
        if (-not (Test-ProcessIdRunning -ProcessId $ProcessId)) {
            return $true
        }

        [System.Threading.Thread]::Sleep($processPollIntervalMs)
    }

    return -not (Test-ProcessIdRunning -ProcessId $ProcessId)
}

function Stop-ProcessTree {
    param([int]$RootProcessId)

    $processTree = Get-ProcessTreeStatus -RootProcessId $RootProcessId
    foreach ($descendant in @($processTree.Descendants | Sort-Object -Property ProcessId -Descending)) {
        try {
            Stop-Process -Id ([int]$descendant.ProcessId) -Force -ErrorAction Stop
        } catch {
        }
    }

    try {
        Stop-Process -Id $RootProcessId -Force -ErrorAction Stop
    } catch {
        if (Test-ProcessIdRunning -ProcessId $RootProcessId) {
            throw
        }
    }

    return Wait-ForProcessExit -ProcessId $RootProcessId -Timeout $stalledShutdownTimeout
}

function Get-SessionHeartbeatStatus {
    param(
        [string]$SessionFolder,
        [string]$EventsFilePath,
        [object[]]$Events
    )

    $sources = New-Object System.Collections.Generic.List[object]

    foreach ($path in @(
        $EventsFilePath,
        (Join-Path $SessionFolder 'session.db'),
        (Join-Path $SessionFolder 'plan.md'),
        (Join-Path $SessionFolder 'checkpoints\index.md'),
        (Join-Path $SessionFolder 'rewind-snapshots\index.json')
    )) {
        if (-not [string]::IsNullOrWhiteSpace($path) -and (Test-Path -LiteralPath $path)) {
            $item = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
            if ($null -ne $item) {
                [void]$sources.Add([pscustomobject]@{
                    Source = $path
                    Timestamp = [DateTimeOffset]$item.LastWriteTimeUtc
                })
            }
        }
    }

    $checkpointsPath = Join-Path $SessionFolder 'checkpoints'
    if (Test-Path -LiteralPath $checkpointsPath) {
        $latestCheckpoint = Get-ChildItem -LiteralPath $checkpointsPath -Filter '*.md' -File -ErrorAction SilentlyContinue |
            Sort-Object -Property LastWriteTimeUtc -Descending |
            Select-Object -First 1
        if ($null -ne $latestCheckpoint) {
            [void]$sources.Add([pscustomobject]@{
                Source = $latestCheckpoint.FullName
                Timestamp = [DateTimeOffset]$latestCheckpoint.LastWriteTimeUtc
            })
        }
    }

    $latestEvent = $Events |
        Where-Object { $null -ne $_.Timestamp } |
        Sort-Object -Property Timestamp -Descending |
        Select-Object -First 1
    if ($null -ne $latestEvent) {
        [void]$sources.Add([pscustomobject]@{
            Source = 'events.jsonl:last-event'
            Timestamp = $latestEvent.Timestamp
        })
    }

    $latestSource = $sources |
        Sort-Object -Property Timestamp -Descending |
        Select-Object -First 1
    $age = [TimeSpan]::MaxValue
    if ($null -ne $latestSource) {
        $age = [DateTimeOffset]::UtcNow - $latestSource.Timestamp
    }

    $latestHeartbeatSource = $null
    $latestHeartbeatTimestamp = $null
    if ($null -ne $latestSource) {
        $latestHeartbeatSource = [string]$latestSource.Source
        $latestHeartbeatTimestamp = $latestSource.Timestamp
    }

    return [pscustomobject]@{
        Sources = @($sources.ToArray())
        LatestSource = $latestHeartbeatSource
        LatestTimestamp = $latestHeartbeatTimestamp
        Age = $age
        IsRecent = ($null -ne $latestSource) -and ($age -le $activeHeartbeatThreshold)
    }
}

function Format-LockEntries {
    param([object[]]$Entries)

    if ($null -eq $Entries -or $Entries.Count -eq 0) {
        return 'none'
    }

    return (@(
        $Entries |
            ForEach-Object {
                if ($null -ne $_.ProcessId) {
                    '{0} (pid {1})' -f $_.File.Name, $_.ProcessId
                } else {
                    $_.File.Name
                }
            }
    ) -join '; ')
}

function Remove-SessionLockEntries {
    param([object[]]$Entries)

    $removed = New-Object System.Collections.Generic.List[string]
    $failed = New-Object System.Collections.Generic.List[string]
    foreach ($entry in @($Entries)) {
        if ($null -eq $entry -or $null -eq $entry.File) {
            continue
        }

        try {
            Remove-Item -LiteralPath $entry.File.FullName -Force -ErrorAction Stop
            [void]$removed.Add($entry.File.Name)
        } catch {
            [void]$failed.Add($entry.File.Name)
        }
    }

    return [pscustomobject]@{
        Removed = $removed.ToArray()
        Failed = $failed.ToArray()
    }
}

function Get-SessionExecutionState {
    param(
        [string]$SessionFolder,
        [object[]]$Events,
        [string]$EventsFilePath
    )

    $lockFiles = @()
    if (Test-Path -LiteralPath $SessionFolder) {
        $lockFiles = @(Get-ChildItem -LiteralPath $SessionFolder -Filter '*.lock' -File -ErrorAction SilentlyContinue)
    }

    $activeLocks = @()
    $staleLocks = @()
    $unknownLocks = @()
    foreach ($lockFile in $lockFiles) {
        $lockProcessId = Get-LockProcessId -LockFile $lockFile
        if ($null -eq $lockProcessId) {
            $unknownLocks += [pscustomobject]@{
                File = $lockFile
                ProcessId = $null
            }
            continue
        }

        if (Test-ProcessIdRunning -ProcessId $lockProcessId) {
            $activeLocks += [pscustomobject]@{
                File = $lockFile
                ProcessId = $lockProcessId
            }
        } else {
            $staleLocks += [pscustomobject]@{
                File = $lockFile
                ProcessId = $lockProcessId
            }
        }
    }

    $latestEvent = $Events |
        Where-Object {
            $null -ne $_.Timestamp -and $terminalEventTypes -notcontains $_.Type
        } |
        Sort-Object -Property Timestamp -Descending |
        Select-Object -First 1

    $heartbeatStatus = Get-SessionHeartbeatStatus -SessionFolder $SessionFolder -EventsFilePath $EventsFilePath -Events $Events
    $processTrees = @()
    foreach ($activeLock in $activeLocks) {
        $processTrees += @(Get-ProcessTreeStatus -RootProcessId $activeLock.ProcessId)
    }

    $activeChildProcesses = @()
    foreach ($processTree in $processTrees) {
        if ($null -ne $processTree.ActiveChildProcesses) {
            $activeChildProcesses += @($processTree.ActiveChildProcesses)
        }
    }
    $hasActiveChildWork = $activeChildProcesses.Count -gt 0

    $state = 'ready-to-resume'
    $isBlocking = $false
    if ($activeLocks.Count -gt 0) {
        if ($heartbeatStatus.IsRecent -or $hasActiveChildWork) {
            $state = 'actively-working'
            $isBlocking = $true
        } else {
            $state = 'live-but-stalled'
        }
    } elseif ($unknownLocks.Count -gt 0) {
        if ($heartbeatStatus.IsRecent) {
            $state = 'unknown-lock-with-recent-heartbeat'
            $isBlocking = $true
        } else {
            $state = 'unknown-lock-but-stale'
        }
    } elseif ($heartbeatStatus.IsRecent) {
        $state = 'recent-heartbeat-no-lock'
        $isBlocking = $true
    } elseif ($staleLocks.Count -gt 0) {
        $state = 'dead-stale-lock'
    }

    return [pscustomobject]@{
        State = $state
        IsBlocking = $isBlocking
        LockFiles = $lockFiles
        ActiveLocks = $activeLocks
        StaleLocks = $staleLocks
        UnknownLocks = $unknownLocks
        LatestEvent = $latestEvent
        HeartbeatStatus = $heartbeatStatus
        ProcessTrees = $processTrees
        ActiveChildProcesses = $activeChildProcesses
        HasActiveChildWork = $hasActiveChildWork
    }
}

function Get-GitHubIssues {
    param(
        [string]$Owner,
        [string]$RepoName
    )

    $ghCommand = Get-Command gh -ErrorAction SilentlyContinue
    if (-not $ghCommand) {
        throw 'GitHub CLI not found in PATH.'
    }

    $issues = @()
    $page = 1
    while ($true) {
        $path = 'repos/{0}/{1}/issues?state=open&per_page=100&page={2}' -f $Owner, $RepoName, $page
        $raw = & $ghCommand.Path api $path 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw (($raw | Out-String).Trim())
        }

        $rawText = ($raw | Out-String).Trim()
        if ([string]::IsNullOrWhiteSpace($rawText)) {
            break
        }

        $pageIssues = $rawText | ConvertFrom-Json
        $pageIssueList = @($pageIssues)
        if ($pageIssueList.Count -eq 0) {
            break
        }

        $issues += $pageIssueList
        if ($pageIssueList.Count -lt 100) {
            break
        }

        $page += 1
    }

    return $issues
}

function Get-IssueLabelNames {
    param([object]$Issue)

    $labelNames = @()
    if ($Issue.PSObject.Properties.Name -contains 'labels' -and $null -ne $Issue.labels) {
        foreach ($label in @($Issue.labels)) {
            if ($null -eq $label) {
                continue
            }

            if ($label -is [string]) {
                $labelNames += $label.ToLowerInvariant()
            } elseif ($label.PSObject.Properties.Name -contains 'name' -and -not [string]::IsNullOrWhiteSpace([string]$label.name)) {
                $labelNames += ([string]$label.name).ToLowerInvariant()
            }
        }
    }

    return $labelNames
}

function Test-ImplementationIssue {
    param([object]$Issue)

    if ($Issue.PSObject.Properties.Name -contains 'pull_request' -and $null -ne $Issue.pull_request) {
        return $false
    }

    $title = if ($Issue.PSObject.Properties.Name -contains 'title') { [string]$Issue.title } else { '' }
    foreach ($prefix in $excludedTitlePrefixes) {
        if ($title.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $false
        }
    }

    $labelNames = Get-IssueLabelNames -Issue $Issue
    foreach ($excludedLabel in $excludedLabels) {
        if ($labelNames -contains $excludedLabel) {
            return $false
        }
    }

    $body = if ($Issue.PSObject.Properties.Name -contains 'body') { [string]$Issue.body } else { '' }
    if ([string]::IsNullOrWhiteSpace($body) -or $body -notmatch '(?i)Acceptance Criteria') {
        return $false
    }

    $commentCount = 0
    if ($Issue.PSObject.Properties.Name -contains 'comments' -and $null -ne $Issue.comments) {
        $commentCount = [int]$Issue.comments
    }

    return $commentCount -eq 0
}

function Resolve-AgentPath {
    param([string]$RequestedAgentPath)

    if (-not [string]::IsNullOrWhiteSpace($RequestedAgentPath)) {
        return $RequestedAgentPath
    }

    $cmd = Get-Command cpa.bat -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Path) {
        return $cmd.Path
    }

    throw 'Agent not found in PATH: cpa.bat'
}

Append-ResumeLogEntry -Text ('----- {0} -----' -f (Get-Date -Format o))
Write-ResumeLog ('Starting resume check for session {0}.' -f $SessionId)

try {
    if (-not (Test-Path -LiteralPath $sessionRoot)) {
        Write-ResumeLog ('Configuration error: session folder not found at {0}.' -f $sessionRoot)
        exit 1
    }

    $repositoryContext = Get-RepositoryContext -SessionFolder $sessionRoot
    if ([string]::IsNullOrWhiteSpace($repositoryContext.Owner) -or [string]::IsNullOrWhiteSpace($repositoryContext.Repo)) {
        Write-ResumeLog 'Skipped: could not resolve the GitHub repository from session metadata.'
        exit 0
    }
    if ([string]::IsNullOrWhiteSpace($repositoryContext.WorkingDirectory)) {
        Write-ResumeLog 'Skipped: could not resolve a valid working directory from session metadata.'
        exit 0
    }

    Write-ResumeLog ('Resolved repository {0}/{1} and working directory {2}.' -f $repositoryContext.Owner, $repositoryContext.Repo, $repositoryContext.WorkingDirectory)

    try {
        $allIssues = @(Get-GitHubIssues -Owner $repositoryContext.Owner -RepoName $repositoryContext.Repo)
    } catch {
        Write-ResumeLog ('Skipped: failed to query GitHub issues for {0}/{1}. Error: {2}' -f $repositoryContext.Owner, $repositoryContext.Repo, $_.Exception.Message)
        exit 0
    }

    $actionableIssues = @($allIssues | Where-Object { Test-ImplementationIssue -Issue $_ })
    if ($actionableIssues.Count -eq 0) {
        Write-ResumeLog 'Skipped: no actionable open GitHub issues without comments were found.'
        exit 0
    }

    $issuePreview = @(
        $actionableIssues |
            Select-Object -First 5 |
            ForEach-Object { '#{0} {1}' -f $_.number, $_.title }
    ) -join '; '
    Write-ResumeLog ('Found {0} actionable issue(s). {1}' -f $actionableIssues.Count, $issuePreview)

    $eventsFile = Join-Path $sessionRoot 'events.jsonl'
    $events = Read-SessionEvents -EventsFilePath $eventsFile
    $rateLimitStatus = Get-RateLimitStatus -Events $events
    if ($rateLimitStatus.IsActive) {
        Write-ResumeLog ('Skipped: Copilot rate limit is active until {0} (remaining {1}, source {2}).' -f $rateLimitStatus.CooldownUntil.ToString('o'), (Format-TimeSpan -Duration $rateLimitStatus.Remaining), $rateLimitStatus.Source)
        exit 0
    }

    $sessionState = Get-SessionExecutionState -SessionFolder $sessionRoot -Events $events -EventsFilePath $eventsFile
    if ($null -ne $sessionState.HeartbeatStatus.LatestTimestamp) {
        Write-ResumeLog ('Session state {0}; latest heartbeat {1} from {2} ({3} ago).' -f $sessionState.State, $sessionState.HeartbeatStatus.LatestTimestamp.ToString('o'), $sessionState.HeartbeatStatus.LatestSource, (Format-TimeSpan -Duration $sessionState.HeartbeatStatus.Age))
    } else {
        Write-ResumeLog ('Session state {0}; no heartbeat files were found.' -f $sessionState.State)
    }

    if ($sessionState.IsBlocking) {
        $reasons = @()
        if ($sessionState.ActiveLocks.Count -gt 0) {
            $reasons += @(
                $sessionState.ActiveLocks |
                    ForEach-Object { 'live lock {0} (pid {1})' -f $_.File.Name, $_.ProcessId }
            )
        }
        if ($sessionState.UnknownLocks.Count -gt 0) {
            $reasons += @(
                $sessionState.UnknownLocks |
                    ForEach-Object { 'unvalidated lock {0}' -f $_.File.Name }
            )
        }
        if ($sessionState.HasActiveChildWork) {
            $reasons += ('active child work: {0}' -f ((@($sessionState.ActiveChildProcesses | Select-Object -ExpandProperty Name -Unique) -join ', ')))
        }
        if ($null -ne $sessionState.LatestEvent) {
            $reasons += ('latest event {0} at {1}' -f $sessionState.LatestEvent.Type, $sessionState.LatestEvent.Timestamp.ToString('o'))
        }
        Write-ResumeLog ('Skipped: session appears to be currently running ({0}).' -f ($reasons -join '; '))
        exit 0
    }

    if ($sessionState.State -eq 'live-but-stalled') {
        $stalledSummary = Format-LockEntries -Entries $sessionState.ActiveLocks
        Write-ResumeLog ('Session appears stalled: live lock(s) without heartbeat for {0}. Attempting recovery for {1}.' -f (Format-TimeSpan -Duration $sessionState.HeartbeatStatus.Age), $stalledSummary)

        foreach ($stalledLock in @($sessionState.ActiveLocks)) {
            $stopped = Stop-ProcessTree -RootProcessId $stalledLock.ProcessId
            if (-not $stopped) {
                Write-ResumeLog ('Recovery failed: Copilot PID {0} did not exit within {1}.' -f $stalledLock.ProcessId, (Format-TimeSpan -Duration $stalledShutdownTimeout))
                exit 1
            }

            Write-ResumeLog ('Recovered stalled Copilot PID {0}.' -f $stalledLock.ProcessId)
        }

        $sessionState = Get-SessionExecutionState -SessionFolder $sessionRoot -Events $events -EventsFilePath $eventsFile
        if ($sessionState.ActiveLocks.Count -gt 0) {
            Write-ResumeLog ('Recovery failed: live lock(s) still present after stopping process tree: {0}.' -f (Format-LockEntries -Entries $sessionState.ActiveLocks))
            exit 1
        }
    }

    $locksToRemove = @()
    if ($sessionState.StaleLocks.Count -gt 0) {
        $locksToRemove += @($sessionState.StaleLocks)
    }
    if ($sessionState.State -eq 'unknown-lock-but-stale') {
        $locksToRemove += @($sessionState.UnknownLocks)
    }
    if ($locksToRemove.Count -gt 0) {
        $cleanupResult = Remove-SessionLockEntries -Entries $locksToRemove
        if ($cleanupResult.Removed.Count -gt 0) {
            Write-ResumeLog ('Removed stale session lock(s): {0}.' -f ($cleanupResult.Removed -join '; '))
        }
        if ($cleanupResult.Failed.Count -gt 0) {
            Write-ResumeLog ('Configuration error: failed to remove stale lock(s): {0}.' -f ($cleanupResult.Failed -join '; '))
            exit 1
        }
    }

    $resolvedPrompt = Get-ResolvedPrompt -RequestedPrompt $Prompt
    $resolvedAgentPath = Resolve-AgentPath -RequestedAgentPath $AgentPath
    if (-not (Test-Path -LiteralPath $resolvedAgentPath)) {
        Write-ResumeLog ('Configuration error: agent not found at {0}.' -f $resolvedAgentPath)
        exit 1
    }

    if ($DryRun) {
        Write-ResumeLog ('Dry run: would start {0} in {1}.' -f $resolvedAgentPath, $repositoryContext.WorkingDirectory)
        Write-ResumeLog ('Dry run prompt: {0}' -f $resolvedPrompt)
        exit 0
    }

    $cpaArgs = @(
        $resolvedAgentPath,
        '--resume={0}' -f $SessionId,
        '--prompt={0}' -f [System.Security.SecurityElement]::Escape($resolvedPrompt),
        '--allow-all-paths',
        '--allow-all-tools',
        '--autopilot',
        '--model=gpt-5.4'
    )

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'cmd.exe'
    $startInfo.Arguments = '/c "{0}"' -f ($cpaArgs -join ' ')
    $startInfo.WorkingDirectory = $repositoryContext.WorkingDirectory
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo

    $stdoutBuilder = New-Object System.Text.StringBuilder
    $stderrBuilder = New-Object System.Text.StringBuilder
    $stdoutHandler = [System.Diagnostics.DataReceivedEventHandler]{
        param($eventSender, $eventArgs)
        if ($null -ne $eventArgs.Data) {
            [void]$stdoutBuilder.AppendLine($eventArgs.Data)
        }
    }
    $stderrHandler = [System.Diagnostics.DataReceivedEventHandler]{
        param($eventSender, $eventArgs)
        if ($null -ne $eventArgs.Data) {
            [void]$stderrBuilder.AppendLine($eventArgs.Data)
        }
    }

    Write-ResumeLog ('Launching CPA: {0}' -f ($cpaArgs -join ' '))

    $process.add_OutputDataReceived($stdoutHandler)
    $process.add_ErrorDataReceived($stderrHandler)
    $process.Start() | Out-Null
    $process.BeginOutputReadLine()
    $process.BeginErrorReadLine()

    $finished = $process.WaitForExit(600000)
    if (-not $finished) {
        try {
            $process.Kill()
        } catch {
        }
        Write-ResumeLog 'Process timed out and was terminated.'
        exit 1
    }

    $process.WaitForExit()
    $stdout = $stdoutBuilder.ToString().TrimEnd()
    $stderr = $stderrBuilder.ToString().TrimEnd()

    $entry = @(
        ('ExitCode: {0}' -f $process.ExitCode),
        'STDOUT:',
        $stdout,
        'STDERR:',
        $stderr
    ) -join "`n"

    Append-ResumeLogEntry -Text $entry
    Write-ResumeLog ('CPA finished with exit code {0}.' -f $process.ExitCode)
} catch {
    Write-ResumeLog ('Exception: {0}' -f $_.Exception.ToString())
    exit 1
}
