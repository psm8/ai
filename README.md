# AI Infrastructure

Wrapper repository managing skills and utility scripts for AI-driven development.

## Contents

### `docs/`
Documentation files and installation guides.

### `.githooks/`
Git hooks for automation.

**Contents:**
- `pre-commit` — Auto-updates `docs/setup.md` when skills are added
- `update-setup-docs.ps1` — Script called by pre-commit hook

Configured via `git config core.hooksPath .githooks`.

### `skills/`
Agent skills (Claude Code, GitHub Copilot, Factory Droid), installed with `npx skills add psm8/ai --skill <name>`.

**Available skills:**

Code review and delivery:
- **ps-anti-ai-slop-code-review** — Multi-skill backend code review (contribution critique, SOLID, anti-slop detection) of an MR or local diff for merge-readiness and AI-slop removal. Read-only; outputs a detailed report and a paste-ready sum-up.
- **ps-contribution-critique** — Advisory, local-only critique of finished implementations against repo conventions, minimal integration, simplification, and historic-language cleanup.
- **ps-contribution-package** — Packages an approved critique into local-only issue drafts and a first-time-maintainer PR description without creating remote artifacts.
- **ps-autoloop** — Picks up open unclaimed issues, bundles related ones into one branch/MR, and runs independent ones in parallel with subagents.

Issue workflow:
- **ps-github-issue-lifecycle** — Manages a GitHub issue from triage to close using Issues, Projects V2, PR linkage, and safe close or reopen decisions.
- **ps-swarm-issue-delivery** — Delivers `Ready` GitHub issues through `swarm-orchestrator` with reviewed plans, PR review mode, and proof-based closure.

Writing and learning:
- **ps-jira-writing-style** — Writes Jira comments and updates in the user's internal team style while preserving technical wording.
- **ps-simple-short-analogy** — Answers a problem with one short everyday analogy instead of a detailed breakdown.
- **create-interactive-lesson** (`skills/ps-create-interactive-lesson/`) — Creates one self-contained interactive HTML lesson on a programming topic for senior interview prep.
- **rs-onboarding-pages-docs** — Turns screenshots, rollout notes, and implementation evidence into onboarding-focused static documentation pages.

### `scripts/`
Helper scripts for skill installation and session management.

**Available scripts:**
- `install-skills-glob.ps1` — PowerShell wrapper for installing skills with glob pattern matching
- `install-skills-glob.sh` — Bash wrapper for installing skills with glob pattern matching
- `install_resume_task.bat` — Creates Windows scheduled task for session resumption
- `resume_agent.ps1` — Gated resume flow for Copilot sessions with rate-limit handling, stall detection, and auto-recovery

See `scripts/README.md` for details.

## Setup

After cloning this repository, enable git hooks:

```powershell
git config --local include.path ../.gitconfig
```

This configures git to use `.githooks/` for all hooks in this repository.

## Usage

### Automatic skill documentation (recommended)

Once hooks are configured, they run automatically on every commit.

When you add new skills:
1. Add a new skill to `skills/` with SKILL.md frontmatter
2. Commit the change
3. Pre-commit hook auto-detects new skill
4. Hook updates `docs/setup.md` with install command: `npx skills add psm8/ai --skill name`
5. Commit includes updated docs/setup.md

### Manual skill documentation update

To update docs/setup.md manually:

```powershell
./.githooks/update-setup-docs.ps1
```

### View installation guide

See `docs/setup.md` for complete skill and agent installation instructions for new projects.

### Install skills with glob matching

**PowerShell:**
```powershell
./scripts/install-skills-glob.ps1 -RepoUrl "https://github.com/owner/repo" -Skill "pattern-*"
```

**Bash:**
```bash
bash scripts/install-skills-glob.sh https://github.com/owner/repo --skill 'pattern-*'
```

### Schedule session resumption

Create a Windows scheduled task for automatic session recovery:

```bat
scripts/install_resume_task.bat <session-id>
```

With custom prompt:
```bat
scripts/install_resume_task.bat <session-id> /fleet continue with work
```

## Creating Skills

All skills should include frontmatter at the top of `SKILL.md`:

```yaml
---
name: skill-name
description: "What this skill does"
---
```

When you commit a new skill with frontmatter:
1. Pre-commit hook automatically runs (via core.hooksPath)
2. Parses the skill frontmatter
3. Updates `docs/setup.md` with: `npx skills add psm8/ai --skill name`
4. Stages the updated `docs/setup.md`

This ensures `docs/setup.md` stays current with available skills in your repo.
