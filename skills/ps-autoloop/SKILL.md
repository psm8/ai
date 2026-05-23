---
name: ps-autoloop
description: >
  Picks up open unclaimed issues from a repo, bundles related ones, and runs them in parallel using subagents.
  Use when the user wants to clear a backlog of issues, work through open issues in a repo, or hand off issue implementation to agents.
  Bundles connected issues into one branch/MR, parallels independent ones. Uses ps-solid-agent for extensive coding and ps-contribution-critique before MR.
argument-hint: Which repo to work on, and optionally which issues or areas to focus on
---

# ps-autoloop

## Prerequisites

- `gh` or gitlab mcp installed and authenticated
- `git` installed and authenticated
- `ps-solid-agent` available for extensive coding
- `ps-contribution-critique` available for pre-MR review

## Quick start

- Orchestrates: pick issues → bundle related ones → parallel independent ones → implement → review → commit → MR → comment.

## Non-negotiable rules

1. Never claim an issue with an assignee or "working on this" comment.
2. Follow DDD — bounded contexts, aggregates, domain language from docs and code.
3. Test frequently. Not all-code-then-once-at-end.
4. Run `ps-contribution-critique` before MR.
5. Detect and follow agentic harness hooks and git hooks before committing. Read them upfront and satisfy their requirements.
6. Conventional commits.
7. Sum up in MR description + issue comment.

## Workflow

1. List open issues. Filter: skip if assignee exists or comment claims work in progress.
2. Bundle related issues. Group issues that touch the same area/feature into one branch and MR. Keep independent issues on separate branches — they run in parallel.
3. For each bundle or independent issue: read issue body, acceptance criteria, linked context. Read `AGENTS.md`, `README.md`, `CONTEXT.md`, `docs/adr/`, existing code for domain language.
4. Detect agentic harness hooks and git hooks. Harness hooks are lifecycle hooks registered by plugins that intercept the agent at `preToolUse`, `subagentStop`, `sessionStart`, etc. Git hooks are in `.githooks/`, `.husky/`, or `core.hooksPath`. Scan both, read their requirements, and satisfy them before committing.
5. Branch: `<type>/<issue-1name>-<issue-2name>-<brief-desc>` where type is `feat|fix|misc|docs|refactor|test|chore`. E.g. `feat/issue-42-add-user-api`, `fix/issue-15-17-login-and-session-timeout`.
6. Implement in parallel where possible:
   - Independent issues → launch separate `ps-solid-agent` subagents concurrently.
   - Bundled issues → single subagent or direct implementation.
   - Test after each meaningful change.
7. Review: run `ps-contribution-critique` on each diff. Fix flagged items.
8. Commit: conventional commits. Satisfy harness hook requirements.
9. Push + create MR/PR per bundle. Description summarizes what was done and lists all bundled issues.
10. Comment on each issue with summary + MR link.
11. Loop to step 2 for next batch.

## Bundle logic

- Issues sharing a domain/feature/area → one branch, one MR.
- Independent issues → separate branches, separate MRs, run in parallel.
- Use judgment: a `docs` fix and a `feat` addition in the same area can bundle; a backend fix and a frontend refactor probably should not.

## Loop control

- Report after each batch: issue numbers, summaries, MR links.
- Too large/blocked → skip, note why, next.
- Tests fail repeatedly → stop and report. No broken code pushes.

## Anti-patterns

- Claiming in-progress issues
- Running issues one-by-one when they could be parallel
- Bundling unrelated issues into one MR
- Ignoring harness/git hooks then failing CI
- All code then one test run
- Skipping pre-MR review
- Non-conventional commits
- Closing issue without merged proof

## Validation checklist

- [ ] No claimed issues taken
- [ ] Related issues bundled, independent ones parallelized
- [ ] DDD followed
- [ ] Tests ran frequently
- [ ] `ps-contribution-critique` passed before MR
- [ ] Harness hooks and git hooks detected and satisfied
- [ ] Conventional commits used
- [ ] MR description summarizes work and lists bundled issues
- [ ] Issue comments posted
