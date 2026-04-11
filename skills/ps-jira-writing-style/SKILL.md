---
name: ps-jira-writing-style
description: 'Apply the user''s Jira commenting style when composing Jira text via MCP. Use when writing comments, descriptions, or updates in Jira issues using jira_add_comment, jira_create_issue, jira_update_issue, or any MCP tool that writes text to Jira. Mirror the thread language, keep code terms in English, and write in a direct teammate-to-teammate tone.'
---

# Jira Writing Style

Adopt the following voice and structure when composing Jira text.

## Language Rules

1. Match the language of the surrounding Jira thread
2. If the thread has no clear language yet, use the language the user is currently using in the conversation
3. Keep code symbols, class names, method names, endpoint paths, config keys, and MR labels in their original technical form
4. Mixed local-language prose with English technical terms is fine and often preferred in internal comments

## Voice Rules

1. Be direct -- no filler, no corporate pleasantries, get to the point quickly
2. Sound like a teammate, not a status bot -- casual, natural, internal
3. Light humor or a short ironic opener is acceptable when the thread tone supports it
4. Be opinionated and pragmatic -- say what is fixed, what is still risky, and what should happen next
5. Use short paragraphs and bullets freely; do not force full prose when a list is clearer
6. Back claims with evidence when it matters, but do not overload routine status updates with unnecessary proof
7. End with the concrete next step only when there actually is one

## Structure by Comment Type

### Development Update (code ready / sent for testing)

Pattern:
- Optional short reply/reactive opener if answering someone directly
- One blunt summary line that the fix is in
- 2-4 bullets with concrete technical changes
- Separate MR lines per repo when relevant
- `Do testów:` section with numbered scenarios

Example:
```
Poprawki w kodzie dodane.
 * Po synchronizacji obiekt jest odświeżany i blokowany przed zapisem.
 * Dodatkowo zachowany jest ten sam request ID w logach.

MR repo-1: [link]
MR repo-2: [link]

Do testów:
1. Scenariusz główny działa poprawnie.
2. Nie pojawiają się nowe błędne wpisy w historii.
```

### Technical Analysis

Pattern:
- Short framing sentence
- Facts in bullets or numbered points
- Specific evidence only where it adds value
- Clear conclusion, recommendation, or open question
- Jira headings are optional; use them only for longer analysis comments

### Quick Acknowledgment

One line is enough. Examples:
- `OK, poprawione.`
- `Dzięki, sprawdzone.`
- `Review OK.`
- `No problem z mojej strony.`

### Question / Clarification

Direct question with just enough context to show why it matters. Reference specific code, config, logs, or flow when needed.

### Problem Report / Root Cause

Pattern:
- State what is happening
- Explain root cause in practical terms
- Add technical detail only where it proves the point
- Suggest the fix, testing direction, or handoff

## Anti-Patterns (DO NOT)

- Do NOT use corporate filler ("I hope this message finds you well", "Please don't hesitate to...")
- Do NOT switch to English if the thread is clearly in another language
- Do NOT hedge technical opinions ("Perhaps we could consider maybe looking at...")
- Do NOT over-explain obvious things
- Do NOT write walls of text when bullets would be clearer
- Do NOT force `Review please.` into every implementation update
- Do NOT use formal closings ("Best regards", "Kind regards") in internal comments
- Do NOT sound like AI ("Based on my analysis...", "I have investigated the matter thoroughly...")

## Strong Defaults

- Prefer the thread's dominant language for internal Jira comments
- Prefer short summary + bullets over essay format
- Prefer separate `MR <repo>:` lines when multiple repositories are involved
- Prefer `Do testów:` over `For testing:` when writing in Polish
- If replying to a teammate in an already informal thread, a small joke or human opener is fine
