---
name: yo-max-start
description: Start een werksessie aan Yo Max (de dicteer-app in ~/GIT/yo-max). Haalt het laatste werk binnen van GitHub (origin, branch yo-max), kijkt of VoiceInk nieuwe updates heeft (upstream), controleert of alles gecommit is, leest CLAUDE.md en geeft een korte status met de to-do en voorstellen voor de volgende stap. Gebruik bij "/yo-max-start", "yo-max start", "verder met Yo Max", "waar waren we" over Yo Max.
---

# Yo Max — een sessie starten

Je hervat het werk aan Yo Max in `~/GIT/yo-max`. `CLAUDE.md` is het geheugen; vertrouw niet op oude chats. Antwoord in het Nederlands, kort.

## 1. Binnenhalen en controleren

Parallel waar het kan:

- `git status -sb`: staat er niet-gecommit werk open? Meld het en gooi nooit iets weg.
- `git fetch origin` en `git fetch upstream`.
- Bestaat `origin/yo-max` en loopt die voor? Dan `git pull --ff-only origin yo-max`. Lukt fast-forward niet (de twee kanten liepen uiteen): niets forceren, toon het verschil (`git log --oneline HEAD..origin/yo-max` en `origin/yo-max..HEAD`) en vraag wat Sander wil.
- **Nieuwe VoiceInk-updates (aanpak A, kiezen en overnemen):** `git log --oneline HEAD..upstream/main`. Lees de titels (en bij twijfel `git show --stat <commit>`) en deel ze in twee groepen:
  - **Telt voor Yo Max:** Whisper of lokale transcriptie, plakken, fn/sneltoetsen, de recorder, crashfixes, beveiliging, nieuwe macOS-versies, geheugen of snelheid.
  - **Laten liggen:** cloudproviders (Soniox, ElevenLabs, Deepgram, …), betaalde functies, VoiceInk Pro of licenties, hun eigen branding en website.
  Meld per groep het aantal en de belangrijkste titels in gewone taal. **Niet zelf overnemen**: dat gebeurt pas als Sander kiest, meestal met `git cherry-pick <commit>` en daarna de scripts in `tools/tarmax-stijl/` (zie `CLAUDE.md` › "VoiceInk-updates binnenhalen").
- Kwamen er commits binnen via de pull, of draait er een oudere build? Stel `make local` voor (en herinner aan de Toegankelijkheid-toestemming na elke build). Bouw niet ongevraagd.

## 2. Status

Vaste kopjes, kort per punt:

1. **Stand:** branch, laatste commit, alles gecommit en op GitHub of niet, hoeveel nieuwe VoiceInk-commits.
2. **Laatst gedaan:** de laatste commits (`git log --oneline -5`) in gewone taal.
3. **To-do:** de open punten uit `CLAUDE.md` › "To-do / ideeën voor later", per groep.
4. **Om rekening mee te houden:** dingen die nog niet getest zijn, of bekende valkuilen uit `CLAUDE.md`.

## 3. Voorstellen

Drie genummerde voorstellen, in volgorde van wat je aanraadt, met per voorstel: wat het oplevert, klein/middel/groot, en of Sander zelf iets moet doen (testen met fn, een keuze maken). Sluit af met één aanbeveling en de vraag waar hij wil beginnen. Begin niet zelf te bouwen.

Voor iets visueels: eerst een prototype (zie `CLAUDE.md` › "Werkafspraken" › prototypes), pas na zijn keuze in Swift bouwen.
