# Local PR Description Template

Use this only as local markdown for a human to post manually.

Lead with value and reviewer mental model before implementation detail.

```md
## Summary

One short paragraph on what changed.

## Why this matters

What user or maintainer problem this solves.

## Code shape

- The main pieces introduced or changed in the final design
- How those pieces fit together
- Where a reviewer should anchor their reading

## Design choices

- Which seam, domain object, adapter, or composition point was chosen
- Why this shape is simple enough for the problem
- Why broader or more invasive alternatives were intentionally not taken

## Tests worth carrying

- Test 1: what it protects and why that drift matters
- Test 2: what it protects and why that drift matters

## Reviewer guide

- Where to start reading
- How to verify behavior
- What is intentionally out of scope
- How to revert safely if needed
```
