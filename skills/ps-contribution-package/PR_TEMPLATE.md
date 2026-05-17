# Local PR Description Template

Use this only as local markdown for a human to post manually.

Lead with value and reviewer mental model before implementation detail.

```md
## Summary

One short paragraph on what changed.

## Why this matters

What user or maintainer problem this solves.

## What changed

- Item 1
- Item 2
- Item 3

## Why this integrates minimally

- Which new seam, domain object, adapter, or composition point was introduced
- Which existing files changed and why each change is unavoidable
- Which broader refactors were intentionally not taken on

## Simplifications made before review

- Removed temporary or history-driven naming
- Deleted migration-only comments or contributor-specific notes
- Collapsed unnecessary branches, wrappers, or flags

## Reviewer guide

- Where to start reading
- How to verify behavior
- What is intentionally out of scope
- How to revert safely if needed
```
