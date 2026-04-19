# Jira Writing Style Reference

## Language Rules

1. Match the language of the surrounding Jira thread.
2. If the thread has no clear language yet, use the language the user is currently using in the conversation.
3. Keep code symbols, class names, method names, endpoint paths, config keys, and MR labels in their original technical form.
4. Mixed local-language prose with English technical terms is fine and often preferred in internal comments.

## Voice Rules

1. Be direct; no filler, no corporate pleasantries, get to the point quickly.
2. Sound like a teammate, not a status bot.
3. Light humor or a short ironic opener is acceptable when the thread tone supports it.
4. Be opinionated and pragmatic; say what is fixed, what is still risky, and what should happen next.
5. Use short paragraphs and bullets when they are clearer than dense prose.
6. Back claims with evidence when it matters, but do not overload routine status updates.
7. End with a concrete next step only when there actually is one.

## Comment Type Guidance

### Development Update

Pattern:
- optional short reactive opener
- one blunt summary line that the fix is in
- 2-4 bullets with concrete technical changes
- separate MR lines per repo when relevant
- `Do testów:` section with numbered scenarios

Example:

```text
Poprawki w kodzie dodane.
- Po synchronizacji obiekt jest odświeżany i blokowany przed zapisem.
- Zachowany jest ten sam request ID w logach.

MR repo-1: [link]
MR repo-2: [link]

Do testów:
1. Scenariusz główny działa poprawnie.
2. Nie pojawiają się nowe błędne wpisy w historii.
```

### Technical Analysis

Pattern:
- short framing sentence
- facts in bullets or numbered points
- specific evidence only where it adds value
- clear conclusion, recommendation, or open question

### Quick Acknowledgment

One line is enough. Examples:
- `OK, poprawione.`
- `Dzięki, sprawdzone.`
- `Review OK.`
- `No problem z mojej strony.`

### Question or Clarification

Ask the direct question and include only the context needed to show why it matters.

### Problem Report or Root Cause

Pattern:
- state what is happening
- explain root cause in practical terms
- add technical detail only where it proves the point
- suggest the fix, testing direction, or handoff

## Anti-Patterns

- Do not use corporate filler.
- Do not switch to English if the thread is clearly in another language.
- Do not hedge technical opinions.
- Do not write walls of text when bullets are clearer.
- Do not force `Review please.` into every implementation update.
- Do not use formal closings in internal comments.
- Do not sound like AI.

## Strong Defaults

- Prefer the thread's dominant language for internal Jira comments.
- Prefer short summary + bullets over essay format.
- Prefer separate `MR <repo>:` lines when multiple repositories are involved.
- Prefer `Do testów:` over `For testing:` when writing in Polish.
- If replying in an already informal thread, a small joke or human opener is fine.
