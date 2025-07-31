# 🚀 Habit Royale - Xcode Setup Anleitung

## Schritt 1: Neues Xcode Projekt erstellen

1. **Xcode öffnen** → "Create a new Xcode project"
2. **iOS** → **App** auswählen
3. **Projekt-Details eingeben:**
   ```
   Product Name: HabitRoyale
   Team: [Dein Team]
   Organization Identifier: com.yourcompany.habitroyale
   Bundle Identifier: com.yourcompany.habitroyale
   Language: Swift
   Interface: SwiftUI
   Use Core Data: ❌ NEIN
   Include Tests: ✅ JA
   ```

4. **Speicherort:** 
   `/Users/jessemayerhoff/Documents/Projekte/HabitPet_iOS/HabitRoyaleXcode`

## Schritt 2: Nach Projekt-Erstellung

### A) Bestehende Dateien löschen
- `ContentView.swift` → löschen
- `HabitRoyaleApp.swift` → löschen (wird ersetzt)

### B) Unsere Dateien kopieren
Kopiere alle Dateien aus `/HabitPet/HabitPet/` in das neue Xcode Projekt:

```
HabitRoyaleXcode/
├── HabitRoyale/
│   ├── App/
│   │   └── HabitRoyaleApp.swift
│   ├── Models/
│   ├── Views/
│   ├── ViewModels/
│   ├── Services/
│   ├── Utilities/
│   └── Extensions/
```

## Schritt 3: Package Dependencies hinzufügen

1. **Xcode** → **File** → **Add Package Dependencies**
2. **URLs hinzufügen:**

```
Firebase SDK:
https://github.com/firebase/firebase-ios-sdk.git

Lottie:
https://github.com/airbnb/lottie-ios.git

SDWebImage:
https://github.com/SDWebImage/SDWebImageSwiftUI.git

SwiftKeychainWrapper:
https://github.com/jrendel/SwiftKeychainWrapper.git
```

3. **Packages zum Target hinzufügen:**
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseFirestoreSwift
   - FirebaseStorage
   - FirebaseFunctions
   - FirebaseMessaging
   - FirebaseAnalytics
   - Lottie
   - SDWebImageSwiftUI
   - SwiftKeychainWrapper

## Schritt 4: Project Settings

1. **Target Settings** → **General**:
   - **Deployment Target:** iOS 16.0
   - **Bundle Identifier:** com.yourcompany.habitroyale

2. **Info.plist** Permissions hinzufügen:
```xml
<key>NSCameraUsageDescription</key>
<string>Habit Royale benötigt Kamera-Zugriff für Pet-Fotos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Habit Royale benötigt Foto-Zugriff für Pet-Bilder</string>
```

## Schritt 5: Firebase Setup

1. **Firebase Console:** https://console.firebase.google.com
2. **Neues Projekt erstellen:** "Habit Royale"
3. **iOS App hinzufügen:** Bundle ID `com.yourcompany.habitroyale`
4. **GoogleService-Info.plist** herunterladen → in Xcode Root hinzufügen

## Schritt 6: Erste Compilation

1. **Product** → **Clean Build Folder** (⇧⌘K)
2. **Product** → **Build** (⌘B)
3. Bei Fehlern: Siehe Troubleshooting unten

---

## 🔧 Troubleshooting

### Häufige Fehler:

#### "Cannot find type 'User' in scope"
→ Alle Model-Dateien korrekt hinzugefügt?

#### "No such module 'FirebaseAuth'"
→ Package Dependencies korrekt hinzugefügt?

#### Build-Fehler bei SwiftUI
→ iOS Deployment Target auf 16.0 gesetzt?

---

## ✅ Erfolg!

Wenn das Projekt erfolgreich kompiliert:
1. **Simulator starten** → iPhone 15 Pro
2. **Product** → **Run** (⌘R)
3. App sollte mit Login-Screen starten

Bei Problemen: Überprüfe Console-Logs für detaillierte Fehlermeldungen.