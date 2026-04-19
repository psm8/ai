# Change Decisions After `to-issues`

Use this guide when you find a bug, discover missing acceptance criteria, or want to change something after backlog issues already exist.

## Default operating model

- The parent feature issue is the live feature contract after `to-issues`.
- Child issues are the live implementation contracts.
- Project `Workflow State` is the lifecycle source of truth.
- The PR is proof that a change landed.
- Comments hold investigation notes and rationale; they do not replace scope.

If the original PRD markdown still exists, treat it as a planning artifact unless you are actively using it to reshape the backlog. Do not mirror every small implementation discovery back into the PRD.

## Quick decision table

| Situation | Action |
|---|---|
| Open issue, and the discovered problem is still part of the current acceptance criteria | Edit the existing issue and keep working in the same issue |
| Open issue, but the discovered problem is different work | Create a new issue and link it; block the current issue if needed |
| Closed issue, and the shipped result still fails the original acceptance criteria | Reopen the same issue |
| Closed issue, and you now want extra behavior that was never promised | Create a new follow-up issue |
| Product-level decision changes how multiple child issues should work | Edit the parent feature issue, then rescope or create child issues |
| Implementation approach changes, but user-visible scope does not | Keep the same issue; update body or comment only if the decision matters later |

## Edit the existing child issue when

Edit the existing issue body when the contract is the same but the issue needs to be clearer or more complete.

Typical cases:

- acceptance criteria were too vague
- a required edge case was discovered
- a blocker or dependency needs to be made explicit
- review revealed the issue is not actually done yet
- the implementation plan changed, but the promised outcome did not

Use the issue body for durable scope. Use comments for investigation details, tradeoffs, and links to evidence.

## Reopen the existing issue when

Reopen the same issue only when the original contract is still broken after the work was already considered done.

Typical cases:

- the PR merged, but the feature still fails one of the original acceptance criteria
- QA or manual testing found a regression in the exact behavior that issue claimed to deliver
- a partial fix was merged and the issue was closed too early

When reopening:

1. Add a comment naming the failed acceptance criterion.
2. Move Project `Workflow State` to `Reopened`.
3. Keep built-in `Status` coarse: `Todo` until work resumes, then `In Progress`.
4. Reuse the same issue number so history stays attached to the original promise.

## Create a new issue when

Create a new issue when the work is adjacent to the original issue, but not part of the same contract.

Typical cases:

- a new improvement idea appears during implementation
- review finds cleanup or refactor work that is not required to satisfy the current issue
- the real bug is in another slice or another subsystem
- you want additional UX or validation beyond the original acceptance criteria
- a dependency must be fixed elsewhere before the current issue can finish

When the new issue blocks the current one:

1. Create the new issue.
2. Link it as a dependency.
3. Move the blocked issue to `Blocked`.

Do not silently expand one issue until it becomes a vague mini-epic.

## Edit the parent feature issue or PRD when

Edit the parent feature issue when the feature-level contract changes for remaining work.

Typical cases:

- a user story changes in a way that affects multiple child issues
- a non-goal becomes in-scope, or an in-scope item becomes out-of-scope
- the feature decomposition needs extra child issues
- the order or dependency structure of remaining work changed materially
- you learned a product rule that future slices must follow

Edit the original PRD document only when you still use that PRD as an active planning artifact. If day-to-day execution now happens in GitHub issues, prefer updating the parent feature issue and keep the PRD for major product-level reshaping only.

## Simple rule of thumb

- Same promise, same issue.
- Same promise, but already closed: reopen.
- New promise: new issue.
- Feature-wide contract change: update the parent feature issue, then update the affected child issues.

## Anti-patterns

- Editing a closed issue to hide that the original contract failed
- Reopening a feature parent for a child-level bug when one child issue is the actual broken contract
- Packing unrelated cleanup, polish, and new scope into the current issue
- Using comments as the only place where real acceptance criteria live
- Marking an issue `Done` just because code exists locally or a comment says "implemented"
