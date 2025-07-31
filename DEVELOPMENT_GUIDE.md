# HabitPet iOS - Entwicklungs-Leitfaden

## 🚀 Schnellstart

### 1. Projekt-Setup
```bash
# Repository klonen (falls vorhanden)
git clone <repository-url>
cd HabitPet_iOS

# Xcode-Projekt erstellen
./setup-xcode-project.sh

# Projekt in Xcode öffnen
open HabitPet.xcodeproj
```

### 2. Firebase-Konfiguration

#### Firebase-Projekt erstellen
1. [Firebase Console](https://console.firebase.google.com/) besuchen
2. Neues Projekt erstellen: `habitpet-ios`
3. iOS-App hinzufügen:
   - Bundle ID: `com.yourcompany.habitpet` (anpassen nach Bedarf)
   - App-Name: `HabitPet`

#### Firebase-Services aktivieren
```bash
# Authentication
- E-Mail/Passwort-Anbieter aktivieren
- Benutzerregistrierung erlauben

# Firestore Database
- Datenbank im Testmodus erstellen
- Sicherheitsregeln konfigurieren

# Cloud Storage
- Storage Bucket erstellen
- Regeln für Bild-Uploads konfigurieren

# Cloud Functions
- Funktionen für Battle-Logik deployen

# Cloud Messaging (FCM)
- Push-Notifications konfigurieren
- APNs-Zertifikat hochladen
```

#### GoogleService-Info.plist
1. Datei aus Firebase Console herunterladen
2. In Xcode zu `/HabitPet/Resources/` hinzufügen
3. Zum Build Target hinzufügen

### 3. Dependencies installieren

In Xcode über Package Manager:
```
File → Add Package Dependencies

Firebase iOS SDK:
https://github.com/firebase/firebase-ios-sdk.git

Lottie (Animationen):
https://github.com/airbnb/lottie-ios.git

SDWebImageSwiftUI (Image Caching):
https://github.com/SDWebImage/SDWebImageSwiftUI.git

SwiftKeychainWrapper (Sicherheit):
https://github.com/jrendel/SwiftKeychainWrapper.git
```

## 🏗️ Architektur-Details

### MVVM-Pattern
```
View ↔ ViewModel ↔ Model/Service
```

**Beispiel:**
- `DashboardView` (UI)
- `DashboardViewModel` (Business Logic)
- `UserManager` (Service Layer)

### Datenfluss
```
Firebase ← Firestore ← Service Layer ← ViewModel ← View
```

### Ordner-Struktur
```
HabitPet/
├── App/                    # App-Konfiguration
│   └── HabitPetApp.swift  # Main App Entry Point
├── Models/                 # Datenmodelle
│   ├── User.swift
│   ├── Pet.swift
│   ├── Habit.swift
│   ├── Battle.swift
│   └── Competition.swift
├── Views/                  # SwiftUI Views
│   ├── Auth/              # Authentifizierung
│   ├── Dashboard/         # Haupt-Dashboard
│   ├── Pets/              # Pet-Management
│   ├── Competition/       # Leaderboards & Achievements
│   ├── Battles/           # Kampf-System
│   ├── Habits/            # Gewohnheiten
│   └── Settings/          # Einstellungen
├── ViewModels/            # Business Logic
│   ├── DashboardViewModel.swift
│   ├── PetSelectionViewModel.swift
│   └── [weitere ViewModels]
├── Services/              # Backend-Integration
│   ├── AuthenticationManager.swift
│   ├── UserManager.swift
│   └── NotificationManager.swift
├── Utilities/             # Hilfsfunktionen
│   └── Constants.swift
├── Extensions/            # Swift Extensions
│   └── Date+Extensions.swift
└── Resources/             # Assets & Konfiguration
    ├── GoogleService-Info.plist
    ├── Info.plist
    └── Assets.xcassets
```

## 🔄 Development Workflow

### 1. Feature-Entwicklung
```bash
# Feature Branch erstellen
git checkout -b feature/new-pet-evolution

# Entwicklung
# 1. Model erweitern (falls nötig)
# 2. Service-Layer implementieren
# 3. ViewModel erstellen/erweitern
# 4. UI-Components entwickeln
# 5. Tests schreiben

# Commit und Push
git add .
git commit -m "Add pet evolution system"
git push origin feature/new-pet-evolution
```

### 2. Code-Konventionen

#### Swift Code Style
```swift
// MARK: - Properties
@Published var pets: [Pet] = []
private let db = Firestore.firestore()

// MARK: - Lifecycle
func loadPets() {
    // Implementation
}

// MARK: - Actions
private func createPet() {
    // Implementation
}
```

#### SwiftUI Komponenten
```swift
struct PetCard: View {
    let pet: Pet
    
    var body: some View {
        VStack(spacing: 12) {
            // Content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}
```

### 3. Firebase-Integration

#### Firestore-Queries
```swift
// Effiziente Queries verwenden
db.collection("users").document(userId)
  .collection("pets")
  .whereField("isActive", isEqualTo: true)
  .limit(to: 10)
  .addSnapshotListener { snapshot, error in
      // Handle updates
  }
```

#### Error Handling
```swift
do {
    try await createPet(template: template, name: name)
} catch {
    print("Error creating pet: \(error.localizedDescription)")
    // User-friendly error handling
}
```

## 🧪 Testing

### Unit Tests
```swift
@testable import HabitPet
import XCTest

class PetTests: XCTestCase {
    func testPetEvolution() {
        let pet = Pet(level: 25)
        XCTAssertEqual(pet.evolution, .legendary)
    }
}
```

### UI Tests
```swift
class HabitPetUITests: XCTestCase {
    func testPetSelection() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Pet auswählen"].tap()
        XCTAssertTrue(app.staticTexts["Pet benennen"].exists)
    }
}
```

### Test-Ausführung
```bash
# Unit Tests
xcodebuild test -scheme HabitPet -destination 'platform=iOS Simulator,name=iPhone 15'

# UI Tests
xcodebuild test -scheme HabitPetUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 🚀 Deployment

### TestFlight
```bash
# Archive erstellen
xcodebuild archive -scheme HabitPet -archivePath HabitPet.xcarchive

# Export für App Store
xcodebuild -exportArchive -archivePath HabitPet.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist
```

### App Store Connect
1. App Store Connect öffnen
2. App-Informationen konfigurieren
3. Screenshots und App-Beschreibung hinzufügen
4. Zur Überprüfung einreichen

## 🔧 Debugging & Troubleshooting

### Firebase-Debugging
```swift
// Firestore-Debugging aktivieren
Firestore.enableLogging(true)

// Authentication-Status prüfen
print("Auth state: \(Auth.auth().currentUser?.uid ?? "not authenticated")")
```

### Performance-Monitoring
```swift
// Performance Trace
let trace = Performance.startTrace(name: "pet_loading")
// ... operation
trace?.stop()
```

### Common Issues

#### 1. Firebase-Konfiguration
**Problem:** App startet nicht / Firebase-Fehler
**Lösung:**
- `GoogleService-Info.plist` korrekt hinzugefügt?
- Bundle ID stimmt überein?
- Firebase-Services aktiviert?

#### 2. Simulator vs. Device
**Problem:** Push Notifications funktionieren nicht
**Lösung:**
- Push Notifications nur auf echten Geräten
- APNs-Zertifikat korrekt konfiguriert?
- Berechtigung erteilt?

#### 3. SwiftUI-Performance
**Problem:** Langsame UI-Updates
**Lösung:**
- `@StateObject` vs. `@ObservedObject` korrekt verwenden
- Unnötige View-Updates vermeiden
- Lazy Loading implementieren

## 📊 Monitoring & Analytics

### Firebase Analytics
```swift
// Custom Events
Analytics.logEvent("pet_created", parameters: [
    "pet_type": petType,
    "user_level": userLevel
])

// User Properties
Analytics.setUserProperty(userLevel.description, forName: "user_level")
```

### Crash Reporting
```swift
// Non-fatal Errors
Crashlytics.crashlytics().record(error: error)

// Custom Keys
Crashlytics.crashlytics().setCustomValue(userId, forKey: "user_id")
```

## 🔒 Sicherheit & Datenschutz

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /pets/{petId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Sensitive Data Handling
```swift
// Niemals hardcoded secrets
// Keychain für lokale Speicherung verwenden
KeychainWrapper.standard.set(token, forKey: "user_token")

// Input-Validierung
func validateUsername(_ username: String) -> Bool {
    return username.count >= 3 && username.count <= 20
}
```

## 📈 Performance-Best-Practices

### Memory Management
```swift
// Weak references in closures
someService.loadData { [weak self] result in
    self?.handleResult(result)
}

// Remove listeners
deinit {
    listeners.forEach { $0.remove() }
}
```

### Efficient UI Updates
```swift
// Batch UI updates
DispatchQueue.main.async {
    // Multiple UI updates together
}

// Lazy loading
LazyVGrid(columns: columns) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

## 🛠️ Erweiterte Features

### Core Data Integration (Offline Support)
```swift
// Core Data für lokale Persistierung
import CoreData

class PersistenceController {
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HabitPet")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
}
```

### HealthKit Integration
```swift
import HealthKit

class HealthManager {
    let healthStore = HKHealthStore()
    
    func requestPermission() {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .sleepAnalysis)!
        ]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { _, _ in
            // Handle result
        }
    }
}
```

### Widgets (iOS 14+)
```swift
import WidgetKit
import SwiftUI

struct HabitPetWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "HabitPetWidget", provider: Provider()) { entry in
            HabitPetWidgetView(entry: entry)
        }
        .configurationDisplayName("HabitPet")
        .description("Zeigt dein aktives Pet und den aktuellen Streak.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

## 📝 Zusätzliche Ressourcen

### Dokumentation
- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### Tools
- **Xcode Instruments**: Performance-Profiling
- **Firebase Console**: Backend-Management
- **TestFlight**: Beta-Testing
- **App Store Connect**: Release-Management

### Community
- [Swift.org](https://swift.org/)
- [SwiftUI Community](https://www.reddit.com/r/SwiftUI/)
- [Firebase Community](https://firebase.google.com/community)

---

**Happy Coding! 🐾** 

Bei Fragen oder Problemen, siehe die README.md oder erstelle ein GitHub Issue.