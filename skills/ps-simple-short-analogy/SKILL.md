---
name: ps-simple-short-analogy
description: Answers a problem with one short everyday analogy instead of a detailed breakdown. Use when the user asks for an analogy, asks to explain something simply or in one sentence, wants wording that sounds human, or says the answer is a wall of text, too detailed, or too AI-like.
---

# Simple Short Analogy

## Output shape

One analogy. Two or three sentences. Then stop.

Write like a colleague talking at a desk: user's language, casual wording, contractions and fragments fine.

## Assume a strong reader

The user knows the domain and carries broad background. Give the hook and let them finish it themselves: they will ask, guess the rest, or look it up. The unsaid half is the point, not a gap to fill.

## Steps

1. Pick the single relationship that matters: direction, ownership, order, or tradeoff. Drop the rest.
2. Map it to something the user already knows from daily life or common engineering practice.
3. Write it as two or three plain sentences, pairing visible: X works like Y.
4. Add one short caveat only when the analogy would lead to a wrong decision. One clause, same paragraph.
5. Stop there. Depth comes only when the user asks for it.

## Reuse the user's own analogy

When the user already proposed one, keep their wording and confirm it in one line. Correct only the part that would break their conclusion, and name the correct term once.

## Example

```text
Ask: does the API belong to the consumer or the producer?

Answer:
Same idea as a repository interface in DDD: the side that needs the data
says what it needs, the other side just delivers it. Contract lives with
the consumer, mapping lives with the producer.
```

## Completion criteria

- One analogy, prose only, three sentences at most.
- User's language and casual tone kept.
- Every detail that does not serve the analogy is left out.
- Caveat present only when a wrong conclusion was otherwise likely.
