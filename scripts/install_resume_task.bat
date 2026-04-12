@echo off
REM Install scheduled task to run resume_agent.ps1 every 2 hours for a specific session.
SETLOCAL EnableExtensions

SET "SCRIPT=%~dp0resume_agent.ps1"
SET "SESSION_ID=%~1"
SET "DEFAULT_PROMPT=/fleet continue with remaining github issues, use ps-solid-agent for implementation and review, verify and document ui changes with screenshots, test frequenty, iterate until everything looks fine, comment in github, when you think the issue is implemented, then commit the changes after each issue finished"

IF "%SESSION_ID%"=="" (
  echo Usage: %~nx0 SESSION_ID [PROMPT]
  echo Example:
  echo   %~nx0 87abb67d-847e-48a5-a37f-7a2c863f7320
  exit /b 1
)

SHIFT
SET "PROMPT=%*"
IF NOT DEFINED PROMPT SET "PROMPT=%DEFAULT_PROMPT%"

IF NOT "%PROMPT%"=="" IF "%PROMPT:~0,1%"=="\"" IF "%PROMPT:~-1%"=="\"" SET "PROMPT=%PROMPT:~1,-1%"
SET "PROMPT_ESCAPED=%PROMPT:"=\"%"
SET "SESSION_ID_ESCAPED=%SESSION_ID:"=\"%"
SET "TASK_NAME=ResumeCopilotAgent-%SESSION_ID%"

schtasks /Create /SC HOURLY /MO 2 /TN "%TASK_NAME%" /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%SCRIPT%\" -SessionId \"%SESSION_ID_ESCAPED%\" -Prompt \"%PROMPT_ESCAPED%\"" /F

IF %ERRORLEVEL% EQU 0 (
  echo Scheduled task created/updated: %TASK_NAME%
  echo SessionId: %SESSION_ID%
  echo To remove: schtasks /Delete /TN "%TASK_NAME%" /F
) ELSE (
  echo Failed to create scheduled task. Error %ERRORLEVEL%
)

ENDLOCAL
