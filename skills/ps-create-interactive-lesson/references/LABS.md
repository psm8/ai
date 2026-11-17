# Lab catalogue

How to fill interaction slots in [`LESSON-TEMPLATE.html`](LESSON-TEMPLATE.html). Pick by **decision the learner makes**, not by visual novelty.

Minimum bar from the skill: **≥1 lab per major module**, **≥1 bug hunt per lesson**.

Code language follows the lesson parameter (default Java). Challenges test **decisions**, not syntax recall: legal outcomes, best tool, click-the-line, word-bank, hints.

---

## Shared conventions

- Wrap labs in `<div class="lab" id="lab-…">` + `<h4>Lab · …</h4>`.
- Controls: `<div class="lab-controls">` + `<button class="btn primary|…">`.
- Result line: `<div class="outcome" id="…Out">`.
- Author JS: either inline in a module section script, or extend the bottom script with `// AUTHOR: lab-…`.
- Keep snippets short; comment the **decision**, not every token.
- Quiz options near this lab: similar length; exactly one `data-correct="true"`.

---

## 1. Outcome enumerator

**Use when:** the topic has legal vs illegal traces (ordering, isolation levels, parser states, cache policies, HTTP semantics).

**Shape:** prose setup + buttons that list legal outcomes / illegal outcomes / “what naive SC assumes”.

```html
<div class="lab" id="lab-outcomes">
  <h4>Lab · Legal outcomes</h4>
  <p style="color:var(--muted)">Setup: two actors, no synchronization edge.</p>
  <div class="lab-controls">
    <button class="btn primary" data-outcome="legal">Enumerate legal outcomes</button>
    <button class="btn" data-outcome="naive">What sequential consistency would claim</button>
  </div>
  <div class="outcome" id="outcomeOut">Press a control.</div>
</div>
```

```js
document.querySelectorAll("[data-outcome]").forEach(btn => {
  btn.addEventListener("click", () => {
    const mode = btn.getAttribute("data-outcome");
    const out = document.getElementById("outcomeOut");
    // AUTHOR: fill strings
    out.innerHTML = mode === "legal"
      ? "<span class='ok'>Legal: …</span>, …"
      : "<span class='no'>SC-only claim: …</span> — wrong without edges.";
  });
});
```

---

## 2. Step simulator

**Use when:** the mechanism is a timeline (request lifecycle, GC phases, event loop ticks, handshake).

**Shape:** two (or more) panes of numbered lines; buttons advance steps; highlight `.line.active` then `.line.executed`.

```html
<div class="lab" id="lab-sim">
  <h4>Lab · Timeline</h4>
  <div class="mem-panel">
    <div class="thread">
      <header><strong>Actor A</strong><span class="badge" id="simStatusA">idle</span></header>
      <div class="lines" id="simA">
        <div class="line" data-i="0">step 0</div>
        <div class="line" data-i="1">step 1</div>
      </div>
    </div>
    <div class="thread">
      <header><strong>Actor B</strong><span class="badge" id="simStatusB">idle</span></header>
      <div class="lines" id="simB">
        <div class="line" data-i="0">step 0</div>
        <div class="line" data-i="1">step 1</div>
      </div>
    </div>
  </div>
  <div class="lab-controls">
    <button class="btn primary" id="simRun">Run one interesting trace</button>
    <button class="btn" id="simEnum">Enumerate interesting results</button>
  </div>
  <div class="outcome" id="simOut">…</div>
</div>
```

Use `await sleep(ms)` between steps; paint outcome with `.ok` / `.no` spans.

---

## 3. Scenario picker

**Use when:** “which tool / pattern fits?” (JMM tools, caching strategies, transaction boundaries, observability hooks).

**Preferred (data-driven, no custom JS):** JSON attribute on the lab.

```html
<div class="lab" data-scenario-lab='[
  {
    "q": "Worker loop must notice a stop flag. One writer, many readers.",
    "options": [
      { "label": "volatile flag", "best": true, "verdict": "Release/acquire on a single field — default." },
      { "label": "plain boolean", "best": false, "verdict": "No edge — stale reads are legal." },
      { "label": "synchronized everything", "best": false, "verdict": "Correct but usually heavier than a flag needs." }
    ]
  },
  {
    "q": "Compound counter across threads.",
    "options": [
      { "label": "AtomicLong", "best": true, "verdict": "Library RMW semantics." },
      { "label": "volatile int ++", "best": false, "verdict": "Orders accesses; not atomic RMW." }
    ]
  }
]'>
  <h4>Lab · Choose the tool</h4>
  <p>Read the scenario, pick the best default, then compare to the senior answer.</p>
</div>
```

Template JS auto-wires prev/next and verdicts. Do not invent a second picker engine.

---

## 4. Graph / edge builder

**Use when:** causality or structure matters (happens-before, call graphs, dependency direction, state machines).

**Shape:** absolutely positioned nodes + SVG lines; click select → click target; preset button; check button.

Minimum nodes: 4–8. Label kinds in `data-kind` for legality checks.

```html
<div class="lab" id="lab-graph">
  <h4>Lab · Edge builder</h4>
  <div class="lab-controls">
    <button class="btn primary" id="graphCheck">Check scenario</button>
    <button class="btn" id="graphReset">Reset</button>
    <button class="btn" id="graphPreset">Load preset</button>
  </div>
  <div class="hb-canvas" id="graphCanvas">
    <svg class="hb-svg" id="graphSvg"></svg>
    <div class="hb-node threadn" data-id="n1" data-kind="a" style="left:20%;top:30%">n1</div>
    <div class="hb-node vol" data-id="n2" data-kind="b" style="left:50%;top:30%">n2</div>
    <div class="hb-node vol" data-id="n3" data-kind="c" style="left:50%;top:70%">n3</div>
    <div class="hb-node threadn" data-id="n4" data-kind="d" style="left:80%;top:70%">n4</div>
  </div>
  <div class="outcome" id="graphOut">…</div>
</div>
```

Implement legality with `data-kind` pairs (topic-specific function). CSS classes `.ok` / `.bad` on lines are already in the template.

---

## 5. Tabbed failure modes

**Use when:** several wrong intuitions share a stage (lost update vs stale read vs torn multi-field; 4xx vs 5xx vs timeout; N+1 vs missing index).

```html
<div class="lab" id="lab-fail">
  <h4>Lab · Failure modes</h4>
  <div class="tabs">
    <button class="tab active" data-tab="t1">Mode A</button>
    <button class="tab" data-tab="t2">Mode B</button>
  </div>
  <div id="failT1">…</div>
  <div id="failT2" class="hidden">…</div>
  <div class="lab-controls">
    <button class="btn primary" id="runT1">Simulate A</button>
  </div>
  <div class="outcome" id="failOut">…</div>
</div>
```

Tab JS: toggle `.hidden`, move `.active` on the tab clicked.

---

## 6. Bug hunt (required)

**Use when:** the topic has a subtle failure that tests the model, not API trivia.

**Modes:** `data-bug-mode="mcq"` or `"click"`.  
**Grading:** keyword rubric in `data-keywords` (comma-separated) + optional `data-accept` phrase + `data-explanation`.  
**Hints:** `data-hint1` (concept) → `data-hint2` (where) → `data-hint3` (principle).

```html
<div class="bughunt" data-bug="bh1"
     data-bug-mode="mcq"
     data-keywords="compound,atomic,race"
     data-accept="read-modify-write"
     data-hint1="What does the compound action decompose into?"
     data-hint2="Look at the method body, not the type name."
     data-hint3="Ordering is not indivisibility."
     data-explanation="…two or three sentences, senior tone…">
  <h4>Bug hunt 1</h4>
  <div class="bh-meta">Shared counter, many threads.</div>
  <pre><code><span class="c">// AUTHOR</span>
counter++;  <span class="c">// subtle bug</span>
</code></pre>
  <div class="options" data-bh-choices>
    <button class="option" data-correct="false">…</button>
    <button class="option" data-correct="true">…</button>
    <button class="option" data-correct="false">…</button>
  </div>
</div>
```

**Click-the-line variant:**

```html
<div class="bughunt" data-bug="bh2" data-bug-mode="click"
     data-keywords="…" data-explanation="…"
     data-hint1="…" data-hint2="…" data-hint3="...">
  <h4>Bug hunt 2</h4>
  <pre class="hidden"></pre>
  <div class="bh-lines" data-bh-lines>
    <div class="bh-line clickable" data-line-id="l1" data-bug-line="false">safe line</div>
    <div class="bh-line clickable" data-line-id="l2" data-bug-line="true">subtle bug line</div>
    <div class="bh-line clickable" data-line-id="l3" data-bug-line="false">safe line</div>
  </div>
</div>
```

Do not put a large empty `<pre>`; put code inside the lines or keep a short `<pre><code>` above `data-bh-lines`.

**Keyword rubric craft:**

| Element | Rule |
|---------|------|
| `data-keywords` | 3–5 concept tokens that appear in a *good* explanation (e.g. `compound,atomic,release`) |
| `data-accept` | One phrase that shows first-principles grasp (`read-modify-write`, `happens-before`, `N+1`) |
| Verdict UI | MCQ/click still primary; rubric fills “what’s missing” |
| Hints | Escalating; never the full answer in hint1 |

**Subtle-bug subject list (topic-agnostic patterns):**

- Compound action on a “safe” primitive
- Multi-field invariant with per-field sync
- Unsafe publication / half-built object
- Check-then-act on a shared structure
- API that is thread-safe for reads but not the documented write path
- Ordering assumption that needs an explicit edge
- Retry that reorders side effects
- Default that is correct in single-thread tests only

---

## 7. Decision ladder

**Use when:** shipping defaults.

```html
<div class="decision-tree">
  <div class="decision-step">
    <div class="q">1. Can the data be immutable?</div>
    <div class="a">Yes → value objects / records. Usually wins.</div>
  </div>
</div>
```

Follow with one quiz that forces the ladder under pressure.

---

## 8. Myth grid

**Use when:** folklore is load-bearing in interviews.

```html
<div class="myth open">
  <button class="head">
    <span>Slogan under test</span>
    <span class="verdict folk">Folk model</span>
  </button>
  <div class="body"><p>First-principles upgrade.</p></div>
</div>
```

Verdict classes: `folk` | `partial` | `real`. 4–6 entries.

---

## 9. Word-bank blanks

**Use when:** compact model should be *retrieved*, not re-read.

```html
<div class="lab" id="lab-bank">
  <h4>Lab · Word bank</h4>
  <p>Fill: the mechanism is <span class="blank" data-blank="1"></span> and the edge is <span class="blank" data-blank="2"></span>.</p>
  <div class="wordbank" data-wordbank>
    <button data-word="release">release</button>
    <button data-word="acquire">acquire</button>
    <button data-word="volatile">volatile</button>
  </div>
  <div class="lab-controls">
    <button class="btn primary" id="bankCheck">Check</button>
  </div>
  <div class="outcome" id="bankOut">…</div>
</div>
```

Author wires click-to-fill + check (compare `data-word` to expected map). Keep expected map in one JS object.

---

## 10. Flashcards

Set `window.LESSON_FLASHCARDS` in a `<script>` **before** the main template script:

```html
<script>
  window.LESSON_FLASHCARDS = [
    { f: "What is X?", b: "One-line model answer." },
    { f: "When is Y wrong?", b: "Failure condition + default." }
  ];
</script>
```

---

## Module assembly checklist

- [ ] Module states first principle(s) before slogan
- [ ] Analogy (if any) after mechanism + caveat clause
- [ ] Opinionated default + when it fails
- [ ] Lab present and wired
- [ ] Quiz(s) with explanation; options similar length
- [ ] At least one bug hunt with keywords + hints + explanation
- [ ] Myth-grid, decision ladder, drill, cheatsheet, self-score
- [ ] No exact-syntax “type the method” challenges
- [ ] Template quiz shuffle left intact
