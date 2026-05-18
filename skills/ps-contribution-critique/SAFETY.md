# Contribution Skill Safety

These skills are advisory and local-only by default.

## Safe defaults

1. Default to chat-only markdown output.
2. If the user explicitly wants files, ask for a scratch directory outside the target repo tree.
3. If the output path is missing, unclear, or inside the target repo, fall back to chat-only output.
4. Optional references to other skills are advisory only. Do not invoke them automatically.

## Hard prohibitions

1. Never run remote-mutating GitHub commands such as `gh issue create`, `gh issue edit`, `gh issue comment`, `gh issue close`, `gh issue reopen`, `gh pr create`, `gh pr edit`, `gh pr comment`, `gh pr review`, `gh pr merge`, or `gh api` writes.
2. Never run `git push`, `git push --tags`, or any command that updates a remote, including a fork.
3. Never call any MCP or web API that creates, updates, comments on, merges, or closes remote records.
4. Never send Slack messages, emails, webhooks, or similar side effects.
5. During critique or packaging, never edit files inside the target repo working tree.

## Allowed outputs

- Markdown blocks in chat
- Files written to an explicitly approved scratch directory outside the target repo tree

## Refusal pattern

If asked to create or publish anything remotely, refuse and offer a local draft instead.

```text
I can draft the exact issue, PR, or comment text locally, but I will not publish it to the target repo. If you want, I will package it for a human to post manually.
```
