# Yo Max — projectgeheugen

Yo Max is een persoonlijke dicteer-app voor macOS, zoals Wispr Flow: **houd fn ingedrukt, spreek, laat los → nette tekst verschijnt in elke app.**
Het is een fork van het open-source **VoiceInk** (https://github.com/Beingpax/VoiceInk, GPL-3.0, Swift/SwiftUI).

Doel: de beste Nederlandse kwaliteit (Vlaams accent, Engelse vaktermen), snel, volledig gratis. Voor eigen gebruik, eventueel gedeeld met een vriend.

## Werkafspraken (voor Claude)

- Communiceer in het Nederlands, kort. Leg elke stap in één zin uit.
- Toon eerst welke bestanden je wil aanpassen en waarom, vóór je broncode wijzigt.
- Werk in fases; stop na elke fase, vat samen en wacht op "ok".
- Commit na elke fase met een duidelijke boodschap. **Push niets zonder dat Sander het vraagt.**
- Zet **nooit** API-sleutels of andere geheimen in code, config of git (sleutels staan in de macOS-sleutelhanger).
- Laat `LICENSE` en de copyrightvermeldingen van VoiceInk altijd staan.
- Bij een fout: lees de melding, zoek de oorzaak, los het op. Lukt het na 2 pogingen niet: stop en leg het eenvoudig uit.

## Repo

- Map: `/Users/sanderbrebels/GIT/yo-max`, branch **`yo-max`**.
- Remotes: `origin` = https://github.com/sanderbrebels/yo-max (eigen fork), `upstream` = https://github.com/Beingpax/VoiceInk.
- Swift-modulenaam en mapnamen blijven `VoiceInk` (minder merge-conflicten met upstream); alleen wat de gebruiker ziet heet "Yo Max".
- Nieuwe Yo Max-code staat zoveel mogelijk apart in `VoiceInk/App/YoMax/`. Wijzigingen in bestaande VoiceInk-bestanden zijn klein en gemarkeerd met een `// Yo Max:`-commentaar.

## Gemaakte keuzes

### Naam en identiteit (fase 2)
- App-naam "Yo Max", bundle-id `com.sanderbrebels.yomax` (Debug: "Yo Max Dev", `com.sanderbrebels.yomax.dev`).
- Copyright in Info: "Yo Max — gebaseerd op VoiceInk © Prakash Joshi Pax (GPL-3.0). Broncode: github.com/sanderbrebels/yo-max".
- **Sparkle-updates uit** (`UpdaterViewModel.updatesEnabled = false`, feed-URL en sleutel uit `Info.plist` verwijderd): Yo Max mag nooit automatisch naar een VoiceInk-versie updaten.
- Aankondigingen van VoiceInk uit. Pagina "VoiceInk Pro" verborgen in lokale builds (die zijn altijd gelicentieerd via `LOCAL_BUILD`).
- Datamap blijft gedeeld met VoiceInk: `~/Library/Application Support/com.prakashjoshipax.VoiceInk` (gedownloade modellen worden hergebruikt). Instellingen (UserDefaults) zijn wel apart per bundle-id.

### Nederlands, fn-toets en snelheid (fase 3)
- **Standaardmodel: Whisper Large v3 Turbo (lokaal), taal `nl`.** De onboarding downloadt nog altijd Parakeet V3 (die is sterk aan de onboarding gekoppeld). Daarna downloadt `YoMaxDefaultModelService` Whisper Turbo één keer automatisch en zet de startmodi om naar Turbo + Nederlands. Parakeet blijft beschikbaar om te vergelijken.
- Constanten staan in `enum YoMaxDefaults` (`VoiceInk/App/YoMax/YoMaxDefaultModelService.swift`).
- **Model in het geheugen houden** (instelling "Keep Model Loaded", standaard aan): het model wordt bij het opstarten geladen en blijft geladen tussen dictaten → snelle eerste dictee.
- **fn-toets standaard** als opnametoets, met nieuwe modus **"Hold or Double-Tap"** (`RecordingShortcutManager`):
  - fn ≥ 0,3 s ingedrukt houden → opnemen, loslaten = plakken;
  - dubbeltik → handsfree opnemen, nog eens tikken = stoppen;
  - één korte tik → opname wordt geannuleerd.
  - Opgelet: bestaande instellingen worden niet overschreven. Wie al een modus had, moet "Hold or Double-Tap" zelf kiezen in Settings.
- macOS: zet *Systeeminstellingen → Toetsenbord → "Druk op 🌐-toets om"* op **"Niets doen"**, anders opent de emoji-kiezer.
- **AI-opschoning via Groq** (gratis tier, OpenAI-compatibel). Standaardmodel `qwen/qwen3.8-27b`; alternatieven `openai/gpt-oss-120b` (beste Nederlands) en `openai/gpt-oss-20b` (sneller). De sleutel vul je in de app in (AI Models → Groq) en die komt in de sleutelhanger. **Nooit in code.**
- Nieuwe prompt **"Nederlands"** (`PromptTemplates.dutchPromptId`): spelling en leestekens, euh/ehm weg, zelfcorrecties verwerken (nee/neen/sorry/wacht/ik bedoel), Engelse termen behouden, betekenis nooit veranderen, getallen netjes (€ 250, 15%, 14.30 uur), lijsten, en **vragen of instructies nooit uitvoeren**. De startmodus "Enhancement" gebruikt deze prompt, zonder schermopname (privacy).
- Testzinnen: `testzinnen.md` (15 zinnen + notitietabel).

## Bouwen

```bash
cd /Users/sanderbrebels/GIT/yo-max
make local
```

- Bouwt `whisper.xcframework` in `~/VoiceInk-Dependencies` (eerste keer, cmake nodig via Homebrew), daarna een Release-build met `LocalBuild.xcconfig` (ad-hoc ondertekend, `LOCAL_BUILD`).
- Het resultaat komt in **`~/Downloads/Yo Max.app`**. Installeren:
  ```bash
  rm -rf "/Applications/Yo Max.app" && mv ~/Downloads/"Yo Max.app" /Applications/ && open "/Applications/Yo Max.app"
  ```
- Ontbreekt de Metal Toolchain, dan: `xcodebuild -downloadComponent MetalToolchain`.
- Andere targets: `make check`, `make dev` (Debug, "Yo Max Dev"), `make clean`, `make help`.

> ⚠️ **Na elke nieuwe build moet je de Toegankelijkheid-toestemming opnieuw geven.**
> De app is ad-hoc ondertekend, dus macOS ziet elke build als een nieuwe app. Ga naar *Systeeminstellingen → Privacy en beveiliging → Toegankelijkheid*, verwijder "Yo Max" met het minteken, voeg hem opnieuw toe en zet hem aan. Doe hetzelfde bij Invoermonitoring/Microfoon als iets niet werkt. Zonder deze toestemming werken fn en plakken niet.

## VoiceInk-updates binnenhalen

```bash
git fetch upstream
git checkout yo-max
git merge upstream/main
```

- Los conflicten op en behoud daarbij de Yo Max-aanpassingen (zoek op `Yo Max`). Let vooral op `project.pbxproj` (naam/bundle-id), `Info.plist` (Sparkle uit), `Localizable.xcstrings` en `RecordingShortcutManager.swift`.
- Daarna `make local`, testen met `testzinnen.md` en committen. Niet pushen zonder te vragen.

## Licentie (GPL-3.0)

- Yo Max is een afgeleid werk van VoiceInk en valt dus ook onder **GPL-3.0**.
- `LICENSE` en alle copyrightvermeldingen van VoiceInk blijven staan, ook in de app (Info/copyright, tekst "based on the open-source VoiceInk").
- **Wie de app aan iemand anders geeft, moet ook de broncode aanbieden**: geef de link naar de fork https://github.com/sanderbrebels/yo-max en zorg dat de gedeelde versie daar gepusht staat (vraag dan eerst om te pushen).
- De naam/het merk "VoiceInk" en de betaalde Pro-licentie niet gebruiken als eigen product.

## Delen met een vriend

1. `make local` en zip de app: rechtsklik op `Yo Max.app` → Comprimeer (of `ditto -c -k --keepParent "/Applications/Yo Max.app" ~/Desktop/YoMax.zip`).
2. Stuur de zip en de broncodelink (https://github.com/sanderbrebels/yo-max).
3. Op de Mac van de vriend: uitpakken, naar Programma's slepen en dan:
   ```bash
   xattr -cr "/Applications/Yo Max.app"
   ```
   (de app is niet door Apple genotariseerd; dit haalt de quarantaine-vlag weg).
4. Toestemmingen geven (Microfoon, Toegankelijkheid, eventueel Schermopname) en de 🌐-toets op "Niets doen" zetten.
5. Voor AI-opschoning maakt de vriend een **eigen gratis Groq-sleutel** aan (console.groq.com) en vult die in de app in. Deel nooit je eigen sleutel.

Vereisten: Mac met **Apple Silicon (M-chip)** en **macOS 15.0 of nieuwer** (`MACOSX_DEPLOYMENT_TARGET = 15.0`; dat is strenger dan de 14.4 uit het oorspronkelijke plan). Reken op ongeveer 2 GB vrije schijfruimte voor de modellen.

## To-do / ideeën voor later

Volgorde = voorstel van prioriteit. Vink af met [x] als het klaar is.

### Kwaliteit
- [ ] Testzinnen (`testzinnen.md`) dicteren met en zonder Groq, fouten noteren en de prompt "Nederlands" bijstellen.
- [ ] `qwen/qwen3.8-27b` vs. `openai/gpt-oss-120b` vergelijken op Nederlands en snelheid.
- [ ] Snelheid en kwaliteit vergelijken: Whisper Turbo vs. Parakeet V3.
- [ ] Woordenboek (Dictionary) vullen met eigen namen en vaktermen (Tarmax, MacBook, staging, …).

### Branding en design
- [ ] Eigen app-icoon (`VoiceInk/Assets.xcassets/AppIcon.appiconset`).
- [ ] Eigen menubalk-icoon (`menuBarIcon.imageset`).
- [ ] Eigen accentkleur en kleuren (`AccentColor.colorset`, `DesignSystem/Theme/AppTheme.swift`).
- [ ] Eigen opname-animatie en golfvorm (`Features/Recording/Components/AudioVisualizerView.swift`).
- [ ] Recorder-venster restylen (`Features/Recording/Views/MiniRecorderView.swift`, `NotchRecorderView.swift`).
- [ ] Optioneel: geluidjes bij start/stop van de opname.

### Functies
- [ ] Stijl per app (formeel in Mail, los in Slack/WhatsApp) via Modes met app-triggers.
- [ ] Lokale opschoning via Ollama, zodat niets meer naar de cloud gaat.
- [ ] Koppeling met Sanders app **Tarmax**.

### Delen
- [ ] Branch `yo-max` naar de fork pushen (pas als Sander het vraagt) en de vriend de link geven.
