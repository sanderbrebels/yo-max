# Tarmax-stijl opnieuw toepassen

Yo Max wijkt sterk af van VoiceInk (Nederlands, eigen naam, volledige Tarmax-look). Neem je code van VoiceInk over (een merge van `upstream/main`), dan komt hun nieuwe code binnen met hun eigen lettertypes, kleuren en de naam "VoiceInk". Deze scripts zetten dat in één keer terug naar Yo Max.

Alle scripts zijn **veilig om opnieuw te draaien**: op code die al omgezet is, veranderen ze niets (getest op 2026-11-07).

## Na een merge met VoiceInk

1. Bij een conflict in een schermbestand: neem **hun** versie van die regels (de nieuwe VoiceInk-code).
2. Draai daarna vanuit de repo-map:

   ```bash
   python3 -I tools/tarmax-stijl/lettertypes.py VoiceInk
   python3 -I tools/tarmax-stijl/kleuren.py VoiceInk
   python3 -I tools/tarmax-stijl/naam_yo_max.py .
   ```

3. Kijk de wijzigingen na (`git diff`), bouw met `make local` en test.

## Wat elk script doet

| Script | Doet |
|---|---|
| `lettertypes.py` | `.system(size:…)` en standaardstijlen (`.title`, `.headline`, …) → `.yoMax(…)` (Aeonik, Tarmax-gewichten). `monospaced` blijft. |
| `kleuren.py` | `.secondary`/`.primary`/`.tertiary` en losse rood/grijs → `AppTheme.Text…`/`AppTheme.Status…`. Slaat Recording, Notifications en Licensing over (donkere grond). |
| `naam_yo_max.py` | Zichtbare teksten "VoiceInk" → "Yo Max", ook in `Localizable.xcstrings`. Laat staan: de GPL-vermelding ("based on the open-source VoiceInk"), "VoiceInk Refine", "VoiceInk Pro", repository-namen, paden, sleutels, logs en licentiecode. |
| `svg-naar-png.swift` | Rendert een vierkante SVG naar PNG (app-icoon): `swift tools/tarmax-stijl/svg-naar-png.swift uit.png 1024 design/icoon/yo-max-icoon.svg`. Met meer SVG's na elkaar krijg je ze naast elkaar (voorstellen vergelijken). |
| `svg-naar-png-rechthoek.swift` | Rendert een SVG op een vaste breedte en hoogte (dashboard-banner): `swift tools/tarmax-stijl/svg-naar-png-rechthoek.swift design/icoon/dashboard-banner.svg uit.png 2300 597`. Gebruik absolute paden als het laden faalt. |

App-icoon in alle maten opnieuw maken:

```bash
for s in 16 32 64 128 256 512 1024; do
  swift tools/tarmax-stijl/svg-naar-png.swift VoiceInk/Assets.xcassets/AppIcon.appiconset/$s-mac.png $s design/icoon/yo-max-icoon.svg
done
```

Let op: in SVG-commentaar mag geen dubbel streepje staan, anders laadt macOS het bestand niet.
