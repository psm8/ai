---
name: ps-anti-ai-slop-code-review
description: >
  Multi-skill backend code review orchestrating contribution-critique, SOLID, and anti-slop detection.
  Use when reviewing an external MR or local diff for merge-readiness and AI-slop removal. Outputs a detailed report and a paste-ready sum-up. Read-only — does not fix code.
argument-hint: What MR or local changes to review, and any specific areas to focus on
---

## Prerequisites

Install the skills this orchestrator delegates to:

```
npx skills add psm8/ai@ps-contribution-critique -g -y
npx skills add psm8/ai@ps-solid -g -y
npx skills add b4r7x/agent-skills@anti-slop -g -y
```

Optionally install a writing-style skill for report tone — the skill checks at runtime whether one is available and adapts.

## Quick start

- Use when reviewing backend code from an external MR or local changes for merge-readiness.
- Orchestrates `ps-contribution-critique`, `ps-solid`, and `b4r7x/agent-skills@anti-slop`.
- Read `AGENTS.md`, `README.md`, documentation, `docs/adr/` and `CONTEXT.md` (if existing) for shared language and naming before inventing new terms.

## Non-negotiable rules

1. Treat the target repo as read-only. Do not create or update issues, PRs, comments, branches, or remote refs.
2. Ground every claimed project pattern in code or docs citations from the target repo.
3. Do not flag something already scheduled in open issues or TODOs with ticket references.
4. Use project-specific naming from docs — never invent names.
5. Check whether a writing-style skill is available. If it is, use it. If not, write in direct, concise, teammate-to-teammate language — no corporate filler, no hedging, no AI-sounding phrasing.

## Workflow

1. Read the diff, touched files, adjacent patterns, and local docs (`AGENTS.md`, `README.md`, `docs/adr/`, `CONTEXT.md`).
2. Check open issues in the remote repo — do not flag something already scheduled.
3. Run the three review dimensions below. Merge findings into one report.
4. Write a detailed report to `ai-reports/<scope>-review-<date>.md`.
5. Write a sum-up file to `ai-reports/<scope>-sumup-<date>.md` — at most a few bullet points; can be 0 if nothing is worth mentioning. Paste-ready for the MR review.

### Dimension 1 — Merge-readiness (`ps-contribution-critique`)

Delegates to `ps-contribution-critique`.

### Dimension 2 — SOLID principles (`ps-solid`)

Delegates to `ps-solid`.

### Dimension 3 — Anti-slop (`b4r7x/agent-skills@anti-slop`)

Delegates to `b4r7x/agent-skills@anti-slop`. Flag **only** what the code under review introduces — do not flag pre-existing patterns in untouched code.

## Validation checklist

- [ ] Target repo stayed read-only
- [ ] Open issues checked — nothing flagged that is already scheduled
- [ ] Project-specific naming used from docs, not invented
- [ ] Writing-style skill checked and used if available, otherwise direct/concise tone
- [ ] Detailed report written to `ai-reports/`
- [ ] Sum-up file written to `ai-reports/` (can be empty/0 points)
