---
name: ps-contribution-critique
description: Interviews a human and critiques a finished implementation for merge-readiness against repo conventions, minimal integration, DDD-friendly composition, simplification, and cleanup of historic or temporary language. Use when implementation is done in a repo you do not control and you need a local-only advisory review before a human opens issues or a PR.
---

# Contribution Critique

## Quick start

- Use this after implementation exists and before a human opens issues or a PR in the target repo.
- Default to chat-only output. If the user wants files, ask for a scratch directory outside the target repo.
- Read the code and diff first. Ask only the blocking gray-area questions that the code cannot answer.
- Prefer short advisory bash or classic cmd snippets for churn context instead of dedicated helper scripts.
- This skill is advisory only. See [../ps-contribution-common/SAFETY.md](../ps-contribution-common/SAFETY.md).

## Non-negotiable rules

1. Treat the target repo as read-only during this skill.
2. Do not create or update issues, PRs, comments, branches, or remote refs.
3. Do not edit files in the target repo working tree.
4. Ground every claimed project pattern in code or docs citations from the target repo.
5. Prefer new domain seams and composition when they reduce churn, but explicitly test whether a smaller surgical edit is actually better.
6. Ask at most five blocking questions, one at a time, and stop early when the remaining ambiguity no longer changes the recommendation.

## Workflow

1. Confirm the target repo path and the output mode: chat-only or safe scratch directory.
2. Read the relevant diff, touched files, adjacent patterns, and local docs.
3. Build a convention-evidence table with concrete citations.
4. Identify only the unresolved gray areas, then ask one blocking question at a time with a recommended answer.
5. Produce the critique pack:
   - minimal-integration map
   - diff-size budget for existing vs new files
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
- Safety rules: [../ps-contribution-common/SAFETY.md](../ps-contribution-common/SAFETY.md)
- After the critique is accepted, use `ps-contribution-package` for local-only issue and PR artifacts.

## Validation checklist

- [ ] The target repo stayed read-only
- [ ] Every claimed project pattern is backed by citations
- [ ] Gray-area questions stopped once the critique was decision-ready
- [ ] Existing-code churn is explicitly measured and justified
- [ ] Temporary, historic, and user-specific language is flagged for removal
