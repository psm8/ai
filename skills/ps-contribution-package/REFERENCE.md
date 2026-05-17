# Contribution Package Reference

## Inputs to confirm

1. Target repo path
2. Approved critique or equivalent reviewed summary
3. Output mode: chat-only or safe scratch directory outside the target repo

## Local-only issue pack rules

Mirror the spirit of `to-issues`, but do not publish anything.

1. Prefer tracer-bullet vertical slices over layer-by-layer tickets.
2. Mark slices as `AFK` or `HITL` when that distinction helps the human decide what can move independently.
3. Keep blockers explicit.
4. Publish nothing. The output is only a local package for a human to post manually.

## Maintainer-facing writing defaults

1. Lead with purpose and value before implementation detail.
2. Explain the reviewer mental model before walking file-by-file.
3. Keep integration boundaries and non-goals explicit.
4. Remove historic, temporary, and contributor-specific framing unless it still explains real risk.
5. Assume the maintainer has not seen the prior conversation.

## Template files

- Issue drafts: [ISSUE_TEMPLATE.md](ISSUE_TEMPLATE.md)
- PR description: [PR_TEMPLATE.md](PR_TEMPLATE.md)

## Reusing churn stats

If the PR description benefits from churn context, prefer reusing the critique pack first.

If that summary is missing, reuse the short advisory bash or classic `cmd` snippets in [../ps-contribution-critique/REFERENCE.md](../ps-contribution-critique/REFERENCE.md) instead of adding a dedicated helper script.

## Numbered slice summary

Start the issue pack with a numbered list:

1. **Title**
2. **Type**: AFK or HITL
3. **Blocked by**
4. **Why this slice exists**

## First-time-maintainer checklist

- Can a maintainer understand the value without prior conversation context?
- Are repo-specific patterns cited rather than assumed?
- Is the minimal-integration story explicit?
- Are tests or verification steps named clearly?
- Are non-goals explicit so reviewers do not infer extra scope?
