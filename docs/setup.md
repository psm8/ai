# Setup Skills and Agents for GitHub Copilot

## Skills Installation

### Cleanup (remove all installed skills)
```bash
npx skills rm --all -g
npx skills rm --all
```

### Install Skills

#### Common
```bash
npx skills add mattpocock/skills --skill write-a-prd
npx skills add mattpocock/skills --skill prd-to-issues
npx skills add vercel-labs/skills --skill find-skills
npx skills add mattpocock/skills --skill write-a-skill -g -a github-copilot -y
```

#### Git
```bash
npx skills add github/awesome-copilot --skill github-issues
npx skills add mattpocock/skills --skill triage-issue
npx skills add obra/superpowers --skill requesting-code-review
```

#### Solid
```bash
npx skills add solid-skills --skill ps-solid
```

#### Kotlin
```bash
npx skills add affaan-m/everything-claude-code --skill kotlin-coroutines-flows
npx skills add affaan-m/everything-claude-code --skill kotlin-patterns
npx skills add affaan-m/everything-claude-code --skill kotlin-testing
npx skills add affaan-m/everything-claude-code --skill android-clean-architecture
npx skills add affaan-m/everything-claude-code --skill compose-multiplatform-patterns
```

#### Dart/Flutter
```bash
npx skills add Jeffallan/claude-skills --skill flutter-expert
```

---


#### This Repository

Skills developed in this repository:
```bash
npx skills add psm8/ai --skill ps-github-issue-lifecycle
npx skills add psm8/ai --skill ps-jira-writing-style
npx skills add psm8/ai --skill ps-swarm-issue-delivery
```