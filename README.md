# Synsanalyse

En interaktiv kalkulator for å simulere syn etter refraktiv kirurgi (LASIK, PRK, SMILE). Tilgjengelig som webapplikasjon (Docker) og native iOS-app.

## Funksjoner
- Juster startverdi (R0), linsekorreksjon og akkommodasjon per øye
- Monovision/Presbyond-modus med automatisk beregning av nærøye
- Resultattabell med fargekoding (grønn < 0.5 D, rød ≥ 0.5 D)
- Visuell graf med rest-defokus og DOF-sone
- Persistering av innstillinger mellom sesjoner

---

## Web (Docker)

### Hurtigstart
```bash
docker compose up -d --build
```

Åpne: http://localhost:8080

### Stopp
```bash
docker compose down
```

### Start igjen
```bash
docker compose up -d
```

### Opprydding
```bash
docker compose down --rmi local --volumes --remove-orphans
```

### Alternativ uten Docker Compose
```bash
docker build -t synstest .
docker run -d -p 8080:80 --name synstest-app synstest
```

### Docker-image detaljer
- Base-image: `nginx:alpine` (~23MB)
- Eksponert port: 80
- Inneholder kun statisk HTML med JavaScript

---

## iOS-app

Native SwiftUI-app i `ios/`-katalogen. Krever Xcode 16+ og iOS 18+.

### Åpne i Xcode
```bash
open ios/Synstest.xcodeproj
```

### Bygg fra kommandolinje
```bash
cd ios
xcodebuild -project Synstest.xcodeproj -scheme Synstest \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -configuration Debug build
```

### Kjør på simulator
```bash
xcrun simctl boot "iPhone 17 Pro"
open -a Simulator
xcrun simctl install booted Build/Products/Debug-iphonesimulator/Synstest.app
xcrun simctl launch booted com.synstest.app
```

### Prosjektstruktur
```
ios/
├── Synstest.xcodeproj/
└── Synstest/
    ├── SynstestApp.swift          # App entry point
    ├── Models/
    │   └── EyeModel.swift         # Domenemodell og optikk-beregninger
    ├── ViewModels/
    │   └── SynsViewModel.swift    # Tilstand, monovision-logikk, persistering
    └── Views/
        ├── ContentView.swift      # Hovedvisning
        ├── EyeCardView.swift      # Øye-kort med slidere
        ├── MonovisionToggleView.swift
        ├── ResultsTableView.swift
        └── DefocusChartView.swift # Swift Charts-grafer
```

### Teknologi
- **SwiftUI** med `@Observable` (iOS 18+)
- **Swift Charts** for rest-defokus-grafer
- **UserDefaults** for persistering av innstillinger

### Kjør på fysisk iPhone

For å kjøre appen på en fysisk iPhone direkte fra Xcode (sideloading):

1. **Apple ID**: Du trenger en Apple ID (gratis). Med gratis konto kan du installere på inntil 3 enheter, og appen utløper etter 7 dager.
2. **Koble til iPhone**: Koble telefonen til Mac via USB (eller bruk trådløs debugging etter første tilkobling).
3. **Konfigurer signing i Xcode**:
   - Åpne `ios/Synstest.xcodeproj` i Xcode
   - Velg prosjektet i navigatoren → **Signing & Capabilities**
   - Huk av **Automatically manage signing**
   - Velg ditt **Team** (din Apple ID)
   - Endre **Bundle Identifier** til noe unikt, f.eks. `com.dittnavn.synsanalyse`
4. **Stol på utvikler**: Første gang du installerer, gå til **Innstillinger → Generelt → VPN og enhetsadministrasjon** på iPhonen og godkjenn utviklersertifikatet.
5. **Bygg og kjør**: Velg din iPhone som destinasjon i Xcode og trykk ▶️ (Run).

> **Merk**: Med gratis Apple ID må du re-signere og installere på nytt hver 7. dag. Med betalt Apple Developer-konto ($99/år) varer sertifikatet i 1 år.

### Distribuer via App Store

For å publisere appen på App Store:

#### Forutsetninger
- **Apple Developer Program**: Krever medlemskap ($99/år) — [developer.apple.com/programs](https://developer.apple.com/programs/)
- **App Store Connect-konto**: Følger med Developer Program
- **App-ikon**: 1024×1024 px ikon i Assets-katalogen
- **Screenshots**: Minst én screenshot per påkrevd enhetsstørrelse

#### Steg for steg

1. **Konfigurer prosjektet**:
   - Sett riktig **Bundle Identifier** (f.eks. `com.firmanavn.synsanalyse`)
   - Sett **Version** og **Build** nummer
   - Velg ditt Developer Program-team under **Signing & Capabilities**
   - Sett **Deployment Target** til ønsket minimum iOS-versjon

2. **Opprett app i App Store Connect**:
   - Logg inn på [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - **Mine apper → + Ny app**
   - Fyll ut navn, Bundle ID, SKU og språk

3. **Arkiver appen**:
   ```bash
   # I Xcode: Product → Archive (med "Any iOS Device" som destinasjon)
   # Eller fra kommandolinje:
   cd ios
   xcodebuild -project Synstest.xcodeproj -scheme Synstest \
     -destination 'generic/platform=iOS' \
     -configuration Release archive \
     -archivePath build/Synstest.xcarchive
   ```

4. **Last opp til App Store Connect**:
   - Fra Xcode: **Window → Organizer** → velg arkivet → **Distribute App**
   - Velg **App Store Connect** → **Upload**
   - Eller bruk kommandolinje med `xcodebuild -exportArchive`

5. **Fyll ut metadata i App Store Connect**:
   - Beskrivelse, nøkkelord, kategori (Medisin / Helse)
   - Screenshots og forhåndsvisning
   - Aldersgrense og personvernerklæring
   - Pris (gratis eller betalt)

6. **Send til review**: Trykk **Send til Apple-gjennomgang**. Gjennomgangen tar vanligvis 1–3 dager.

> **Tips**: Bruk TestFlight (tilgjengelig via App Store Connect) for å distribuere beta-versjoner til testere før du sender til App Store.
