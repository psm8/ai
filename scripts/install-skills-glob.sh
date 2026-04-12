#!/usr/bin/env bash
# Install Skills with Glob Matching
# Wraps `npx skills add` to support wildcard patterns for --skill.
# Usage:
#   ./install-skills-glob.sh <repo-url> --skill 'core-*' -a codex -y
#   ./install-skills-glob.sh <repo-url> --skill 'core-*' --skill 'citools-*' -a codex --dry-run
set -euo pipefail

REPO_URL=""
SKILL_PATTERNS=()
ADAPTERS=()
YES_FLAG=""
GLOBAL_FLAG=""
DRY_RUN=false
EXTRA_ARGS=()

# ── Parse arguments ──────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill|-s)    SKILL_PATTERNS+=("$2"); shift 2 ;;
    --adapter|-a)  ADAPTERS+=("$2"); shift 2 ;;
    -y|--yes)      YES_FLAG="-y"; shift ;;
    -g|--global)   GLOBAL_FLAG="-g"; shift ;;
    --dry-run)     DRY_RUN=true; shift ;;
    -*)            EXTRA_ARGS+=("$1"); shift ;;
    *)
      if [[ -z "$REPO_URL" ]]; then REPO_URL="$1"; shift
      else EXTRA_ARGS+=("$1"); shift; fi
      ;;
  esac
done

if [[ -z "$REPO_URL" ]]; then
  echo "[error] Missing repo URL. Usage: $0 <repo-url> --skill 'pattern' [-a adapter] [-y] [--dry-run]" >&2
  exit 1
fi
if [[ ${#SKILL_PATTERNS[@]} -eq 0 ]]; then
  echo "[error] At least one --skill pattern is required." >&2
  exit 1
fi

info()  { printf '\033[36m[info]  %s\033[0m\n' "$1"; }
match() { printf '\033[32m[match] %s\033[0m\n' "$1"; }
skip()  { printf '\033[90m[skip]  %s\033[0m\n' "$1"; }
err()   { printf '\033[31m[error] %s\033[0m\n' "$1"; }

# ── 1. List available skills ─────────────────────────────────────────────
info "Listing skills from $REPO_URL ..."
LIST_RAW=$(npx skills add "$REPO_URL" --list 2>&1) || {
  err "Failed to list skills"; exit 1
}

if [[ -z "${LIST_RAW// }" ]]; then
  err "No output from --list. Verify the repo URL."; exit 1
fi

# ── 2. Parse skill names ────────────────────────────────────────────────
SKILL_NAMES=()
while IFS= read -r line; do
  trimmed="${line#"${line%%[![:space:]]*}"}"  # ltrim
  trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"  # rtrim
  [[ -z "$trimmed" ]] && continue
  [[ "$trimmed" =~ ^[-=+\|]+$ ]] && continue
  [[ "$trimmed" =~ ^(name|skill|available|listing) ]] && continue

  # extract first alphanumeric-with-hyphens token
  candidate=""
  if [[ "$trimmed" =~ ^[\|\*\-]*[[:space:]]*([a-zA-Z0-9][a-zA-Z0-9_.\-]+) ]]; then
    candidate="${BASH_REMATCH[1]}"
  fi

  if [[ -n "$candidate" ]] && ! [[ "$candidate" =~ ^(name|skill|id|description|version|type|status)$ ]]; then
    SKILL_NAMES+=("$candidate")
  fi
done <<< "$LIST_RAW"

# deduplicate
mapfile -t SKILL_NAMES < <(printf '%s\n' "${SKILL_NAMES[@]}" | sort -u)

if [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
  err "Could not parse any skill names from listing output."
  info "Raw output:"; echo "$LIST_RAW"; exit 1
fi

info "Found ${#SKILL_NAMES[@]} skill(s) in repo: ${SKILL_NAMES[*]}"

# ── 3. Glob-match ───────────────────────────────────────────────────────
MATCHED=()
for pattern in "${SKILL_PATTERNS[@]}"; do
  hits=0
  for name in "${SKILL_NAMES[@]}"; do
    # bash built-in glob matching
    if [[ "$name" == $pattern ]]; then
      # avoid duplicates
      if [[ ! " ${MATCHED[*]:-} " =~ " $name " ]]; then
        MATCHED+=("$name")
      fi
      ((hits++)) || true
    fi
  done
  if [[ $hits -eq 0 ]]; then
    skip "Pattern '$pattern' matched no skills."
  fi
done

if [[ ${#MATCHED[@]} -eq 0 ]]; then
  err "No skills matched the given pattern(s): ${SKILL_PATTERNS[*]}"
  info "Available skills: ${SKILL_NAMES[*]}"
  exit 1
fi

echo ""
info "Matched ${#MATCHED[@]} skill(s):"
for m in "${MATCHED[@]}"; do match "  $m"; done
echo ""

# ── 4. Dry-run gate ─────────────────────────────────────────────────────
if $DRY_RUN; then
  info "[dry-run] No skills were installed. Remove --dry-run to install."
  exit 0
fi

# ── 5. Install each matched skill ───────────────────────────────────────
FAILED=()
SUCCESS=()

for name in "${MATCHED[@]}"; do
  info "Installing skill: $name ..."
  cmd=(npx skills add "$REPO_URL" --skill "$name")
  for adp in "${ADAPTERS[@]}"; do cmd+=(-a "$adp"); done
  [[ -n "$GLOBAL_FLAG" ]] && cmd+=("$GLOBAL_FLAG")
  [[ -n "$YES_FLAG" ]] && cmd+=("$YES_FLAG")
  cmd+=("${EXTRA_ARGS[@]}")

  if "${cmd[@]}" 2>&1 | sed 's/^/  /'; then
    SUCCESS+=("$name")
  else
    err "Failed to install '$name'"
    FAILED+=("$name")
  fi
done

# ── 6. Summary ──────────────────────────────────────────────────────────
echo ""
info "Done. Installed: ${#SUCCESS[@]}/${#MATCHED[@]}"
[[ ${#SUCCESS[@]} -gt 0 ]] && match "  OK:     ${SUCCESS[*]}"
[[ ${#FAILED[@]}  -gt 0 ]] && err   "  FAILED: ${FAILED[*]}"
[[ ${#FAILED[@]}  -gt 0 ]] && exit 1
exit 0
