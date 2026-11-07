---
name: yo-max-stop
description: Sluit een werksessie aan Yo Max (~/GIT/yo-max) netjes af. Controleert dat er geen geheimen, betaalde lettertypes of buildbestanden in git komen, werkt CLAUDE.md bij (keuzes en to-do), commit wat af is en zet alles op GitHub (origin, branch yo-max). Gebruik bij "/yo-max-stop", "yo-max stop", "rond af", "zet alles op git", "stop voor vandaag" over Yo Max.
---

# Yo Max — een sessie afsluiten

Je rondt het werk aan Yo Max in `~/GIT/yo-max` af, zodat `/yo-max-start` de volgende keer zonder deze chat verder kan. Antwoord in het Nederlands, kort. Gooi nooit werk weg en herschrijf geen geschiedenis. Sander typt deze skill zelf: dat is zijn vraag om te pushen.

## 1. Stand opnemen

- `git status -sb` en `git log --oneline origin/yo-max..HEAD` (bestaat `origin/yo-max` nog niet, dan is alles nieuw).
- Niet-gecommit werk: hoort het bij iets wat Sander goedkeurde? Afronden en committen. Half of afgewezen? Vraag het; weggooien alleen als hij het zegt.

## 2. Veiligheidscontrole (verplicht vóór de push, de repo is openbaar)

Op wat gepusht wordt (`git diff origin/yo-max..HEAD`, of de hele boom als de branch nieuw is) en de staging:

- **Geen geheimen:** zoek naar `gsk_`, `sk-`, `api_key`, `apiKey =`, `Bearer `, `.env`, private keys. API-sleutels horen in de macOS-sleutelhanger, nooit in git.
- **Geen Aeonik of andere betaalde lettertypes:** geen `*.woff2`, `*.ttf`, `*.otf` in de repo (Aeonik komt van `~/Library/Fonts`).
- **Geen buildbestanden:** niets uit `.local-build/`, geen `.app`, geen `xcuserdata`.
- `LICENSE` en de VoiceInk-copyright staan er nog.

Vind je iets: stop, toon het en push niet.

## 3. CLAUDE.md bijwerken

- Nieuwe keuzes van deze sessie bij "Gemaakte keuzes", kort en met de bestanden erbij.
- To-do: afvinken wat af is (`[x]`), nieuwe punten erbij. Wat nog niet getest is, zeg je erbij.
- Nieuwe lessen over de samenwerking bij "Werkafspraken".
- Deze skill en `/yo-max-start` bijwerken als de werkwijze veranderde.

## 4. Vastleggen en op GitHub zetten

- Commit de laatste wijzigingen gericht, met een zin over het resultaat en de attributieregel.
- Push: `git push -u origin yo-max` (de eerste keer zet `-u` de koppeling).
  - **Nooit** `--force`, nooit naar `main` en nooit naar `upstream` (dat is VoiceInk zelf).
  - Geweigerd? `git fetch origin`, toon het verschil en vraag wat Sander wil.
- Controleer met `git status -sb` dat alles op GitHub staat.

## 5. Overdracht

Meld in een paar regels: wat er deze sessie bijkwam, de commit op GitHub (link: https://github.com/sanderbrebels/yo-max/tree/yo-max), wat nog niet getest is, en waar `/yo-max-start` de volgende keer verder kan. Tijdelijke bestanden staan in de scratchpad, niet in de repo.
