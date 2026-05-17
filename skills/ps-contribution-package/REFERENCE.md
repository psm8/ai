# Contribution Package Reference

## Inputs to confirm

1. Target repo path
2. Final implementation summary and design rationale
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
4. Explain only the final design choices and why they are simple, minimally invasive, and worth the trade-off.
5. Be selective about tests: mention only the ones that protect real behavior or important drift.
6. Remove critique history, temporary framing, and contributor-specific narration.
7. Assume the maintainer has not seen the prior conversation.

## Template files

- Issue drafts: [ISSUE_TEMPLATE.md](ISSUE_TEMPLATE.md)
- PR description: [PR_TEMPLATE.md](PR_TEMPLATE.md)

## End-state boundary

The maintainer-facing package is not a changelog of how the author got there.

- Do not explain what was simplified during authoring.
- Do not mention removed candidate tests, discarded approaches, or prior internal review passes.
- Do explain the chosen shape of the code, the key trade-offs, and why broader changes were intentionally avoided.
- Do explain only the final tests that remain and why they are worth keeping.

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
- Are the final design choices explained without narrating the author's process?
- Are tests or verification steps named clearly?
- Does each mentioned test have a clear purpose and a real failure mode worth maintaining?
- Are non-goals explicit so reviewers do not infer extra scope?
