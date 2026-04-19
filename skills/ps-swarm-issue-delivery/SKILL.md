---
name: ps-swarm-issue-delivery
description: Delivers a GitHub issue through swarm-orchestrator with explicit issue context, reviewed plans, PR review mode, MCP evidence, and safe close or reopen rules. Use when a GitHub issue is already `Ready` (triaged, acceptance criteria explicit, Workflow State set) and implementation should run via a local swarm checkout instead of direct session. Produces reviewed plan, PR, and evidence before merging.
---

# Swarm Issue Delivery

## Quick start

- Use this only for issues that are already triaged and `Ready`.
- Build the swarm goal from issue number and acceptance criteria, not from the title alone.
- Review the generated plan before execution.
- Deliver through a PR review flow and close the issue only from merged proof.

## Do Not Use This Skill When

- The issue is still ambiguous or blocked
- The work is tiny enough for a direct implementation session
- There is no local swarm checkout or no GitHub CLI auth

## Prerequisites

- Issue `Workflow State = Ready`
- `gh`, `git`, Node.js 20+, and a supported agent CLI installed
- Local swarm checkout available
- Target repo path and stable acceptance criteria known

## Workflow

1. Read the issue body, comments, blockers, and linked PRs.
2. Condense acceptance criteria and explicit non-goals.
3. Build a goal that includes repo, issue number, title, acceptance criteria, and PR delivery.
4. Run `swarm bootstrap` against the target repo and review the generated plan.
5. Execute with safe defaults such as `--pr review --mcp --governance --strict-isolation`.
6. Fix PR issue linkage if needed: use `Closes #<issue>` only when the PR fully resolves the contract.
7. Merge only after review; mark `Done` only when the merged result satisfies the contract. Reopen the same issue if the original contract still fails.

## Command patterns

```powershell
swarm bootstrap "C:\path\to\target-repo" "Implement issue #123: ..."
swarm swarm plan.json --pr review --mcp --governance --strict-isolation
gh pr edit <pr-number> --body "Closes #123`n`n<existing body>"
```

## Advanced features

- Use `ps-github-issue-lifecycle` first for triage, project normalization, and close or reopen decisions
- Keep the issue open when delivery is partial or acceptance criteria are not fully met

## Anti-patterns

- Pointing swarm at its own repo instead of the target repo
- Passing only the issue title
- Trusting local implementation without PR-backed proof
- Auto-closing partial work

## Validation checklist

- [ ] The issue is genuinely `Ready`
- [ ] Goal text includes issue number and acceptance criteria
- [ ] The generated plan was reviewed before execution
- [ ] PR linkage matches full vs partial delivery
- [ ] Close or reopen decision matches the merged result
