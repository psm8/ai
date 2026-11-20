"""Render a CV markdown file into the styling of the existing CV docx (used as template)."""
import copy
import re
import sys

import docx

template, md_path, out_path = sys.argv[1:4]
doc = docx.Document(template)
paras = doc.paragraphs
proto = {
    "name": paras[0], "contact": paras[1], "heading": paras[2], "body": paras[3],
    "company": paras[5], "italic": paras[6], "sub": paras[7], "bullet": paras[8],
}
proto = {k: copy.deepcopy(p._p) for k, p in proto.items()}
body = doc.element.body
sectPr = body[-1] if body[-1].tag.endswith("sectPr") else None
for p in list(paras):
    body.remove(p._p)

W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"


def segments(text):
    out = []
    for tok in re.split(r"(\*\*.+?\*\*|(?<!\*)\*[^*]+?\*(?!\*))", text):
        if not tok:
            continue
        if tok.startswith("**"):
            out.append((tok[2:-2], True, False))
        elif tok.startswith("*"):
            out.append((tok[1:-1], False, True))
        else:
            out.append((tok, False, False))
    return out


def add(kind, text, force_bold=None, force_italic=None):
    p_el = copy.deepcopy(proto[kind])
    runs = p_el.findall(W + "r")
    rpr_src = runs[0].find(W + "rPr")
    for r in runs:
        p_el.remove(r)
    if sectPr is not None:
        sectPr.addprevious(p_el)
    else:
        body.append(p_el)
    para = docx.text.paragraph.Paragraph(p_el, doc._body)
    for seg, bold, italic in segments(text):
        run = para.add_run(seg)
        if rpr_src is not None:
            run._r.insert(0, copy.deepcopy(rpr_src))
        run.bold = force_bold if force_bold is not None else bold
        run.italic = force_italic if force_italic is not None else italic


lines = open(md_path, encoding="utf-8").read().splitlines()
first_para_after_heading = False
for line in lines:
    s = line.rstrip()
    if not s:
        continue
    if s.startswith("# "):
        add("name", s[2:], force_bold=True)
    elif s.startswith("## "):
        add("heading", s[3:].upper(), force_bold=True)
    elif s.startswith("### "):
        add("company", s[4:], force_bold=True)
    elif s.startswith("- "):
        add("bullet", s[2:])
    elif re.fullmatch(r"\*[^*].*[^*]\*", s):
        add("italic", s[1:-1], force_italic=True)
    elif re.fullmatch(r"\*\*[^*]+\*\*", s):
        add("sub", s[2:-2], force_bold=True)
    elif s.startswith("**Senior") or "@" in s:
        add("contact", s)
    else:
        add("body", s)

doc.save(out_path)
print("saved", out_path)
