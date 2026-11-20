"""Check a tailored CV against the base: few changed lines, every new word from the offer or the base."""
import difflib
import re
import sys

MAX_CHANGED_LINES = 5
TOKEN = re.compile(r"[\w+#.]+")

sys.stdout.reconfigure(encoding="utf-8")
base_path, tailored_path, offer_path = sys.argv[1:4]
base = open(base_path, encoding="utf-8").read()
tailored = open(tailored_path, encoding="utf-8").read()
allowed = {t.lower().strip(".") for t in TOKEN.findall(base + " " + open(offer_path, encoding="utf-8").read())}

base_lines, new_lines = base.splitlines(), tailored.splitlines()
problems = []
changed = 0
for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, base_lines, new_lines).get_opcodes():
    if tag == "equal":
        continue
    changed += max(i2 - i1, j2 - j1)
    if i2 - i1 != j2 - j1:
        problems.append(f"lines added or removed near base line {i1 + 1}: keep the base structure")
    for line in new_lines[j1:j2]:
        foreign = [t for t in TOKEN.findall(line) if t.lower().strip(".") not in allowed]
        if foreign:
            problems.append(f"words in neither base nor offer: {foreign} in: {line[:80]}")

if changed > MAX_CHANGED_LINES:
    problems.append(f"{changed} changed lines, max {MAX_CHANGED_LINES}")
print("OK" if not problems else "FAIL\n" + "\n".join(problems))
print(f"changed lines: {changed}")
sys.exit(1 if problems else 0)
