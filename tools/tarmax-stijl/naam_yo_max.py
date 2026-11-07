"""Replace the visible app name "VoiceInk" with "Yo Max" inside Swift string literals.

Leaves alone: identifiers, model/product names ("VoiceInk Refine", "VoiceInk Pro"),
bundle IDs, paths, URLs, log subsystems, keys, licensing/GitHub-star/support code.
Then renames matching keys and values in Localizable.xcstrings.
"""
import json
import os
import re
import sys

# Usage: python3 -I tools/tarmax-stijl/naam_yo_max.py .   (from the repo root)
ROOT = sys.argv[1]
DIRS = ["VoiceInk", "Shared", "VoiceInkRefineXPC"]
NEW = "Yo Max"

# Not: "VoiceInk Refine", "VoiceInk Pro", "VoiceInk-..." (repository names, paths).
NAME = re.compile(r"\bVoiceInk\b(?! Refine| Pro|-)")
LITERAL = re.compile(r'"(?:[^"\\\n]|\\.)*"')

SKIP_FILES = (
    "/Features/Licensing/",
    "/Onboarding/Components/OnboardingLicenseCards.swift",
    "/Onboarding/Views/OnboardingLicenseScreen.swift",
    "/GitHubStarPrompt",
    "/GitHubCLIStarService.swift",
    "/Settings/Support/EmailSupport.swift",
)
SKIP_LINE = re.compile(
    r"Logger\(|DispatchQueue\(label|NSUserInterfaceItemIdentifier|domain:|com\.|https?://|"
    r"Beingpax|appendingPathComponent|forHTTPHeaderField|PasteboardType|thread\.name|"
    r"\$HOME|repoSlug|forKey|Key\b|logger\.|^\s*//|"
    # GPL credit and model repositories must keep the VoiceInk name.
    r"repositoryID|open-source VoiceInk"
)
SPECIAL = {
    '"VoiceInk is also open source, so you can inspect every single line of code."':
        '"Yo Max is based on the open-source VoiceInk, so you can inspect every single line of code."',
    '"VoiceInk-transcription.csv"': '"YoMax-transcription.csv"',
}

changed_files = []
for d in DIRS:
    for dirpath, _, files in os.walk(os.path.join(ROOT, d)):
        for f in files:
            if not f.endswith(".swift"):
                continue
            path = os.path.join(dirpath, f)
            rel = path[len(ROOT):]
            if any(s in rel for s in SKIP_FILES):
                continue
            lines = open(path, encoding="utf-8").read().split("\n")
            out, n = [], 0
            for line in lines:
                new = line
                for old, rep in SPECIAL.items():
                    new = new.replace(old, rep)
                if new == line and not SKIP_LINE.search(line):
                    new = LITERAL.sub(lambda m: NAME.sub(NEW, m.group(0)), line)
                if new != line:
                    n += 1
                out.append(new)
            if n:
                open(path, "w", encoding="utf-8").write("\n".join(out))
                changed_files.append((rel, n))

for rel, n in sorted(changed_files):
    print(f"{n:3d}  {rel}")
print("Swift-bestanden:", len(changed_files), "regels:", sum(n for _, n in changed_files))

# --- String catalog -------------------------------------------------------
swift_src = ""
for d in DIRS:
    for dirpath, _, files in os.walk(os.path.join(ROOT, d)):
        for f in files:
            if f.endswith(".swift"):
                swift_src += open(os.path.join(dirpath, f), encoding="utf-8").read()

FMT = re.compile(r"%(?:\d+\$)?(?:lld|ld|@|d|f|s|u)")
cat_path = os.path.join(ROOT, "VoiceInk/Localizable.xcstrings")
cat = json.load(open(cat_path, encoding="utf-8"))
strings = cat["strings"]
renamed = kept = 0
result = {}
for key, entry in strings.items():
    if not NAME.search(key):
        result[key] = entry
        continue
    fragments = [p for p in FMT.split(key) if NAME.search(p)]
    frag = max(fragments, key=len)
    # Still used verbatim in Swift (excluded file) -> keep the old key.
    if frag in swift_src:
        kept += 1
        result[key] = entry
        continue
    new_key = NAME.sub(NEW, key)
    for loc in entry.get("localizations", {}).values():
        su = loc.get("stringUnit")
        if su:
            su["value"] = NAME.sub(NEW, su["value"])
        for var in loc.get("variations", {}).values():
            for v in var.values():
                vsu = v.get("stringUnit")
                if vsu:
                    vsu["value"] = NAME.sub(NEW, vsu["value"])
    result[new_key] = entry
    renamed += 1

cat["strings"] = result
with open(cat_path, "w", encoding="utf-8") as fh:
    fh.write(json.dumps(cat, ensure_ascii=False, indent=2, separators=(",", " : ")) + "\n")
print("Catalogus: hernoemd", renamed, "behouden", kept)
