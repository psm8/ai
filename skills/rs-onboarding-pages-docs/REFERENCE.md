# Onboarding Pages Reference

## Recommended page structure

Use a landing page that answers these questions in order:

1. What can the user do now?
2. Why would they use it?
3. What are the key steps?
4. What should they expect to see?
5. Where do they go next?

Suggested sections:

- Hero / title
- Short value statement
- Step-by-step walkthrough
- Example outcomes
- FAQ or next steps

## Rewriting source material

Raw source material often starts as:

- test notes
- implementation summaries
- shell commands
- screenshot filenames
- acceptance criteria

Rewrite that into:

- user goals
- actions the user takes
- visible results
- concise expectations

Bad:

> Verified via manual test that the modal opens after command X and screenshot Y proves it.

Better:

> Open the feature from the main page. You should see the setup panel appear immediately, with the primary action ready to use.

## Screenshot guidance

Use screenshots to confirm user-facing states:

- before/after steps
- key controls to click
- successful completion states

Avoid screenshots that mostly show:

- terminal output
- test harnesses
- internal admin data
- redacted-but-still-sensitive customer data

When labeling screenshots:

- use descriptive, stable filenames
- keep captions short
- explain the user-visible meaning, not how the screenshot was captured

## Static HTML guidance

Prefer a single `docs/index.html` file when:

- the scope is one feature or one walkthrough
- there are only a few screenshots
- the content can stay readable without a framework

Split into more pages only when:

- the landing page becomes long enough to harm scanning
- there are multiple distinct journeys
- you need a reusable pattern library or reference appendix

## Patterns for longer pages

When the landing page has more than roughly five steps or becomes long enough that the overview disappears on scroll, layer in these patterns. Use them additively - start with the simplest, add more only when the page becomes hard to scan.

### Flow diagram at top

- Purpose: give the reader the whole shape of the process before they commit to reading.
- Use when: the walkthrough has more than five steps, or the steps have a non-obvious order (branches, loops, repeated phases).
- How: plain HTML/CSS boxes with arrow characters. No diagramming library needed.
- Avoid when: the flow is a simple linear 1-2-3 - the numbered steps alone are clearer.

Minimal pattern:

```html
<div class="flow">
  <div class="flow-node">Step 1</div>
  <span>&rarr;</span>
  <div class="flow-node">Step 2</div>
  <span>&rarr;</span>
  <div class="flow-node">Step 3</div>
</div>
```

### Collapsible step cards

- Purpose: progressive disclosure - let the reader skim all step titles first, then expand only what they need.
- Use when: the page has six or more steps, or individual steps have long bodies.
- How: native `<details>` / `<summary>` is the simplest accessible option. Custom JS toggles are fine when more styling is needed.
- Avoid when: the walkthrough is short enough to read top-to-bottom.

Minimal pattern:

```html
<details>
  <summary>Step 1 - Title</summary>
  <p>Step body here.</p>
</details>
```

### Scroll-spy sidebar

- Purpose: persistent navigation that highlights the section currently in view.
- Use when: the page has five or more sections and is long enough that users scroll past the top.
- How: fixed sidebar with section links, IntersectionObserver updates the active link as sections scroll in.
- Avoid when: the page fits on one or two screens - adds visual noise for no gain.
- Responsive note: collapse or hide the sidebar below a small-screen breakpoint.

Minimal pattern:

```js
const links = document.querySelectorAll('.nav a');
const observer = new IntersectionObserver(entries => {
  entries.forEach(e => {
    if (e.isIntersecting) {
      links.forEach(l => l.classList.remove('active'));
      const link = document.querySelector('.nav a[href="#' + e.target.id + '"]');
      if (link) link.classList.add('active');
    }
  });
}, { rootMargin: '-20% 0px -60% 0px' });
document.querySelectorAll('section').forEach(s => observer.observe(s));
```

### Callout boxes

- Purpose: pull hard-won rules, warnings, or non-obvious notes out of the main flow so they cannot be missed.
- Use when: there is content the reader must see even if they skim - lessons learned, common mistakes, prerequisites.
- Distinct from examples: callouts are rules or warnings (what to do or avoid); examples are illustrations.
- How: visually distinguish with a colored left border, short label, and concise body.

Suggested types:

- Note - supporting context the reader should notice
- Warning - action that prevents a common mistake
- Lesson - rule that came from real experience, not a suggestion

Minimal pattern:

```html
<div class="callout lesson">
  <div class="label">Lesson</div>
  <p>Short rule the reader should remember.</p>
</div>
```

Keep callouts short. If a callout grows past a few sentences, it probably belongs in the main flow as a dedicated section.

## Publishing guidance

For GitHub-hosted repositories, prefer the existing `docs/` convention when present. Keep paths relative and avoid build steps unless the repo already has a site generator.

## Generic example prompts

- Create an onboarding landing page from these screenshots and release notes.
- Rewrite these test notes into a user guide with clear steps and expected results.
- Build a static docs page that explains how to complete the new workflow from start to finish.
