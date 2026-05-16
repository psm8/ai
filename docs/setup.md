# Setup Skills and Agents for GitHub Copilot

## Skills Installation

### Cleanup (remove all installed skills)
```bash
npx skills rm --all -g
npx skills rm --all
```

### Install Skills

#### Common Global
```bash
skg vercel-labs/skills -s find-skills
skg mattpocock/skills -s caveman to-prd to-issues grill-with-docs tdd write-a-skill
```

#### Git
```bash
skl github/awesome-copilot -s github-issues
skg mattpocock/skills -s triage
skl obra/superpowers -s requesting-code-review
```

#### Solid
```bash
skg psm8/solid-skills -s ps-solid
```

#### Kotlin
```bash
skl affaan-m/everything-claude-code --skill kotlin-coroutines-flows
skl affaan-m/everything-claude-code --skill kotlin-patterns
skl affaan-m/everything-claude-code --skill kotlin-testing
skl affaan-m/everything-claude-code --skill android-clean-architecture
skl affaan-m/everything-claude-code --skill compose-multiplatform-patterns
```

#### Dart/Flutter
```bash
skl Jeffallan/claude-skills --skill flutter-expert
```

---


#### This Repository

Skills developed in this repository:
```bash
# Global (Personal) Skills

skg psm8/ai -s ps-github-issue-lifecycle
skg psm8/ai -s ps-swarm-issue-delivery  # (dependency)
skg psm8/ai -s ps-jira-writing-style

# Local (Repository) Skills

skl psm8/ai -s rs-onboarding-pages-docs
```