"""Yo Max fase 6: lettertypes naar Font.yoMax (Tarmax-typeschaal), Rounded weg, monospaced blijft."""
import os, re, sys
ROOT = sys.argv[1]
SKIP = ("/App/YoMax/YoMaxTypography.swift",)

def find_close(s, i):
    # s[i] == '('; return index of matching ')'
    depth = 0
    for j in range(i, len(s)):
        c = s[j]
        if c == '(':
            depth += 1
        elif c == ')':
            depth -= 1
            if depth == 0:
                return j
    return -1

def split_args(a):
    parts, depth, cur = [], 0, ""
    for c in a:
        if c in "([":
            depth += 1
        elif c in ")]":
            depth -= 1
        if c == "," and depth == 0:
            parts.append(cur.strip()); cur = ""
        else:
            cur += c
    if cur.strip():
        parts.append(cur.strip())
    return parts

def convert_system(s):
    out, i, n = [], 0, 0
    key = ".system(size:"
    while True:
        k = s.find(key, i)
        if k < 0:
            out.append(s[i:]); break
        open_i = k + len(".system")
        close_i = find_close(s, open_i)
        args = split_args(s[open_i + 1:close_i])
        named = {}
        ok = True
        for a in args:
            m = re.match(r"(size|weight|design):\s*(.+)$", a, re.S)
            if not m:
                ok = False; break
            named[m.group(1)] = m.group(2)
        if not ok or "monospaced" in named.get("design", ""):
            out.append(s[i:close_i + 1]); i = close_i + 1; continue
        new = ".yoMax(" + named["size"] + (", weight: " + named["weight"] if "weight" in named else "") + ")"
        out.append(s[i:k] + new)
        i = close_i + 1; n += 1
    return "".join(out), n

# macOS-groottes, Tarmax-gewichten (titels en koppen 500, tekst 400)
SEMANTIC = {
    "largeTitle": "26, weight: .medium", "title": "22, weight: .medium", "title2": "17, weight: .medium",
    "title3": "15, weight: .medium", "headline": "13, weight: .medium", "subheadline": "11",
    "body": "13", "callout": "12", "footnote": "10", "caption": "10", "caption2": "10",
}
sem_re = re.compile(r"\.font\(\.(largeTitle|title3|title2|title|headline|subheadline|body|callout|footnote|caption2|caption)\)")

total_sys = total_sem = files = 0
for d in ("App", "Features", "DesignSystem", "Infrastructure", "Shared"):
    base = os.path.join(ROOT, d)
    for dp, _, fs in os.walk(base):
        for f in fs:
            if not f.endswith(".swift"):
                continue
            p = os.path.join(dp, f)
            if any(p.endswith(x) for x in SKIP):
                continue
            s = open(p, encoding="utf-8").read()
            s2, n1 = convert_system(s)
            s2, n2 = sem_re.subn(lambda m: ".font(.yoMax(%s))" % SEMANTIC[m.group(1)], s2)
            if s2 != s:
                open(p, "w", encoding="utf-8").write(s2)
                total_sys += n1; total_sem += n2; files += 1
print("bestanden", files, "system(size:)", total_sys, "standaardstijlen", total_sem)
