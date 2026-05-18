---
name: ps-contribution-package
description: Packages an approved contribution review into local-only maintainer handoff artifacts, including to-issues-style follow-up slices and a first-time-maintainer PR description. Use when a contribution has already been critiqued and you need advisory markdown outputs for a human to post manually without creating issues, PRs, comments, or pushes.
---

# Contribution Package

## Quick start

- Use this only after the critique is accepted or the user provides an equivalent reviewed summary.
- Default to chat-only output. If the user wants files, ask for a scratch directory outside the target repo.
- Package markdown only. Do not publish anything remotely.
- This skill is advisory only. See [SAFETY.md](SAFETY.md).

## Non-negotiable rules

1. Produce local markdown blocks or local files only.
2. Do not create or update issues, PRs, comments, branches, or remote refs.
3. Do not invent new scope that was not in the final implementation or approved design summary.
4. Keep follow-up slices thin, end-to-end, and manually postable by a human.
5. The maintainer-facing package must describe the final code and decisions, not the author's review process.
6. Lead with value, boundaries, and reviewer mental model before code detail.
7. Mention tests only as part of the final end state and only when they protect behavior worth maintaining.
8. Remove historic, temporary, and current-user-only framing unless it is still required for maintainers to understand risk.

## Workflow

1. Confirm the target repo path and the output mode: chat-only or safe scratch directory.
2. Read the final implementation summary, design rationale, and relevant docs.
3. If ambiguity remains, ask only the minimum blocking questions needed to explain the end state correctly.
4. Draft the issue pack in a `to-issues` style only when the user wants follow-up work captured separately; keep it local-only and explicitly human-posted.
5. Draft the maintainer-facing PR description around the shipped end state: what it is, why it exists, why the chosen design is simple and minimally invasive, and how to review it.
6. Return markdown blocks in chat, or write files only to the approved safe scratch directory such as `issues.md` and `pr-description.md`.

## Refusal pattern

If asked to open the PR, publish issues, add comments, or push to a fork, refuse and offer the packaged markdown instead.

```text
I can package the exact issue or PR text locally, but I will not publish it or push it to any remote. A human needs to do that final step.
```

## Advanced features

- Packaging rules: [REFERENCE.md](REFERENCE.md)
- Issue template: [ISSUE_TEMPLATE.md](ISSUE_TEMPLATE.md)
- PR template: [PR_TEMPLATE.md](PR_TEMPLATE.md)
- Safety rules: [SAFETY.md](SAFETY.md)
- Recommend `to-issues`, `requesting-code-review`, or similar skills by name only when the user explicitly wants a next step. Do not invoke them automatically.

## Validation checklist

- [ ] The output stayed local-only
- [ ] Follow-up slices are thin and independently understandable
- [ ] The PR description explains the final code and decisions to a first-time maintainer
- [ ] Minimal integration and design choices are explicit
- [ ] The package avoids critique history and author-process narration
- [ ] Mentioned tests have a strong end-state justification
- [ ] Historic and temporary language is removed unless still required
