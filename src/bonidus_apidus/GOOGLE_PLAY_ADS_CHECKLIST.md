# Google Play & Advertenties — checklist

Status per 2026-10-16. "Gedaan" = al afgerond in deze repo/sessie. De rest moet jij zelf doen (Play Console-account, keuzes die alleen jij kan maken, of code die nog niet gevraagd is).

## 1. Google Play — technisch (gedaan)

- [x] `INTERNET`-permissie in `AndroidManifest.xml` (zonder deze faalt elke netwerkcall in de release-build).
- [x] Release-signing: `android/app/upload-keystore.jks` + `android/key.properties`, gekoppeld in `build.gradle.kts`. Beide staan in `.gitignore`.
- [x] Minify + resource shrinking aan voor de release-build (`isMinifyEnabled`, `isShrinkResources`, `proguard-rules.pro`).
- [x] Schermoriëntatie vastgezet op portrait (manifest + `SystemChrome`).
- [x] `flutter build appbundle --release` getest — bouwt en signt succesvol.
- [x] Signing geverifieerd met `apksigner verify` (v2-scheme, certificaat matcht de keystore).

## 2. Google Play — nog te doen door jou

### Account & basis
- [ ] **Backup van `android/app/upload-keystore.jks` + het wachtwoord in `android/key.properties`** ergens veilig buiten git (password manager + evt. cloud-backup). Zonder deze kun je de app nooit meer updaten onder dezelfde listing.
- [ ] Google Play Console-developer-account aanmaken (eenmalig $25).
- [ ] Nieuwe app aanmaken in Play Console, package `com.batelaan.bonidus_apidus`.

### Verplichte closed/internal testing periode
- [ ] Voor **nieuwe** developer-accounts eist Google een **closed test met minimaal 20 testers, 14 aaneengesloten dagen**, voordat je naar productie mag. Zet dit zo vroeg mogelijk op als je dit nog niet eerder hebt gedaan — dit is de langste stap in de hele flow.
- [ ] Testers toevoegen via e-mailadres of een opt-in-link in de testing-track.

### Store listing
- [ ] App-titel, korte beschrijving (max 80 tekens), volledige beschrijving.
- [ ] Screenshots (minimaal 2, telefoonformaat).
- [ ] Feature graphic (1024×500 px).
- [ ] Hi-res app-icoon voor de store (512×512 px, los van het in-app icoon).
- [ ] App-categorie kiezen (bv. Tools of Lifestyle).

### Verplichte formulieren
- [ ] **Content rating-questionnaire** invullen.
- [ ] **Data safety-formulier**: minimaal vermelden:
  - Camera-permissie (voor het scannen van barcodes/QR-codes) — data blijft lokaal, wordt niet verzameld/verzonden.
  - Domeinnaam die naar `img.logo.dev` gestuurd wordt om een logo op te halen (geen persoonsgegevens, puur een merknaam/domein).
  - Zie ook sectie 4 hieronder als je advertenties toevoegt — dat verandert dit formulier.
- [ ] **Privacybeleid-URL** — verplicht vanwege de camera-permissie. Moet ergens publiek gehost worden (bv. GitHub Pages, Google Sites). Moet minimaal noemen: welke data lokaal wordt opgeslagen, dat domeinnamen naar logo.dev gaan, en een contactmogelijkheid.
- [ ] Doelgroep & inhoud-instellingen (leeftijdscategorie).
- [ ] Prijs & distributie: gratis, landen selecteren.

### Build uploaden
- [ ] `flutter build appbundle --release` opnieuw draaien op de uiteindelijke versie, `.aab` uploaden naar de testing-track.
- [ ] `version` in `pubspec.yaml` ophogen bij elke nieuwe upload — **het buildnummer (na de `+`) moet ook omhoog**, niet alleen het versienummer. Dat is tot nu toe steeds blijven staan op `+1`.

## 3. Advertenties — keuzes die je eerst moet maken

- [ ] **Welk ad-netwerk?** Standaardkeuze voor Flutter/Android is **Google AdMob** (pakket: `google_mobile_ads`). Geen code hiervoor is nog geschreven — zeg het als je dit wil laten bouwen.
- [ ] **Welk type advertentie?** Banner (permanent, minder opbrengst, minder storend), interstitial (volledig scherm tussen acties), of rewarded (gebruiker kiest ervoor te kijken). Voor een kaarten-app past een banner op het home-scherm het minst storend.
- [ ] **AdMob-account aanmaken** op https://admob.google.com, app registreren, ad unit(s) aanmaken.

## 4. Advertenties — wat dit verandert aan je Play Store-aanvraag

Zodra er advertenties in de app komen:

- [ ] Play Console-vraag **"Bevat je app advertenties?"** → Ja.
- [ ] **Data safety-formulier** moet uitgebreid worden: AdMob verzamelt het **Advertising ID** en deelt data met derden (Google). Dit moet je expliciet aangeven.
- [ ] **Privacybeleid** moet vermelden dat er advertenties getoond worden, via welke partij (Google AdMob), en welke data daarvoor gebruikt wordt.
- [ ] **UMP (User Messaging Platform) / toestemmingsformulier verplicht** voor gebruikers in de EU/EER (dus ook Nederland) — je moet expliciet toestemming vragen voor gepersonaliseerde advertenties voordat je ze toont. Google biedt hiervoor een kant-en-klare SDK (`google_mobile_ads` bevat UMP-support).
- [ ] **AndroidManifest.xml** moet een AdMob App ID bevatten (`<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" .../>`) — zonder deze crasht de app bij het laden van een advertentie.
- [ ] Tijdens ontwikkeling: gebruik **AdMob test ad unit ID's** (niet de echte), anders riskeer je een geblokkeerd account wegens ongeldige kliks op je eigen advertenties.
- [ ] Beleidsregels: advertenties mogen de UI niet overlappen/blokkeren, geen per ongeluk-kliks veroorzaken, en geen interstitial direct bij het openen van de app tonen.

## 5. Volgorde-advies

1. Backup keystore (nu, voor je iets anders doet).
2. Beslis of er advertenties komen vóór je het Data safety-formulier invult — dat formulier moet namelijk kloppen met de uiteindelijke build die je uploadt.
3. Als er advertenties komen: eerst de `google_mobile_ads`-integratie + UMP-consent bouwen en testen, dán pas de closed test starten (anders moet je de 14-dagen-testperiode na een functionele wijziging deels herhalen).
4. Closed test (20 testers, 14 dagen) starten.
5. Store listing, content rating, data safety, privacybeleid invullen.
6. Productie-aanvraag indienen.
