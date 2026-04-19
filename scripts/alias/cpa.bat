@echo off
REM Wrapper to launch copilot with default options
copilot %* --allow-all-paths --allow-all-tools --autopilot --model=gpt-5.4 --effort=xhigh
