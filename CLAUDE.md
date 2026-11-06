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
- Testzinnen: `testzinnen.md` (15 zinnen + notitietabel). Eerste test (2026-11-06): 10/15 perfect; fouten vooral vaktermen die Whisper verkeerd hoort → woordenboek.
- Prompt "Nederlands" v2: tijden zoals gezegd ("half tien" blijft), kleine grammaticafouten herstellen, geen komma tussen onderwerp en werkwoord. Verander je de prompttekst, verhoog dan `PromptTemplates.dutchPromptVersion`, anders krijgt de opgeslagen prompt de nieuwe tekst niet.
- Crash bij afsluiten opgelost: `AppDelegate.applicationShouldTerminate` geeft eerst het Whisper-model vrij (whisper.cpp breekt anders af op zijn Metal-resources).

### Kopieerkader zonder tekstveld (zoals Wispr Flow)
- Na het dicteren kijkt `YoMaxTextFieldDetector` (`VoiceInk/App/YoMax/`) via Toegankelijkheid of er een tekstveld de focus heeft: `editable`, `notEditable` of `unknown`.
- Alleen bij `notEditable` (geen focus, of een knop/lijst/venster…) plakt Yo Max niet: de tekst gaat op het klembord en `YoMaxCopyPanelController` toont een Tarmax-kaart bovenaan het scherm met Copy-knop (verdwijnt na 15 s, blijft zolang de muis erop staat). Bij `unknown` (vaak browsers/Electron) wordt gewoon geplakt.
- Inhaakpunt: `TranscriptionDelivery.paste`. Uitzetten: Settings → "Show Copy Card Without Text Field" (`YoMaxDefaults.copyPanelKey`).

### Tarmax-stijl (fase 5)
- Bron: `~/GIT/tarmax/DESIGN_SYSTEMS.md` en `src/ui/theme/tokens.css`. Kleuren staan als palet in `AppTheme.Brand` (`DesignSystem/Theme/AppTheme.swift`); de rest van de app gebruikt alleen de betekenissen.
- Accent: ink `#0B1F0D` in licht (zoals de hoofdknop van Tarmax), lime `#86F46D` in donker. Zijbalk: brand-dark tegels met lime iconen, gekozen rij = lime pil met ink-tekst.
- Mini-recorder: brand-dark `#212520` met een lime golfvorm (11 ronde streepjes, symmetrisch, rustiger). De notch-recorder blijft zwart (gaat op in de notch).
- App-icoon: Tarmax-ruit met lime golfvorm op licht (`design/icoon/yo-max-icoon.svg`, exact gecentreerd). Menubalk: dezelfde ruit als template met 3 uitgespaarde streepjes (`design/icoon/menubalk-icoon.svg`). PNG's opnieuw maken: render de SVG naar 16–1024 px in `VoiceInk/Assets.xcassets/AppIcon.appiconset/`.
- **Lettertype Aeonik** (`Font.yoMax`, `VoiceInk/App/YoMax/YoMaxTypography.swift`): wordt gebruikt als het op de Mac geïnstalleerd is (`~/Library/Fonts`), anders het systeemlettertype. **Aeonik is betaald: nooit in de app bundelen of in git zetten** (de repo is openbaar). Een vriend ziet dus gewoon SF Pro.
- **Design system via de themalaag (keuze A, 2026-11-06):** de Tarmax-elevation zit in `AppTheme` (Surface, Border, Text, Status, Selection, Insights, Radius) en `AppSurfaces`, die de app al ±650 keer gebruikt. Pagina `#F5F5F5` (donker zwart), kaarten wit zonder rand en schaduw (radius 20), zachte vulling `#F6FAF5`, muted tekst `#657064`, Tarmax-statuskleuren. Het content-gebied is een dekkende pagina (geen doorschijnend materiaal meer). Dashboard-banner: `design/icoon/dashboard-banner.svg` → `momentum-hero-bg`. Schermen die nog "VoiceInk" ogen (losse kleuren in de view-code): één voor één omzetten wanneer nodig. Let op: in SVG-commentaar mag geen dubbel streepje staan, anders laadt macOS het bestand niet.
- **Volledig Tarmax (keuze B, fase 6, 2026-11-06):** Sander koos bewust voor de volledige look, ook al botsen VoiceInk-updates daardoor meer.
  - Alle lettertypes via `Font.yoMax` (±520 `.system(size:)` en 128 standaardstijlen in 104 bestanden, met een script). Rounded is weg; `monospaced` bleef. Typeschaal: macOS-groottes met Tarmax-gewichten (titels/koppen 500, tekst 400, alleen 400/500/700). Nieuwe code: altijd `.font(.yoMax(…))`, nooit `.system(size:)`.
  - `.secondary`/`.primary`/`.tertiary` en losse rood/grijs → `AppTheme.Text…`/`AppTheme.Status…` (niet in Recording, Notifications en Licensing: donkere grond). Grafiekkleuren (`AppTheme.Data`) uit het Tarmax-palet.
  - Zijbalk: zwevende witte kaart (12 pt marge, radius 24, schaduw) op de pagina, gekozen rij = lime pil. Pilknoppen via `.buttonBorderShape(.capsule)` op de root. Dashboard-titels 500 en de banner niet meer wazig.
  - **VoiceInk-updates:** een merge raakt nu bijna altijd een paar van deze regels. Los conflicten op door hun nieuwe code te nemen en daarna opnieuw de lettertype- en kleurregels toe te passen (zelfde omzetting: `.system(size:` → `.yoMax(`, `.secondary` → `AppTheme.Text.secondary`). Of neem nieuwe VoiceInk-functies met de hand over.

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
- [x] Testzinnen (`testzinnen.md`) dicteren met Groq en de prompt "Nederlands" bijstellen (v2).
- [ ] Testzinnen opnieuw dicteren met prompt v2 en het gevulde woordenboek.
- [ ] `qwen/qwen3.8-27b` vs. `openai/gpt-oss-120b` vergelijken op Nederlands en snelheid.
- [ ] Snelheid en kwaliteit vergelijken: Whisper Turbo vs. Parakeet V3.
- [ ] Woordenboek (Dictionary) vullen met eigen namen en vaktermen (Tarmax, MacBook, staging, …).

### Branding en design
- [x] Eigen app-icoon (`VoiceInk/Assets.xcassets/AppIcon.appiconset`).
- [x] Eigen menubalk-icoon (`menuBarIcon.imageset`).
- [x] Eigen accentkleur en kleuren (`AccentColor.colorset`, `DesignSystem/Theme/AppTheme.swift`).
- [x] Eigen opname-animatie en golfvorm (`Features/Recording/Components/AudioVisualizerView.swift`).
- [x] Recorder-venster restylen (`Features/Recording/Views/MiniRecorderView.swift`; notch blijft zwart).
- [x] Tarmax-elevation en tokens via de themalaag (pagina, kaarten, tekst, status).
- [ ] Schermen met losse kleuren één voor één naar tokens omzetten (screenshot bekijken).
- [x] Aeonik en Tarmax-kleuren in alle schermen (fase 6).
- [ ] Optioneel: geluidjes bij start/stop van de opname.

### Functies
- [ ] Stijl per app (formeel in Mail, los in Slack/WhatsApp) via Modes met app-triggers.
- [ ] Lokale opschoning via Ollama, zodat niets meer naar de cloud gaat.
- [ ] Koppeling met Sanders app **Tarmax**.

### Delen
- [ ] Branch `yo-max` naar de fork pushen (pas als Sander het vraagt) en de vriend de link geven.
