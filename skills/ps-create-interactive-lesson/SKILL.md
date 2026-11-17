---
name: create-interactive-lesson
description: Create one self-contained interactive HTML lesson on a programming topic for senior interview prep. Use when the user asks for an interactive lesson, HTML lesson, interview drill, or first-principles deep-dive on a language, framework, concurrency model, or API.
argument-hint: "Topic (e.g. class loading, HTTP caching, transaction isolation), optional level / language / source"
---

# Create interactive lesson

Author **one** senior, first-principles lesson as a single HTML file at `lessons/<slug>.html`. The learner already has expert background; the lesson builds the model, drills decisions, and does **not** re-teach basics.

This skill is a **recipe**. Craft analogies with [`ps-simple-short-analogy`](../../ps-simple-short-analogy/SKILL.md) (shape only — one relationship, one caveat; do not inline that skill). If the user wants a multi-session mission workspace, use [`teach`](../../teach/SKILL.md) instead — this skill emits a one-shot lesson file.

## Defaults

| Knob | Default |
|------|---------|
| Level | Senior interview (user override) |
| Code language | Java (user override) |
| Output | `lessons/<slug>.html` |
| External deps | None — one self-contained file |

Slug: lowercase, hyphenated topic (`transaction-isolation.html`).

## Steps

### 1. Scope

Write a one-line **skill statement**: what the learner can *decide or defend* after the lesson, not what they "will know".

Optional inputs: level, language, source (code / video / doc / PDF). Record language for snippets. If the topic is unbounded ("all of Spring"), cut to one interview-sized decision surface before continuing.

**Done when:** skill statement is one sentence; topic cannot expand without changing that sentence.

### 2. Extract first principles (sources as drills)

Gather claims from whatever the user pointed at or the topic standard. Pull out:

- **5–8 first principles** — why the mechanism exists, what it actually guarantees, where it stops.
- **2–4 folklore claims** — textbook slogans, "everyone knows", source overconfidence, analogy that leads to wrong design.

Treat sources as material to pressure-test, not as the lesson's authority. Lesson body carries no "the book says" identity.

**Done when:** principles + folklore lists exist; each principle is falsifiable in one sentence.

### 3. Design modules

Target **8–12 short modules**. Pattern per module:

1. First principle(s) for the job.
2. Compact model / rule the learner can say out loud.
3. Analogy **after** the mechanism, with a caveat clause (use the analogy skill's shape).
4. Opinionated default + when it does not hold.
5. Lab or interactive from [`LABS.md`](references/LABS.md).
6. Quiz(s) with explanations.

Module 0: orientation (goal, assumed prior knowledge, what the lesson will not cover).  
Final modules: **myth-grid**, **interview drill**, **cheatsheet + self-score**.

**Done when:** every module has one job; each major module names a lab; lesson has ≥1 **bug hunt**.

### 4. Author interactions before final prose

Choose lab types from [`LABS.md`](references/LABS.md). Code challenges use **decision UX**:

- which output / trace is legal
- which tool belongs
- click the buggy line
- word-bank blanks
- hint ladder

Full methods typed from memory are out of scope.

Bug hunts: MCQ or click-line verdict + optional free-text graded by a **keyword rubric** (required keywords + "accept if the learner explains X" list). Hint ladder: concept → where to look → principle.

**Done when:** every lab/bug hunt has its data payload ready to paste (options, rubric, hints, explanation).

### 5. Fill the template

Copy [`references/LESSON-TEMPLATE.html`](references/LESSON-TEMPLATE.html) → `lessons/<slug>.html`. Replace:

- Title, hero, badges, section ids + nav labels
- Module bodies (code, tables, callouts)
- Quiz options (`data-correct="true"` on exactly one; similar length/format)
- Bug hunt payloads (`data-bug-*` attributes)
- Scenario picker / decision ladder / myth-grid / flashcards / drill / checklists
- Footer: no book worship; optional "sources are drills" line

Quiz options are **runtime-shuffled** by the template. Do not rely on option order; keep one `data-correct="true"` per quiz.

**Done when:** file is at `lessons/<slug>.html`; no unreplaced `<!-- AUTHOR` placeholders that still block interaction; every quiz explains; every bug hunt has rubric + hints.

### 6. Verify

- Tag balance (buttons/divs/sections/scripts).
- JS syntax check (e.g. extract `<script>` and `node --check`).
- Confirm quiz shuffle path still present; bug hunts have feedback UI wired.
- Open in browser when the environment allows.

**Done when:** checks pass; file opens; progress + quiz state work.

## Content bar

Apply to every module; these are acceptance criteria, not vibes.

| Bar | Expectation |
|-----|-------------|
| First principles first | Mechanism before slogan; analogy after, with caveat |
| Prior knowledge | Module 0 names assumed background; lesson builds on it |
| Opinion | Default choice + failure mode of the default |
| Skepticism | Myth-grid vs folklore; sources are drills |
| Feedback | Every quiz explains; bug hunts grade + hints |
| Performance goal | Drill = design decisions + whiteboard defense |
| Reflection | Self-score: "could I defend this on a board?" |
| Code UX | MCQ / click-line / legal-outcome / hints — no exact-syntax tests |
| Length | Short modules; sprawl is a defect — disclose detail behind labs |

Effective-learning map (why the shape is this way — do not preach inside the lesson):

| Learner need | Lesson feature |
|--------------|----------------|
| Skill / performance goals | Drill + decision labs |
| Interaction + feedback | Quizzes, bug hunts, labs |
| Mindful reflection | Self-score checklist |
| Prior knowledge | Module 0 assumptions |

## What not to build

- Second lesson, companion markdown notes, or mission workspace unless asked.
- Topic-specific chrome inside the template (keep it universal).
- Book chapters or source worship in the hero.

## Completion (lesson)

Learner opens `lessons/<slug>.html`, works modules in order, hits shuffled quizzes, runs labs, attempts the bug hunt with hints if stuck, scores the drill, ticks self-score. Skill statement is defensible from the cheatsheet + drill answers.
