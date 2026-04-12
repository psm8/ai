# Scripts

This directory contains helper scripts for two tasks:
- Installing skills from a repository with glob-style skill matching.
- Installing and running a Windows-based resume flow for a Copilot session.

## Files

### install-skills-glob.ps1
PowerShell wrapper for `npx skills add`.

What it does:
- Lists skills from a repository with `npx skills add <repo> --list`.
- Matches one or more PowerShell glob patterns passed through `-Skill`.
- Supports `-Adapter`, `-Yes`, `-Global`, `-DryRun`, and extra trailing arguments.
- Installs each matched skill and prints a success or failure summary.

### install-skills-glob.sh
Bash wrapper for `npx skills add`.

What it does:
- Lists skills from a repository with `npx skills add <repo> --list`.
- Matches one or more Bash glob patterns passed through `--skill`.
- Supports `--adapter`, `--yes`, `--global`, `--dry-run`, and extra trailing arguments.
- Installs each matched skill and prints a success or failure summary.

### install_resume_task.bat
Windows batch script that creates or updates a scheduled task for one session.

What it does:
- Requires a session ID as the first argument.
- Accepts an optional prompt override as the remaining arguments.
- Creates or updates a task named `ResumeCopilotAgent-<session-id>`.
- Runs `resume_agent.ps1` every 2 hours through `powershell.exe`.

### resume_agent.ps1
PowerShell runner for a gated Copilot resume flow.

What it does:
- Requires `-SessionId`.
- Accepts `-Prompt`, `-DryRun`, and `-AgentPath`.
- Resolves the target repository and working directory from the session metadata, with a git remote fallback.
- Queries open GitHub issues with `gh`.
- Keeps only issues that contain `Acceptance Criteria`, have zero comments, do not start with `PRD:`, `Spec:`, or `RFC:`, and do not carry the `prd`, `spec`, or `design-doc` labels.
- Treats the session as active when a session lock points to a live process, when a lock cannot be validated safely, or when recent non-terminal session events exist. Ignores stale locks whose PIDs are no longer running.
- Reads rate-limit events from the session event log and skips execution until the cooldown expires.
- Starts `cpa.bat` only after all checks pass.
- Appends decisions, skip reasons, and CPA output to `resume_agent.log`.

### resume_agent.log
Text log file written by `resume_agent.ps1`.

## Requirements

For `install-skills-glob.ps1` and `install-skills-glob.sh`:
- `npx`
- A `skills` command that is available through `npx skills add`

For `install_resume_task.bat` and `resume_agent.ps1`:
- Windows Task Scheduler
- PowerShell
- `gh`
- `git`
- `cpa.bat` in `PATH`, or an explicit `-AgentPath` value when running `resume_agent.ps1`

### What `cpa.bat` is
This is the wrapper expected by `resume_agent.ps1`:

```bat
@echo off
REM Wrapper to launch copilot with default options
copilot %* --allow-all-paths --allow-all-tools --autopilot --model=gpt-5.4
```

`resume_agent.ps1` resolves `cpa.bat` from `PATH` by default, or uses `-AgentPath` when provided. If it cannot find the wrapper, it exits with a configuration error instead of attempting a resume.

## Usage

### Install skills from a repository with glob matching
PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-skills-glob.ps1 -RepoUrl "https://github.com/example/repo" -Skill "core-*" -Adapter codex -DryRun
```

Bash:

```bash
bash scripts/install-skills-glob.sh https://github.com/example/repo --skill 'core-*' --adapter codex --dry-run
```

### Install the scheduled resume task for a session
```bat
scripts/install_resume_task.bat 87abb67d-847e-48a5-a37f-7a2c863f7320
```

### Install the scheduled resume task with a custom prompt
```bat
scripts/install_resume_task.bat 87abb67d-847e-48a5-a37f-7a2c863f7320 /fleet continue with remaining github issues
```

### Run the resume script without starting CPA
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/resume_agent.ps1 -SessionId 87abb67d-847e-48a5-a37f-7a2c863f7320 -DryRun
```

## Checking Scheduled Tasks

To verify how many `ResumeCopilotAgent` tasks are currently scheduled, use one of these methods:

### Using PowerShell (Recommended)
Count all scheduled resume tasks:
```powershell
(Get-ScheduledTask -TaskName "ResumeCopilotAgent-*" | Measure-Object).Count
```

List all tasks with status and timing information:
```powershell
Get-ScheduledTask -TaskName "ResumeCopilotAgent-*" | Select-Object TaskName, State, @{Name="NextRunTime";Expression={$_.NextRunTime}}, @{Name="LastRunTime";Expression={$_.LastRunTime}}
```

### Using Command Prompt
List all scheduled resume tasks:
```cmd
schtasks /Query /FO TABLE | findstr "ResumeCopilotAgent"
```

Get detailed information for a specific task:
```cmd
schtasks /Query /TN "ResumeCopilotAgent-87abb67d-847e-48a5-a37f-7a2c863f7320" /V /FO LIST
```

### Removing a Scheduled Task
If you need to delete a scheduled task:

PowerShell:
```powershell
Unregister-ScheduledTask -TaskName "ResumeCopilotAgent-87abb67d-847e-48a5-a37f-7a2c863f7320" -Confirm:$false
```

Command Prompt:
```cmd
schtasks /Delete /TN "ResumeCopilotAgent-87abb67d-847e-48a5-a37f-7a2c863f7320" /F
```
