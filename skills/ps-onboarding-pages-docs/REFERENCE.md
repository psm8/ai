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

## Publishing guidance

For GitHub-hosted repositories, prefer the existing `docs/` convention when present. Keep paths relative and avoid build steps unless the repo already has a site generator.

## Generic example prompts

- Create an onboarding landing page from these screenshots and release notes.
- Rewrite these test notes into a user guide with clear steps and expected results.
- Build a static docs page that explains how to complete the new workflow from start to finish.
