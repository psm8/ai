---
name: ps-onboarding-pages-docs
description: Creates onboarding-focused static documentation pages from screenshots, rollout notes, and implementation evidence. Use when turning walkthrough artifacts, release notes, manual test notes, or proof screenshots into GitHub Pages-ready end-user guides without exposing internal QA framing.
---

# Onboarding Pages Docs

## Quick start

- Start from the user journey, not the engineering timeline.
- Treat screenshots, commands, and test notes as raw source material to rewrite for end users.
- Publish the result as simple static docs, with `index.html` as the entry point when a docs site is needed.
- Remove QA wording, proof-of-work language, and internal-only commentary from the final copy.

## Prerequisites

- The target repo and docs location are known.
- The available artifacts are known: screenshots, notes, commands, checklists, or test evidence.
- The audience is understood: onboarding, how-to, or feature adoption.

## Workflow

1. Inventory the available artifacts and decide which ones support the end-user story.
2. Rewrite internal notes into user-facing outcomes, tasks, and examples.
3. Build the page around a simple flow: what this helps with, how to use it, what to expect.
4. Use screenshots only when they clarify a user action or result.
5. Keep the site static and portable: plain HTML, lightweight assets, predictable paths.
6. Validate that the final page reads like onboarding documentation, not QA evidence.

## Output shape

- `docs/index.html` for the landing page
- optional `docs/assets/` for images
- optional secondary docs pages only when the landing page would become crowded

## Guardrails

- Do not copy product-specific confidential examples into the skill itself.
- Do not mention QA, agent execution, proof-of-work, or internal verification in user-facing docs.
- Prefer generic wording in bundled examples and templates.

## Advanced features

See [REFERENCE.md](REFERENCE.md) for page structure, content patterns, screenshot rules, and publishing guidance.

## Validation checklist

- [ ] The copy is end-user oriented
- [ ] The page has a clear start-to-finish flow
- [ ] Screenshots support actions, not internal process
- [ ] Static files use stable, simple paths
- [ ] Internal QA or proof language is absent
