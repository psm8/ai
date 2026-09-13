---
name: ps-contribution-critique
description: Interviews a human and critiques a finished implementation for merge-readiness against repo conventions, minimal integration, DDD-friendly composition, simplification, and cleanup of historic or temporary language. Use when implementation is done in a repo you do not control and you need a local-only advisory review before a human opens issues or a PR.
---

# Contribution Critique

## Quick start

- Use this after implementation exists and before a human opens issues or a PR in the target repo.
- Default to chat-only output. If the user wants files, ask for a scratch directory outside the target repo.
- Select the review input first: branch, staged index, or supplied patch. Read that exact code/diff; ask only blocking gray-area questions.
- Use the reference's report-only stats against the same input, in the environment's native shell.
- This skill is advisory only. See [SAFETY.md](SAFETY.md).

## Non-negotiable rules

1. Treat the target repo as read-only during this skill.
2. Do not create or update issues, PRs, comments, branches, or remote refs.
3. Do not edit files in the target repo working tree.
4. Ground every claimed project pattern in code or docs citations from the target repo.
5. Prefer new domain seams and composition when they reduce churn, but explicitly test whether a smaller surgical edit is actually better.
6. Treat stale, low-signal, or refactor-brittle tests as pre-PR problems, not harmless extras.
7. If a kept test cannot justify its purpose, failure mode, and maintenance cost, the change is not ready for PR.
8. Ask at most five blocking questions, one at a time, and stop early when the remaining ambiguity no longer changes the recommendation.

## Workflow

1. Confirm the target repo, output mode, and [selected review input](REFERENCE.md#selected-review-input). Record its base/tip or patch identity before reading.
2. Read the selected diff and corresponding file versions, then adjacent patterns and local docs. Keep unstaged/unrelated work outside the contribution.
3. Build a convention-evidence table with concrete citations.
4. Identify only the unresolved gray areas, then ask one blocking question at a time with a recommended answer.
5. Produce the critique pack:
   - minimal-integration map
   - diff-size budget for existing vs new files
   - test-value review covering which tests earn their keep and which should be removed or rewritten
   - simplification opportunities
   - temporary or historic language scan
   - unavoidable existing-code touchpoints with justification
   - maintainer risks, open questions, and recommended next changes
6. Return markdown blocks in chat, or write files only to the approved safe scratch directory.

## Refusal pattern

If asked to open a PR, create issues, comment remotely, or push code, refuse and offer a local draft instead.

```text
I can critique the implementation and draft the exact follow-up text locally, but I will not create or publish anything in the target repo.
```

## Advanced features

- Critique outputs and interview tracks: [REFERENCE.md](REFERENCE.md)
- Advisory diff stats snippets live in the reference file; keep them report-only
- Safety rules: [SAFETY.md](SAFETY.md)
- After the critique is accepted, use `ps-contribution-package` for local-only issue and PR artifacts.

## Validation checklist

- [ ] The target repo stayed read-only
- [ ] Every claimed project pattern is backed by citations
- [ ] Gray-area questions stopped once the critique was decision-ready
- [ ] Diff, file versions, citations, and churn use one recorded input; it remained unchanged through review
- [ ] Weak, stale, or refactor-brittle tests are explicitly called out
- [ ] Every kept test has a clear purpose and real failure mode worth maintaining
- [ ] Temporary, historic, and user-specific language is flagged for removal
