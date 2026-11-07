"""Yo Max fase 6: systeemgrijs en losse kleuren naar Tarmax-tokens. Recorder en notificaties (donkere grond) blijven."""
import os, re, sys
ROOT = sys.argv[1]
SKIP_DIRS = ("/Features/Recording/", "/App/Notifications/", "/Features/Licensing/")
REPL = [
    (re.compile(r"\.foreground(Color|Style)\(\.secondary\)"), r".foreground\1(AppTheme.Text.secondary)"),
    (re.compile(r"\.foreground(Color|Style)\(\.primary\)"), r".foreground\1(AppTheme.Text.primary)"),
    (re.compile(r"\.foreground(Color|Style)\(\.tertiary\)"), r".foreground\1(AppTheme.Text.muted)"),
    (re.compile(r"\.foregroundStyle\(\.red\)"), ".foregroundStyle(AppTheme.Status.error)"),
    (re.compile(r"Color\(nsColor: \.systemRed\)"), "AppTheme.Status.error"),
    (re.compile(r"\bColor\.red\b"), "AppTheme.Status.error"),
    (re.compile(r"\bColor\.gray\b"), "AppTheme.Text.secondary"),
]
counts = {}
files = 0
for d in ("App", "Features", "DesignSystem"):
    for dp, _, fs in os.walk(os.path.join(ROOT, d)):
        for f in fs:
            if not f.endswith(".swift"):
                continue
            p = os.path.join(dp, f)
            if any(x in p for x in SKIP_DIRS) or "/DesignSystem/Theme/" in p:
                continue
            s = open(p, encoding="utf-8").read(); s0 = s
            for rx, rep in REPL:
                s, n = rx.subn(rep, s)
                counts[rx.pattern] = counts.get(rx.pattern, 0) + n
            if s != s0:
                open(p, "w", encoding="utf-8").write(s); files += 1
print("bestanden", files)
for k, v in counts.items():
    print(v, k)
