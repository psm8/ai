# Contribution Critique Reference

## Inputs to confirm

1. Target repo path
2. Current diff, patch, or implementation summary
3. Relevant docs or ADRs, if any
4. Output mode: chat-only or safe scratch directory outside the target repo

## Analysis order

1. Read the implementation and touched files.
2. Find comparable patterns already used in the target repo.
3. Measure how much existing code was changed versus how much was added.
4. Look for places where a new domain seam or composition point would reduce churn.
5. Scan for temporary, historic, or user-specific language that should not ship.
6. Ask only the gray-area questions that still change the recommendation.

## Advisory diff stats snippets

Do not add a dedicated helper script by default. These are rough report-only snippets for critique or PR prose.

Run them from the target repo root. Prefer bash on Unix-like systems and classic `cmd` on Windows.

### Bash

```bash
BASE="${BASE:-origin/main}"

echo "New files:"
git diff --name-only --diff-filter=A "$BASE"...HEAD

echo
echo "Touched existing files:"
git diff --name-only --diff-filter=CDMRTUXB "$BASE"...HEAD

echo
echo "Summary for existing files:"
git diff --shortstat --diff-filter=CDMRTUXB "$BASE"...HEAD

echo
echo "Per-file line stats for existing files:"
git diff --numstat --diff-filter=CDMRTUXB "$BASE"...HEAD
```

### Windows cmd

```cmd
@echo off
set BASE=origin/main

echo New files:
git diff --name-only --diff-filter=A %BASE%...HEAD

echo.
echo Touched existing files:
git diff --name-only --diff-filter=CDMRTUXB %BASE%...HEAD

echo.
echo Summary for existing files:
git diff --shortstat --diff-filter=CDMRTUXB %BASE%...HEAD

echo.
echo Per-file line stats for existing files:
git diff --numstat --diff-filter=CDMRTUXB %BASE%...HEAD
```

## Suggested question tracks

Ask one question at a time. Stop once the critique is actionable.

### Pattern fit

- Which existing feature or module is the closest precedent?
- Is the current naming aligned with the repo glossary?
- Is any new abstraction solving a real repeated problem, or only this patch?

### Integration surface

- Which edits to preexisting files are strictly required?
- Can any of those edits be replaced with composition, adapters, registration, or configuration seams?
- Is a smaller invasive change actually better than introducing a new domain seam here?

### Simplification

- Which code paths, flags, wrappers, or indirections can be removed without losing behavior?
- Which explanation only exists because the implementation is more complex than necessary?

### Test value

- Which tests would catch a real bug if behavior drifted?
- Which tests are only re-stating the implementation and are likely to break on harmless refactors?
- Which tests no longer protect an important behavior and should be removed before review?
- For each important test, can you say in one sentence what it enforces and why that drift would matter?
- Are there too many local-confidence tests compared to the small set worth asking maintainers to carry?

### Language cleanup

- Are there migration notes, "for now" comments, or history-driven names that should disappear before review?
- Are there comments or sections written for the current contributor instead of future maintainers?

## Critique pack template

### 1. Convention evidence

| Concern | Existing pattern | Citation | Implication |
| --- | --- | --- | --- |
| Naming | `FeatureX` uses term Y | `path:line` | Prefer the same term here |

### 2. Minimal-integration map

- **New domain or seam:** what should be introduced
- **Composition points:** where existing code should be reused without deeper edits
- **Unavoidable existing-file edits:** each file plus one-line justification

### 3. Diff-size budget

| Bucket | Count | Notes |
| --- | --- | --- |
| New files | N | |
| Existing files touched | N | |
| Existing lines added | N | |
| Existing lines removed | N | |

Call out any touched existing file that looks avoidable.

### 4. Simplification pass

- Remove:
- Inline:
- Rename:
- Delete:

### 5. Test value review

| Test or test group | Keep / rewrite / remove | Why it is worth enforcing | Drift or bug it would catch | Brittleness risk |
| --- | --- | --- | --- | --- |
| `test name` | Keep | Protects real behavior | Would fail if X drifted | Low |

Strong defaults:

- Keep tests that verify user-visible behavior, invariants, integration seams, or previously broken flows.
- Rewrite tests that are aimed at the right behavior but coupled to internals.
- Remove tests that mostly mirror implementation shape, duplicate stronger coverage, or no longer protect a meaningful risk.
- If you cannot explain in one sentence what a test protects and why that drift matters, do not carry it into PR unchanged.

### 6. Temporary or historic language scan

| Phrase or pattern | Location | Recommended cleanup |
| --- | --- | --- |
| `for now` | `path:line` | Replace with the final intent or remove |

### 7. Recommendation summary

- **Keep:** what is already maintainer-friendly
- **Change before review:** blocking cleanup
- **Optional follow-up:** good but not merge-blocking
- **Open questions:** only the unresolved items that still matter
