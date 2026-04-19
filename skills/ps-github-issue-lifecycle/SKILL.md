---
name: ps-github-issue-lifecycle
description: Manages a GitHub issue from triage to close using Issues, Projects V2, pull requests, and optional swarm delivery. Use when normalizing PRD-generated issues, setting Workflow State, linking PRs, reopening or closing issues, or preparing ready work for swarm. Ensures acceptance criteria are explicit, lifecycle state is accurate, and PR linkage reflects full vs partial delivery.
---

# GitHub Issue Lifecycle

## Quick start

- Treat the issue body and acceptance criteria as the contract.
- Keep lifecycle in the Project's custom `Workflow State` field.
- Treat the PR as proof that the work landed.
- If the issue is already `Ready` and implementation will run through swarm, switch to `ps-swarm-issue-delivery`.

## Prerequisites

- `gh` installed and authenticated
- Access to the target repository and its GitHub Project, if one is used
- Issue body, comments, linked PRs, and recent related changes available for review
- If swarm will be used later: Node.js 20+, `git`, and a local swarm checkout

## Workflow

1. Read the issue body, comments, labels, linked PRs, and recent related changes.
2. Tighten acceptance criteria and make blockers explicit.
3. Set one real lifecycle state in `Workflow State` such as `Ready`, `Blocked`, or `In Progress`.
4. Build implementation from the acceptance criteria, not from the title alone.
5. Open a PR with `Closes #<issue>` only when it fully resolves the contract; otherwise use partial linkage.
6. Move `Workflow State` to `In Review`, then merge and mark `Done` only when the merged result satisfies the contract.
7. Reopen the same issue only when the merged result still fails the original contract; create a new issue for new scope.

## Command patterns

```powershell
gh issue edit 123 --add-assignee "@me" --add-label "area:stash"
gh project item-add 1 --owner monalisa --url https://github.com/monalisa/myproject/issues/123
gh project field-list 1 --owner monalisa --format json
gh project item-edit --id <item-id> --project-id <project-id> --field-id <workflow-field-id> --single-select-option-id <in-review-id>
gh pr edit 456 --body "Closes #123`n`n<existing body>"
gh issue close 123 --reason completed --comment "Merged in #456."
```

## Advanced features

- Project field model: [references/project-fields.md](references/project-fields.md)
- Reopen vs follow-up decisions: [references/change-decisions.md](references/change-decisions.md)
- Use `ps-swarm-issue-delivery` once the issue is truly `Ready` and execution should be delegated

## Anti-patterns

- Using labels as workflow state
- Using built-in `Status` as the rich lifecycle field
- Closing issues because code exists locally
- Merging PRs without explicit issue linkage
- Sending blocked or unclear work to swarm

## Validation checklist

- [ ] Acceptance criteria are explicit
- [ ] `Workflow State` reflects the real lifecycle
- [ ] PR linkage matches full vs partial delivery
- [ ] Close or reopen decision matches the original contract
- [ ] Project or dependency links exist where needed
