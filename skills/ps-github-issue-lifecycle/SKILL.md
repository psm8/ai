---
name: ps-github-issue-lifecycle
description: Manages a GitHub issue from triage to close using Issues, Projects V2, pull requests, and optional swarm delivery. Use when normalizing PRD-generated issues, adding sub-issues or dependencies, setting Workflow State, linking PRs, reopening or closing issues, or preparing truly Ready work for swarm. Keeps acceptance criteria explicit, lifecycle state accurate, and PR linkage aligned with full vs partial delivery.
---

# GitHub Issue Lifecycle

## Quick start

- Treat the issue body and acceptance criteria as the contract.
- Keep lifecycle in the Project's custom `Workflow State` field, not in labels or comments.
- Treat the PR as proof that the work landed.
- If the issue is already `Ready` and implementation will run through swarm, switch to `ps-swarm-issue-delivery`.

## Prerequisites

- `gh` installed and authenticated
- Access to the target repository and its GitHub Project, if one is used
- Issue body, comments, linked PRs, and recent related changes available for review
- If swarm will be used later: Node.js 20+, `git`, and a local swarm checkout

## Non-negotiable rules

1. Use the issue body for durable scope and acceptance criteria.
2. Use Project `Workflow State` for the real lifecycle.
3. If built-in `Status` exists, keep it coarse only: `Todo`, `In Progress`, `Done`.
4. Use labels for area, release, or metadata, not for workflow state.
5. Use `Closes #<issue>` only when the PR fully resolves the contract on the default branch.
6. Do not close an issue because code exists locally or because someone commented "implemented".
7. Reopen the same issue only when the shipped result still fails the original contract. New scope gets a new issue.

## Workflow

1. Read the issue body, comments, labels, linked PRs, and recent related changes.
2. Tighten acceptance criteria and make blockers explicit.
3. Add sub-issues or blocked-by links when the issue is too large or depends on other work.
4. Set one real lifecycle state in `Workflow State` such as `Ready`, `Blocked`, `In Progress`, or `In Review`.
5. Build implementation from the acceptance criteria, not from the title alone.
6. Open a PR with `Closes #<issue>` only when it fully resolves the contract; otherwise use partial linkage.
7. Move `Workflow State` to `In Review`, then merge and mark `Done` only when the merged result satisfies the contract.
8. Reopen the same issue only when the merged result still fails the original contract; create a new issue for new scope.

## Command patterns

```powershell
# Edit issue metadata; do not use --add-project for Projects V2
gh issue edit 123 --add-assignee "@me" --add-label "area:stash"

# Add an issue to a Projects V2 board
gh project item-add 1 --owner monalisa --url https://github.com/monalisa/myproject/issues/123

# Discover field IDs and option IDs
gh project field-list 1 --owner monalisa --format json

# Discover the project item ID for an issue or PR
gh project item-list 1 --owner monalisa --limit 200 --format json

# Update Workflow State on the project item
gh project item-edit --id <item-id> --project-id <project-id> --field-id <workflow-field-id> --single-select-option-id <in-review-id>

# Close or reopen with an explicit reason
gh issue close 123 --reason completed --comment "Merged in #456."
gh issue reopen 123 --comment "Reopening: acceptance criterion 3 still fails on the default branch."

# Fix PR linkage when needed
gh pr edit 456 --body "Closes #123`n`n<existing body>"
```

Use `gh project ...` for Projects V2 membership and field edits. Use `gh api graphql` (or equivalent GitHub tooling) for sub-issue links and issue dependencies.

## Advanced features

- Project field model: [references/project-fields.md](references/project-fields.md)
- Reopen vs follow-up decisions: [references/change-decisions.md](references/change-decisions.md)
- Use `ps-swarm-issue-delivery` once the issue is truly `Ready` and execution should be delegated

## Anti-patterns

- Using labels as workflow state
- Using built-in `Status` as the rich lifecycle field
- Using `gh issue edit --add-project` for Projects V2
- Closing issues because code exists locally
- Merging PRs without explicit issue linkage
- Reopening a closed issue to add new scope instead of tracking it separately
- Sending blocked or unclear work to swarm

## Validation checklist

- [ ] Acceptance criteria are explicit
- [ ] `Workflow State` reflects the real lifecycle
- [ ] Built-in `Status`, if used, stays coarse
- [ ] PR linkage matches full vs partial delivery
- [ ] Close or reopen decision matches the original contract
- [ ] Project, sub-issue, and dependency links exist where needed
