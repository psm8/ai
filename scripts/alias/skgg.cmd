@echo off
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\ReposPrivate\Infra\ai\install-skills-glob.ps1" %* -g -a droid,github-copilot,claude-code -y
