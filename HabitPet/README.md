# HabitPet iOS App

Eine professionelle iOS-App für gamifiziertes Habit-Tracking mit virtuellen Haustieren, entwickelt mit SwiftUI und Firebase.

## 🎮 Features

### Kernfunktionen
- **Multi-Pet-System**: Sammle bis zu 3 Pets mit progressiver Freischaltung
- **Evolution-System**: 6-stufige Pet-Entwicklung (Ei → Baby → Jung → Erwachsen → Elite → Legendär)
- **Habit-Tracking**: 3 Standard-Gewohnheiten + unbegrenzte Custom Habits
- **Battle-System**: PvP-Kämpfe mit Lifestyle-Fragen
- **Competition**: Leaderboards, Achievements, Fortschrittsverfolgung
- **Social Features**: Freunde herausfordern, gemeinsame Fortschritte

### Technische Highlights
- **SwiftUI**: Native iOS-UI mit modernem Design
- **Firebase Backend**: Realtime Database, Authentication, Cloud Functions
- **Offline-First**: Lokale Datenpersistenz mit Cloud-Sync
- **Push Notifications**: Battle-Herausforderungen, Habit-Erinnerungen
- **DSGVO-konform**: Datenschutz und Sicherheit nach EU-Standards

## 🏗️ Architektur

### Projekt-Struktur
```
HabitPet/
├── App/                    # App-Konfiguration und Entry Point
├── Models/                 # Datenmodelle (User, Pet, Habit, Battle, etc.)
├── Views/                  # SwiftUI Views nach Features organisiert
│   ├── Auth/              # Authentifizierung
│   ├── Dashboard/         # Haupt-Dashboard
│   ├── Pets/              # Pet-Management
│   ├── Competition/       # Leaderboards & Achievements
│   ├── Battles/           # Kampf-System
│   ├── Habits/            # Gewohnheiten-Tracking
│   └── Settings/          # Einstellungen
├── ViewModels/            # Business Logic Layer
├── Services/              # Firebase Services, Authentication
├── Utilities/             # Hilfsfunktionen, Konstanten
├── Extensions/            # Swift Extensions
└── Resources/             # Assets, Konfiguration
```

### Firebase-Integration
- **Authentication**: Sichere Benutzeranmeldung
- **Firestore**: Realtime-Datenbank für alle App-Daten
- **Cloud Functions**: Server-seitige Logik für Battles, Achievements
- **Cloud Storage**: Pet-Bilder und Assets
- **Cloud Messaging**: Push-Notifications

## 🚀 Setup & Installation

### Voraussetzungen
- Xcode 15.0+
- iOS 16.0+
- Firebase-Projekt mit iOS-App

### Installation
1. **Repository klonen**
   ```bash
   git clone <repository-url>
   cd HabitPet_iOS
   ```

2. **Firebase konfigurieren**
   - Firebase-Projekt erstellen
   - iOS-App hinzufügen mit Bundle ID: `com.yourcompany.habitpet`
   - `GoogleService-Info.plist` herunterladen und in `/HabitPet/Resources/` platzieren
   - Firebase-Features aktivieren: Authentication, Firestore, Storage, Functions

3. **Dependencies installieren**
   ```bash
   # Swift Package Manager wird automatisch von Xcode verwendet
   # Alle Dependencies sind in Package.swift definiert
   ```

4. **Xcode-Projekt öffnen**
   ```bash
   open HabitPet.xcodeproj
   ```

### Firebase-Setup
1. **Firestore-Regeln** (vereinfacht für Development):
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
         match /{document=**} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
         }
       }
       match /petTemplates/{document} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && 
           get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['PET_CREATOR', 'ADMIN'];
       }
       match /battles/{document} {
         allow read, write: if request.auth != null && 
           (resource.data.challengerId == request.auth.uid || 
            resource.data.defenderId == request.auth.uid);
       }
     }
   }
   ```

2. **Cloud Functions** deployen:
   ```bash
   cd firebase-functions
   npm install
   firebase deploy --only functions
   ```

## 📱 App-Flow

### 1. Authentifizierung
- Registrierung mit E-Mail/Passwort und Benutzername
- Login-Validierung
- Passwort-Reset-Funktionalität

### 2. Pet-Auswahl (Neue Benutzer)
- 3 zufällige Common-Pets zur Auswahl
- Pet-Benennung
- Automatische Aktivierung als erstes Pet

### 3. Haupt-Navigation (5 Tabs)
- **Dashboard**: Übersicht, Quick Actions
- **Pets**: Pet-Sammlung, Evolution-Management
- **Competition**: Leaderboards, Progress, Achievements
- **Battles**: PvP-Kämpfe, Battle-History
- **Settings**: Ziele, Custom Habits, Account

## 🎯 Gamification-System

### Pet-System
- **3 Slots**: Level 1, 5, 10 Freischaltung
- **Evolution**: 6 Stufen basierend auf Pet-Level
- **Stats**: Health, Attack, Defense beeinflusst durch Habits
- **Kategorien**: Common, Rare, Epic, Legendary

### Habit-Tracking
- **Standard-Habits**: Schlaf, Sport, Bildschirmzeit
- **Custom Habits**: Individuelle Gewohnheiten mit Pet-Effekten
- **Streak-System**: Tägliche Konsequenz für Pet-Gesundheit
- **Belohnungen**: XP und Pet-Stats-Verbesserungen

### Battle-System
- **Lifestyle-Fragen**: 5 Kategorien (Gesundheit, Beziehungen, Spiritualität, Produktivität, Gewohnheiten)
- **Selbstbewertung**: 1-10 Skala für letzten 3 Tage
- **XP-Belohnungen**: 30 XP für Sieger, 10 XP für Verlierer
- **Battle-Stats**: Siegesrate, Durchschnittswerte, Serien

## 🔒 Sicherheit & DSGVO

### Datenschutz
- Minimale Datenerhebung
- Verschlüsselte Datenübertragung
- Lokale Datenspeicherung für Offline-Nutzung
- Benutzer-kontrollierte Datenlöschung

### Sicherheitsmaßnahmen
- Firebase Authentication
- Firestore Security Rules
- Input-Validierung
- SQL-Injection-Schutz durch Firebase

## 🛠️ Development

### Code-Konventionen
- SwiftUI MVVM-Pattern
- Reactive Programming mit Combine
- Async/Await für asynchrone Operationen
- Protocol-orientierte Programmierung

### Testing
```bash
# Unit Tests
xcodebuild test -scheme HabitPet -destination 'platform=iOS Simulator,name=iPhone 15'

# UI Tests
xcodebuild test -scheme HabitPetUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Performance-Optimierung
- Lazy Loading für große Datensätze
- Image Caching mit SDWebImage
- Efficient Firestore Queries
- Memory Management

## 📈 Monitoring & Analytics

### Firebase Analytics
- Benutzertverhalten-Tracking
- Custom Events für Gamification
- Conversion-Tracking
- Crash Reporting

### Performance Monitoring
- App-Performance-Metriken
- Network-Request-Monitoring
- User Experience Tracking

## 🚢 Deployment

### App Store Connect
1. **Archive erstellen**
   ```bash
   xcodebuild archive -scheme HabitPet -archivePath HabitPet.xcarchive
   ```

2. **Upload zu App Store Connect**
   ```bash
   xcodebuild -exportArchive -archivePath HabitPet.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist
   ```

### TestFlight
- Beta-Testing mit ausgewählten Benutzern
- Crash-Report-Sammlung
- Feedback-Integration

## 🤝 Contributing

### Development Workflow
1. Feature Branch erstellen
2. Code-Änderungen implementieren
3. Tests schreiben/aktualisieren
4. Pull Request erstellen
5. Code Review
6. Merge nach Approval

### Code Quality
- SwiftLint für Code-Style
- Unit Test Coverage > 80%
- Performance-Tests für kritische Pfade

## 📄 Lizenz

Dieses Projekt ist urheberrechtlich geschützt. Alle Rechte vorbehalten.

## 📞 Support

Für technische Fragen oder Support:
- GitHub Issues für Bugs und Feature Requests
- Dokumentation im `/docs` Verzeichnis
- Entwickler-Wiki für detaillierte Anleitungen

---

**HabitPet** - Verwandle deine Gewohnheiten in ein Abenteuer! 🐾