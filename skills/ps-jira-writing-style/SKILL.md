---
name: ps-jira-writing-style
description: Writes Jira comments, descriptions, and updates in the user's internal team style (Polish/English mix, teammate-to-teammate tone, code-aware). Use when drafting Jira text through MCP or rewriting text to sound internal, direct, and human instead of corporate. Match thread language, keep technical tokens untouched, pick one comment shape (update/analysis/acknowledgment/problem report).
---

# Jira Writing Style

## Quick start

- Match the thread language; if the thread has no clear language yet, use the user's current language.
- Keep code symbols, endpoint paths, config keys, class names, and labels in their original technical form.
- Prefer teammate-to-teammate wording: short summary, concrete bullets, and a next step only when one actually exists.
- Pick one shape before writing: development update, technical analysis, quick acknowledgment, or problem report.

## Prerequisites

- Read enough of the thread to detect the dominant language and tone
- Identify the comment type before drafting
- Gather only the evidence needed to support the claim

## Workflow

1. Detect the thread language. If it is unclear, use the user's current language.
2. Keep all technical tokens untouched.
3. Pick the comment shape:
   - update = summary + bullets + optional `Do testów:`
   - analysis = framing sentence + facts + conclusion
   - acknowledgment = one line
   - problem report = symptom + root cause + fix or handoff
4. Remove filler, hedging, and obvious explanations.
5. End with a concrete next step only when one is actually needed.

## Example patterns

```text
Update:
Poprawki w kodzie dodane.
- Po synchronizacji obiekt jest odświeżany.
- Ten sam request ID zostaje w logach.

Do testów:
1. Scenariusz główny działa poprawnie.

Analysis:
Problem wynika z braku blokady po odświeżeniu.
- fakt 1
- fakt 2
Rekomendacja: dodać blokadę przed zapisem.
```

## Advanced features

See [REFERENCE.md](REFERENCE.md) for detailed language rules, voice rules, anti-patterns, and expanded guidance for each comment type.

## Validation checklist

- [ ] Matches the thread language and tone
- [ ] Keeps technical terms unchanged
- [ ] Uses the right comment shape
- [ ] Avoids corporate filler and AI phrasing
- [ ] Leaves a real next step only when needed
