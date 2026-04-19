# Recommended Project Fields

Use one GitHub Project as the workflow source of truth for issue state.

For Projects V2, add issues and PRs with `gh project item-add`, not `gh issue edit --add-project`.

## Core fields

| Field | Type | Purpose |
|---|---|---|
| `Workflow State` | Single select (custom) | Rich lifecycle state |
| `Status` | Single select (built-in, optional) | Coarse progress only: `Todo`, `In Progress`, `Done` |
| `Priority` | Single select | Business or delivery urgency |
| `Iteration` | Iteration | Current or upcoming sprint or batch |
| `Estimate` | Number or single select | Relative effort or complexity |
| `Target Release` | Text or single select | Release bucket such as `v1` or `v2` |

## Recommended `Workflow State` values

| Workflow State | Meaning |
|---|---|
| `Backlog` | Captured but not reviewed yet |
| `Triaged` | Reviewed, but not yet ready to implement |
| `Ready` | Acceptance criteria are explicit and no unresolved blockers remain |
| `In Progress` | Actively being implemented |
| `Blocked` | Cannot move without another decision or dependency |
| `In Review` | Waiting on PR review, QA, or merge approval |
| `Done` | Landed and complete |
| `Reopened` | Previously closed, but the original contract still fails |
| `Not Planned` | Explicitly closed without implementation |

## Built-in `Status` values

| Status | Meaning |
|---|---|
| `Todo` | Open, but not actively being implemented |
| `In Progress` | Work is actively moving |
| `Done` | The issue is completed or intentionally closed |

Do not overload built-in `Status` with backlog, blocked, review, or reopened semantics.

## Default transition rules

1. `Backlog` -> `Triaged` after first review
2. `Triaged` -> `Ready` when acceptance criteria and blockers are clear
3. `Ready` -> `In Progress` when implementation begins
4. `In Progress` -> `In Review` when the PR is open and ready
5. `In Review` -> `Done` when the PR merges or the issue closes as completed
6. Any active state -> `Blocked` when a real dependency prevents progress
7. `Done` -> `Reopened` only when the original contract still fails
8. Any open state -> `Not Planned` when the work is intentionally dropped

## Single source of truth rules

- The issue body owns scope and acceptance criteria.
- The custom `Workflow State` field owns lifecycle.
- Built-in `Status` is coarse progress only, if you use it at all.
- The PR owns proof that the change landed.
- Labels describe area, release, risk, or cross-cutting metadata, not workflow state.

## CLI patterns

```powershell
# Add an issue or PR to the project
gh project item-add 1 --owner monalisa --url https://github.com/monalisa/myproject/issues/23

# List fields to resolve the Workflow State field ID and option IDs
gh project field-list 1 --owner monalisa --format json

# List items to resolve the project's item ID for this issue or PR
gh project item-list 1 --owner monalisa --limit 200 --format json

# Update Workflow State on the project item
gh project item-edit --id <item-id> --project-id <project-id> --field-id <workflow-field-id> --single-select-option-id <ready-id>
```

Keep `gh api graphql` for sub-issues and dependencies. Use `gh project ...` for Projects V2 membership and field edits.
