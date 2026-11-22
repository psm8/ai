---
name: ps-cv-tailor
description: Tailors the final CV to one job offer with minimal keyword edits and renders docx/pdf. Use when the user shares a job offer or link to apply to, or asks to tailor, adjust or fine-tune the CV for an offer.
---

# CV tailor

`CV-PiotrSeemann.md` is the user's final CV, written in their voice. A tailored copy **echoes** the offer's vocabulary and changes nothing else: same sentences, same bullets, same order, same tone. Fewer edits beat more; when unsure about an edit, leave it out.

## Allowed edits

Each edit is one of these four, and its new words come from the offer:

- **Rename**: the CV already states the thing under another name → use the offer's spelling. `JPA` → `Hibernate/JPA`, `token grant` → `OAuth2 token grant`.
- **Reorder**: inside one Skills line, move the offer's terms to the front.
- **Add to Skills**: an offer term listed in `CV-skills-tiers.md` ("On the CV" table, or named there as "add only if a job post names it") and backed by a bullet in the CV.
- **Echo in a bullet**: only for a term the user has confirmed is true, append a short clause in the offer's words to the bullet that backs it.

Matching is **verbatim**: recruiters' keyword filters and `check.py` both compare exact tokens. Use the offer's own spelling and inflection: `Mentor` and `mentoring` are different words, so are `LLM` and `LLMs`. A Skills item passes the tiers check only if its exact text appears in `CV-skills-tiers.md`.

Offer terms the CV cannot back (an unused database, a framework never touched) are **gaps**: they go in the report, never into the CV.

## Steps

1. Save the offer text to `offers/<Company>.md` (fetch the link if given). Done when the file holds the full requirements list.
2. List the offer's tech terms and match each against `CV-PiotrSeemann.md`. Done when every term is tagged rename, reorder, add, already-present or gap, and ranked: required terms the CV lacks verbatim first, nice-to-haves last.
3. Write `CV-<Company>.md`: a copy of the base with at most 5 changed lines, spent on the top-ranked terms. Several adds plus a reorder in one Skills line count as one line. Leave the base file untouched.
4. Run `python .claude/skills/ps-cv-tailor/check.py CV-PiotrSeemann.md CV-<Company>.md offers/<Company>.md`. Done when it prints `OK`; on `FAIL`, drop the flagged edits rather than rewording them.
   The check also blocks:
   - changes to locked lines (name, contact, company/title/dates, education, languages);
   - numbers the base line didn't have;
   - new seniority words (Lead, Architect, led…);
   - Skills additions that `CV-skills-tiers.md` doesn't allow.
5. Run `pwsh .claude/skills/ps-cv-tailor/render.ps1 <Company>`. Done when it reports 1 page and writes `output/CV-PiotrSeemann-<Company>.docx` and `.pdf`.

## Report

A table, one row per edit: `before → after | offer term`. Then the gaps as one line. Then one yes/no question per offer term that may be true but isn't in `CV-skills-tiers.md` yet; on a yes, add a dated "user decision" entry there before using the term. Nothing else: the user vetoes rows, you revert them and re-render.
