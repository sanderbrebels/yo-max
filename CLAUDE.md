# Yo Max — projectgeheugen

Yo Max is een persoonlijke dicteer-app voor macOS, zoals Wispr Flow: **houd fn ingedrukt, spreek, laat los → nette tekst verschijnt in elke app.**
Het is een fork van het open-source **VoiceInk** (https://github.com/Beingpax/VoiceInk, GPL-3.0, Swift/SwiftUI).

Doel: de beste Nederlandse kwaliteit (Vlaams accent, Engelse vaktermen), snel, volledig gratis. Voor eigen gebruik, eventueel gedeeld met een vriend.

## Werkafspraken (voor Claude)

- Communiceer in het Nederlands, kort. Leg elke stap in één zin uit.
- Toon eerst welke bestanden je wil aanpassen en waarom, vóór je broncode wijzigt.
- Werk in fases; stop na elke fase, vat samen en wacht op "ok".
- Commit na elke fase met een duidelijke boodschap. **Push niets zonder dat Sander het vraagt.** `/yo-max-stop` is die vraag: die skill controleert en pusht naar `origin/yo-max`.
- **Sessies:** begin met `/yo-max-start` (binnenhalen van GitHub, VoiceInk-updates melden, status en voorstellen) en eindig met `/yo-max-stop` (veiligheidscontrole, CLAUDE.md bijwerken, committen, pushen). Beide staan in `.claude/skills/`.
- **Eerst een prototype, dan Swift:** voor elke zichtbare wijziging maakt Claude eerst een prototype in HTML (twee of drie varianten naast elkaar, in de Tarmax-stijl): als Artifact (privé link) of als bestand in `design/schetsen/`. Sander kiest, pas daarna wordt het in Swift gebouwd.
- Zet **nooit** API-sleutels of andere geheimen in code, config of git (sleutels staan in de macOS-sleutelhanger).
- Laat `LICENSE` en de copyrightvermeldingen van VoiceInk altijd staan.
- Bij een fout: lees de melding, zoek de oorzaak, los het op. Lukt het na 2 pogingen niet: stop en leg het eenvoudig uit.
- **Eén vraag tegelijk.** Sander raakt het overzicht kwijt bij veel vragen in één bericht; loods hem stap voor stap door design- en motionkeuzes.
- **Bij een bug eerst de logs lezen:** `/usr/bin/log show --last 15m --info --predicate 'subsystem BEGINSWITH "com.prakashjoshipax"'` (de categorieën `CursorPaster`, `PasteFocusDiagnostics`, `YoMax…` tonen wat er bij het plakken gebeurde). Dictaten staan in `~/Library/Application Support/com.prakashjoshipax.VoiceInk/default.store` (SQLite, alleen-lezen openen) om ruwe en opgeschoonde tekst te vergelijken.
- **Testen na een build:** `make install` duurt soms langer dan 10 minuten: draai het op de achtergrond. Wat met fn moet gebeuren, test Sander zelf; zeg dat eerlijk.
- Zeg nooit dat iets "genoteerd" is voor het echt in CLAUDE.md staat.

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
- Prompt "Nederlands" v3 (2026-11-07): **staat op zichzelf** (`useSystemInstructions: false`), want de Engelse basisprompt van VoiceInk (`AIPrompts.enhancementSystemTemplate`) verbiedt formeler maken en opdrachten uitvoeren. Nieuw: **opmaakopdrachten**. Overal: "nieuwe alinea", "nieuwe regel", "tussen haakjes … haakje sluiten", leestekens. Alleen als laatste woorden: "maak er een lijstje van", "nummer dat", "maak het formeler/informeler/korter", "in het Engels". Alle andere vragen en opdrachten blijven gewone tekst.
- Prompt "Nederlands" v4 (2026-11-07): v3 herschreef te veel ("goeie" → "goede", andere woordvolgorde), omdat de strenge "zo weinig mogelijk veranderen"-regels van de VoiceInk-basisprompt wegvielen. v4 heeft bovenaan een blok `<PRESERVE>`: woorden, woordkeuze en woordvolgorde behouden, Vlaamse woorden letterlijk laten staan, bij twijfel niets veranderen, geen woorden toevoegen. Opmaakopdrachten werken nog.
- Crash bij afsluiten opgelost: `AppDelegate.applicationShouldTerminate` geeft eerst het Whisper-model vrij (whisper.cpp breekt anders af op zijn Metal-resources).

### Plakken waar je begon (2026-11-07)
- VoiceInk plakt in de app die vooraan staat als de tekst klaar is. Wie tijdens het praten van venster of scherm wisselt, verliest de tekst. `YoMaxPasteTarget` (`VoiceInk/App/YoMax/YoMaxPasteTarget.swift`) onthoudt bij de start van de opname (`VoiceInkEngine.toggleRecord`, staat `.starting`) de app vooraan, en zet die vlak voor het plakken (`TranscriptionDelivery.paste`) terug vooraan als er intussen een andere app vooraan staat. Nooit Yo Max zelf.
- **Terugzetten gaat via Toegankelijkheid**, niet via `NSRunningApplication.activate()`: sinds macOS 14 weigert macOS dat voor een app op de achtergrond (getest: tekst kwam in Notities). Bij de start wordt ook het venster onthouden (`kAXFocusedWindowAttribute`); voor het plakken: `kAXFrontmostAttribute` op de app, `kAXMainAttribute` + `AXRaise` op het venster, `activate()` alleen als terugval. Getest door Sander: Claude → Notities → plakt in Claude.
- Gevolg: je kan niet meer bewust tijdens het praten naar een andere app springen om daar te plakken.

### Kopieerkader zonder tekstveld (zoals Wispr Flow)
- Na het dicteren kijkt `YoMaxTextFieldDetector` (`VoiceInk/App/YoMax/`) via Toegankelijkheid in de app vooraan (nooit Yo Max zelf: de recorder kan de focus krijgen) of er een tekstveld de focus heeft: `editable`, `notEditable` of `unknown`.
- Alleen bij `notEditable` (geen focus, of een knop/lijst/venster…) plakt Yo Max niet: de tekst gaat op het klembord en `YoMaxCopyPanelController` toont een Tarmax-kaart onderaan, net boven de recorder, met Copy-knop (verdwijnt na 15 s, blijft zolang de muis erop staat). Bij `unknown` (vaak browsers/Electron) wordt gewoon geplakt.
- Inhaakpunt: `TranscriptionDelivery.paste`. Uitzetten: Settings → "Show Copy Card Without Text Field" (`YoMaxDefaults.copyPanelKey`).
- **Sinds 2026-11-07 standaard UIT: Yo Max plakt altijd, zoals VoiceInk.** Reden: Electron-apps (Claude, Slack, Notion, VS Code) antwoorden "niets heeft focus" terwijl de cursor in een tekstveld staat, en dat werd gelezen als "geen tekstveld". Nu telt "niets heeft focus" als `unknown` (plakken), en de lijst "nooit tekst" bevat alleen nog echte bedieningselementen (knoppen, vinkjes, menu's, links…), geen tabellen/cellen/scrollgebieden/statische tekst. Aanzetten kan nog in Settings.

### Woordenboek vanuit de geschiedenis (2026-11-07, schets 2A + 2C)
- Code: `VoiceInk/App/YoMax/YoMaxHistoryDictionary.swift`, ingehaakt in `TranscriptionDetailView.swift` (alleen het hoofdvenster, niet het snelle geschiedenispaneel).
- **Rechtsklik op een woord** in een dictaat → "Add … to Dictionary…" → kaart "Wat Whisper hoort" / "Juiste schrijfwijze". Zelfde schrijfwijze = alleen woordenlijst; anders = vervanging + woordenlijst. De tekst staat daarvoor in een `NSTextView` (platte tekst, geen Markdown-weergave meer in het detailscherm).
- **"Find Doubtful Words"**: vraagt de gekozen AI-provider (Groq) welke namen/vaktermen fout gehoord zijn, onderstreept ze oranje en toont keuzepillen → "Add". Alleen op verzoek (geen automatische AI-oproep per dictaat).
- VoiceInk heeft zelf al **Auto-Learn** (leert uit verbeteringen na het plakken, staat standaard aan). De AI-beoordelaar daarvan (`AutoLearnAIReviewer.instructions`) is Engelstalig opgesteld: nakijken in fase 4.

### Opdrachtmodus (2026-11-07, schets 3C)
- Code: `VoiceInk/App/YoMax/YoMaxCommandMode.swift`. Inhaakpunten: `TranscriptionPipeline.swift` (in het blok van de AI-opschoning) en `TranscriptionDelivery.swift` (`Request.yoMaxCommandPreview`).
- Werkt als: AI-opschoning staat aan, er is **tekst geselecteerd** in de app vooraan en het dictaat is **≤ 40 woorden** → Yo Max voert het dictaat uit als opdracht op de selectie (eigen prompt, niet "Nederlands"). Langere dictaten over een selectie worden gewoon geplakt.
- Resultaat in een **donkere kaart** boven de recorder: Cancel / Copy / **Replace** (plakt over de selectie). Het paneel activeert Yo Max niet, zodat de selectie blijft staan. Daarom kan **Enter niet**: dat zou naar de app vooraan gaan.
- Mislukt de AI-oproep, dan wordt er niets geplakt (melding), zodat de selectie nooit overschreven wordt door het ingesproken commando.
- Nog niet gebouwd: de oranje golf met "Opdracht" in de recorder tijdens het opnemen (de selectie wordt pas na de opname gelezen).
- Uitzetten: Settings → "Command Mode on Selected Text" (`YoMaxCommandMode.enabledKey`).

### Auto-Learn in Yo Max-stijl (2026-11-07, schets 4B)
- `AutoLearnSuggestionContent.swift`: donkere brand-dark kaart (radius 20) boven de recorder, oud woord doorstreept → nieuw woord op lime, knoppen No / Remember, lime timerbalk. Geen glas/materiaal meer.
- `AutoLearnAIReviewer.instructions`: niet meer "English only", ook Nederlandse (Vlaamse) paren. Wordt alleen gebruikt als je in Dictionary → Auto-Learn een AI-beoordelaar kiest (standaard: lokaal).

### Tarmax-stijl (fase 5)
- Bron: `~/GIT/tarmax/DESIGN_SYSTEMS.md` en `src/ui/theme/tokens.css`. Kleuren staan als palet in `AppTheme.Brand` (`DesignSystem/Theme/AppTheme.swift`); de rest van de app gebruikt alleen de betekenissen.
- Accent: ink `#0B1F0D` in licht (zoals de hoofdknop van Tarmax), lime `#86F46D` in donker. Zijbalk: brand-dark tegels met lime iconen, gekozen rij = lime pil met ink-tekst.
- Mini-recorder: brand-dark `#212520` met een lime golfvorm (11 ronde streepjes, symmetrisch, rustiger). De notch-recorder blijft zwart (gaat op in de notch).
- **Recorder-motion "C · Lijn" (2026-11-07, schets `design/schetsen/recorder-motion.html`):** rust = één dunne lime lijn; spreken = de 11 lime streepjes op het echte microfoonniveau; uitschrijven/opschonen = de lijn met een lime lichtpunt dat erover loopt (geen tekst "Transcribing" meer). Code: `VoiceInk/App/YoMax/YoMaxRecorderLine.swift`, ingehaakt in `RecorderStatusDisplay` (`RecorderComponents.swift`), geldt ook voor de notch-recorder. Overgangen 200 ms ease-out; met "Minder beweging" een stille lijn. Nog niet: vinkje bij klaar en een foutstaat (de recorder verdwijnt meteen na het plakken).
- **App-icoon B1 (2026-11-07, schets `design/schetsen/icoon-b.html`):** vijf even brede lime streepjes (symmetrisch) op een brand-dark tegel in het macOS-raster, met verloop, lime licht achter de golf en een fijne lichtrand (`design/icoon/yo-max-icoon.svg`). Menubalk: dezelfde vijf streepjes als template (`design/icoon/menubalk-icoon.svg`). PNG's opnieuw maken: render de SVG met de ingebouwde macOS-SVG-lezer (een klein Swift-script met `NSImage(contentsOfFile:)`; er staat geen rsvg/inkscape op de Mac) naar 16–1024 px in `AppIcon.appiconset/` en naar 750 px in `menuBarIcon.imageset/`. (Oud: Tarmax-ruit met golfvorm, zie git-geschiedenis.)
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
- **Snelste weg: `make install`** bouwt, sluit de draaiende Yo Max, zet de nieuwe in `/Applications` en opent hem (één stap, niets meer slepen).
- **Toegankelijkheid niet meer opnieuw geven:** maak één keer een gratis Apple Development-certificaat (Xcode → Settings → Accounts → Apple ID → Manage Certificates → + Apple Development). `make local` gebruikt het dan vanzelf (vaste handtekening), en macOS onthoudt de toestemming tussen builds. Zonder certificaat blijft het ad-hoc en meldt `make install` dat je de toestemming opnieuw moet geven.
- Andere targets: `make check`, `make dev` (Debug, "Yo Max Dev"), `make clean`, `make help`.

> ✅ **Sinds 2026-11-07 blijft de Toegankelijkheid-toestemming staan** op Sanders Mac: daar staat een Apple Development-certificaat ("Apple Development: sander_brebels@hotmail.com", Personal Team) plus het tussencertificaat Apple WWDR G3 in de login-sleutelhanger. Controleren: `security find-identity -v -p codesigning` moet 1 geldige identiteit tonen.
> Zonder certificaat (andere Mac, of het certificaat verloopt in nov 2027) is de app ad-hoc ondertekend en ziet macOS elke build als een nieuwe app: ga dan naar *Systeeminstellingen → Privacy en beveiliging → Toegankelijkheid*, verwijder "Yo Max" met het minteken, voeg hem opnieuw toe en zet hem aan (ook bij Invoermonitoring/Microfoon als iets niet werkt). Meldt "0 valid identities" ondanks een certificaat: dan ontbreekt meestal het G3-tussencertificaat (apple.com/certificateauthority).

## VoiceInk-updates binnenhalen

**Keuze (2026-11-07): aanpak A, kiezen en overnemen.** Automatische app-updates (Sparkle) blijven uit: die zouden VoiceInk over Yo Max installeren. Verbeteringen in de broncode van VoiceInk komen nooit vanzelf binnen. `/yo-max-start` meldt wat er nieuw is bij `upstream/main` en zegt welke commits voor Sander tellen (Whisper/lokale transcriptie, plakken, fn/sneltoetsen, crashfixes, beveiliging, nieuwe macOS-versies). Alleen wat hij kiest wordt overgenomen, meestal met `git cherry-pick <commit>`. Cloudproviders, betaalde functies en VoiceInk Pro laten we liggen.

Een volledige merge (aanpak B) blijft mogelijk voor een grote update:

```bash
git fetch upstream
git checkout yo-max
git merge upstream/main
```

- Bij conflicten in schermbestanden: neem hun versie, en draai daarna de scripts uit `tools/tarmax-stijl/` (lettertypes, kleuren, naam; zie de README daar). Die zetten de Tarmax-look en de naam Yo Max terug en zijn veilig om opnieuw te draaien.
- Let daarnaast met de hand op `project.pbxproj` (naam/bundle-id), `Info.plist` (Sparkle uit), `AppTheme.swift`, `RecordingShortcutManager.swift`, `TranscriptionDelivery.swift` en `AppDelegate.swift` (zoek op `Yo Max`).
- Daarna `make local`, testen met `testzinnen.md` en committen. Pushen met `/yo-max-stop`.

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
- [ ] Testzinnen opnieuw dicteren met prompt **v4** en het gevulde woordenboek; ook de opmaakopdrachten en de opdrachtmodus testen (zie `design/schetsen/index.html` › 1). Nog niet getest door Sander.
- [ ] `qwen/qwen3.8-27b` vs. `openai/gpt-oss-120b` vergelijken op Nederlands en snelheid.
- [ ] Snelheid en kwaliteit vergelijken: Whisper Turbo vs. Parakeet V3.
- [ ] Woordenboek (Dictionary) vullen met eigen namen en vaktermen (Tarmax, MacBook, staging, …). Kan nu ook met rechtsklik en "Find Doubtful Words" in History.

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
- [ ] Kopieerkader betrouwbaar maken zoals Wispr Flow (voorlopig uit): bij Electron-apps `AXManualAccessibility` aanzetten en opnieuw de focus vragen; "niets heeft focus" alleen geloven bij gewone Mac-apps.
- [ ] Stijl per app (formeel in Mail, los in Slack/WhatsApp) via Modes met app-triggers.
- [ ] Lokale opschoning via Ollama, zodat niets meer naar de cloud gaat.
- [ ] Koppeling met Sanders app **Tarmax**.

### Portfolio (later, als app, motion en iconen af zijn)
- [ ] Yo Max-pagina op https://work.sanderbrebels.be/own-work/, **onder Tarmax**. Geen nieuwe site: een projectpagina via de bestaande generator in `~/Library/CloudStorage/Dropbox/AI Brain in the Cloud/Showcase Portfolio 2026/Claude Folder/KBC Showcase (output)/03_website_v3_revolut/_build/` (`content.py`, `pages.py`; Tarmax-casestudy op `/work/tarmac/` als voorbeeld). Vormgeving = die van het portfolio, Yo Max in de Tarmax-branding als inhoud. Doelgroep: recruiters/design leads; tonen: prototypes en keuzes, design system, taalkwaliteit, microinteracties; niet te veel tekst, geen SaaS-landing. Alleen de GitHub-link als feit (VoiceInk-vermelding: nog beslissen, aangeraden). Werken in een eigen sessie in die map (eigen CLAUDE.md en deploy.sh); niets online zonder Sanders go. Zie ook `PRODUCT.md`.

### Motion en iconen
- [x] Inspiratie en storyboard recorder (`design/schetsen/recorder-motion.html`): Sander koos **C · Lijn**, gebouwd.
- [x] App- en menubalkicoon: Sander koos **B1 · Vijf** (`design/schetsen/icoon-b.html`), gebouwd.
- [ ] Recorder: vinkje bij "klaar" en een rode foutstaat (de recorder moet daarvoor even blijven staan na het plakken).
- [ ] Menubalk: opnamestip tijdens het opnemen (staat in de schets, niet gebouwd).
- [ ] Optioneel: Icon Composer-versie (lagen) van icoon B1 voor macOS Tahoe.

### Delen
- [x] Branch `yo-max` naar de fork pushen (met `/yo-max-stop`).
- [ ] De vriend de link geven (https://github.com/sanderbrebels/yo-max).
