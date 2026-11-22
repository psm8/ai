"""Check a tailored CV against the base.

Rules:
- few changed lines, same structure, every new word comes from the offer or the base;
- locked lines never change: name, contact, company/title/date (###), education, languages;
- a changed line keeps its numbers: no number the base line didn't have (dates, metrics, versions);
- no new seniority word in a line (Senior -> Lead, "led", "architect" ...);
- Skills lines: an item that is genuinely added (not a rename or reorder) must be listed in
  CV-skills-tiers.md ("On the CV" table, or named there as "only if a job post names it").
"""
import difflib
import os
import re
import sys

MAX_CHANGED_LINES = 5
TOKEN = re.compile(r"[\w+#.]+")
NUMBER = re.compile(r"(?<![A-Za-z])\d+(?:[.,]\d+)?")  # skip digits inside names like OAuth2
SENIORITY = {"senior", "lead", "leads", "led", "leading", "principal", "staff", "head", "architect",
             "architected", "manager", "managed", "director", "chief", "expert", "owner", "owned", "cto"}
SKILLS_LINE = re.compile(r"^- \*\*([^*:]+):\*\*\s*(.*)$")

sys.stdout.reconfigure(encoding="utf-8")
base_path, tailored_path, offer_path = sys.argv[1:4]
tiers_path = sys.argv[4] if len(sys.argv) > 4 else os.path.join(os.path.dirname(os.path.abspath(base_path)), "CV-skills-tiers.md")

base = open(base_path, encoding="utf-8").read()
tailored = open(tailored_path, encoding="utf-8").read()
allowed = {t.lower().strip(".") for t in TOKEN.findall(base + " " + open(offer_path, encoding="utf-8").read())}


def tiers_text():
    """Skills the tiers file allows on the CV: the 'On the CV' section plus 'only if a job post names it' items."""
    try:
        text = open(tiers_path, encoding="utf-8").read()
    except OSError:
        return None
    on_cv = re.search(r"## On the CV.*?(?=\n## )", text, re.S)
    extra = [line for line in text.splitlines() if "job post names it" in line or "if a job post" in line]
    return ((on_cv.group(0) if on_cv else "") + "\n" + "\n".join(extra)).lower()


TIERS = tiers_text()


def is_locked(line):
    s = line.strip()
    return (s.startswith("# ") or s.startswith("### ") or s.startswith("**Senior") or "@" in s
            or s.startswith("**B.Sc") or s.startswith("Polish (native)"))


def words(line):
    return {t.lower().strip(".") for t in TOKEN.findall(line)}


def skill_items(rest):
    # split on commas that are not inside parentheses
    items, depth, cur = [], 0, ""
    for ch in rest:
        depth += ch == "("
        depth -= ch == ")"
        if ch == "," and depth == 0:
            items.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur.strip():
        items.append(cur.strip())
    return [i.lower() for i in items]


base_lines, new_lines = base.splitlines(), tailored.splitlines()
problems = []
changed = 0
for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, base_lines, new_lines, autojunk=False).get_opcodes():
    if tag == "equal":
        continue
    changed += max(i2 - i1, j2 - j1)
    if i2 - i1 != j2 - j1:
        problems.append(f"lines added or removed near base line {i1 + 1}: keep the base structure")
    for old, new in zip(base_lines[i1:i2], new_lines[j1:j2]):
        short = new[:80]
        if is_locked(old) or is_locked(new):
            problems.append(f"locked line changed (name/contact/company/title/dates/education/languages): {short}")
        foreign = [t for t in TOKEN.findall(new) if t.lower().strip(".") not in allowed]
        if foreign:
            problems.append(f"words in neither base nor offer: {foreign} in: {short}")
        new_numbers = [n for n in NUMBER.findall(new) if n not in NUMBER.findall(old)]
        if new_numbers:
            problems.append(f"numbers not in the base line: {new_numbers} in: {short}")
        new_seniority = (words(new) & SENIORITY) - words(old)
        if new_seniority:
            problems.append(f"new seniority word(s) {sorted(new_seniority)} in: {short}")
        mo, mn = SKILLS_LINE.match(old.strip()), SKILLS_LINE.match(new.strip())
        if mo and mn:
            if mo.group(1) != mn.group(1):
                problems.append(f"Skills category renamed: {mo.group(1)} -> {mn.group(1)}")
            old_items, new_items = skill_items(mo.group(2)), skill_items(mn.group(2))
            added = [i for i in new_items if i not in old_items]
            removed = [i for i in old_items if i not in new_items]
            if TIERS is None and len(added) > len(removed):
                problems.append(f"cannot read {tiers_path}: Skills additions unverifiable")
            elif TIERS is not None:
                untiered = [i for i in added if i not in TIERS]
                # renames pair with removed items; anything beyond that is a real addition
                if len(untiered) > len(removed):
                    problems.append(f"Skills additions not allowed by CV-skills-tiers.md: {untiered} in: {mn.group(1)}")

if changed > MAX_CHANGED_LINES:
    problems.append(f"{changed} changed lines, max {MAX_CHANGED_LINES}")
print("OK" if not problems else "FAIL\n" + "\n".join(problems))
print(f"changed lines: {changed}")
sys.exit(1 if problems else 0)
