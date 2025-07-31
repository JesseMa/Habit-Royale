# 🔥 Firebase Backend Setup - Habit Royale

## 1. Firebase Console Setup

### Projekt erstellen:
1. **Firebase Console:** https://console.firebase.google.com
2. **Neues Projekt erstellen:** "Habit Royale"
3. **Google Analytics:** ✅ Aktivieren
4. **Standort:** Europa (europe-west1)

### iOS App hinzufügen:
- **Bundle ID:** `com.yourcompany.habitroyale`
- **App-Name:** Habit Royale
- **App Store ID:** (später)

## 2. Services konfigurieren

### Authentication
```javascript
// Anmelde-Methoden aktivieren
- Email/Password: ✅
- Anonymous: ✅ (für Offline-Tests)
- Google: ✅ (optional)
```

### Firestore Database
```javascript
// Regeln (Development):
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // User's pets
      match /pets/{petId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // User's habits
      match /habitLogs/{logId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /customHabits/{habitId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /goals/{goalId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /calendar/{calendarId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /progress/{progressId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /streak/{streakId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /battleStats/{statsId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Global collections (read-only for users)
    match /petTemplates/{templateId} {
      allow read: if request.auth != null;
    }
    
    match /battleQuestions/{questionId} {
      allow read: if request.auth != null;
    }
    
    match /achievements/{achievementId} {
      allow read: if request.auth != null;
    }
    
    // Public battles
    match /battles/{battleId} {
      allow read, write: if request.auth != null;
    }
    
    // Leaderboard
    match /leaderboard/{entryId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

### Cloud Functions
```javascript
// Package.json dependencies
{
  "dependencies": {
    "firebase-admin": "^11.0.0",
    "firebase-functions": "^4.0.0"
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /petTemplates/{allPaths=**} {
      allow read: if request.auth != null;
    }
  }
}
```

## 3. Datenbank-Schema

### Collections Structure:
```
/users/{userId}
  - username: string
  - email: string
  - level: number
  - experience: number
  - activePetId: string
  - createdAt: timestamp
  - lastLoginAt: timestamp

/users/{userId}/pets/{petId}
  - templateId: string
  - name: string
  - level: number
  - experience: number
  - health: number
  - maxHealth: number
  - attack: number
  - defense: number
  - evolution: string
  - slotIndex: number
  - isActive: boolean
  - createdAt: timestamp
  - lastFed: timestamp

/users/{userId}/habitLogs/{logId}
  - habitId: string
  - habitType: string (SLEEP|EXERCISE|SCREEN_TIME|CUSTOM)
  - date: timestamp
  - value: number
  - percentage: number
  - notes: string
  - createdAt: timestamp

/users/{userId}/customHabits/{habitId}
  - name: string
  - emoji: string
  - description: string
  - targetType: string (NUMERIC|YESNO)
  - targetValue: number
  - targetUnit: string
  - effect: string (ATTACK|DEFENSE|HEALTH|EXPERIENCE)
  - intensity: string (LIGHT|MEDIUM|STRONG)
  - isActive: boolean
  - createdAt: timestamp

/petTemplates/{templateId}
  - name: string
  - type: string
  - description: string
  - category: string (COMMON|RARE|EPIC|LEGENDARY)
  - baseHealth: number
  - baseAttack: number
  - baseDefense: number
  - unlockLevel: number
  - evolutions: array
  - isVisible: boolean

/battles/{battleId}
  - challengerId: string
  - opponentId: string
  - questions: array
  - challengerAnswers: array
  - opponentAnswers: array
  - winner: string
  - status: string (PENDING|ACTIVE|COMPLETED|EXPIRED)
  - createdAt: timestamp
  - expiresAt: timestamp

/leaderboard/{entryId}
  - userId: string
  - username: string
  - score: number
  - petType: string
  - petLevel: number
  - period: string (DAILY|WEEKLY|MONTHLY)
  - updatedAt: timestamp
```

## 4. Cloud Functions (Beispiele)

### Pet Evolution Check
```javascript
exports.checkPetEvolution = functions.firestore
  .document('users/{userId}/pets/{petId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();
    
    if (newData.level > oldData.level) {
      // Check if evolution is needed
      const newEvolution = getEvolutionForLevel(newData.level);
      if (newEvolution !== newData.evolution) {
        await change.after.ref.update({
          evolution: newEvolution
        });
      }
    }
  });
```

### Daily Pet Health Decay
```javascript
exports.dailyPetHealthDecay = functions.pubsub
  .schedule('0 6 * * *')
  .timeZone('Europe/Berlin')
  .onRun(async (context) => {
    const usersSnapshot = await admin.firestore().collection('users').get();
    
    const batch = admin.firestore().batch();
    
    for (const userDoc of usersSnapshot.docs) {
      const petsSnapshot = await userDoc.ref.collection('pets').get();
      
      for (const petDoc of petsSnapshot.docs) {
        const pet = petDoc.data();
        const newHealth = Math.max(0, pet.health - 10);
        
        batch.update(petDoc.ref, { health: newHealth });
      }
    }
    
    await batch.commit();
  });
```

### Leaderboard Update
```javascript
exports.updateLeaderboard = functions.firestore
  .document('users/{userId}')
  .onWrite(async (change, context) => {
    const userId = context.params.userId;
    const userData = change.after.data();
    
    if (!userData) return; // User deleted
    
    const score = calculateUserScore(userData);
    
    await admin.firestore()
      .collection('leaderboard')
      .doc(userId)
      .set({
        userId,
        username: userData.username,
        score,
        petType: userData.activePet?.type || 'none',
        petLevel: userData.activePet?.level || 0,
        period: 'weekly',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });
  });
```

## 5. Security & GDPR

### Datenschutz-Features:
- **Account-Löschung:** Alle Nutzerdaten entfernen
- **Daten-Export:** JSON-Export aller Nutzerdaten
- **Anonymisierung:** Leaderboard-Einträge anonymisieren

### Security Best Practices:
- **Firestore Rules:** Strenge Zugriffskontrollen
- **Function Auth:** Alle Functions authentifiziert
- **Input Validation:** Server-seitige Validierung
- **Rate Limiting:** API-Missbrauch verhindern

## 6. Monitoring & Analytics

### Firebase Analytics Events:
```javascript
// Custom Events
- user_pet_created
- habit_logged
- battle_completed
- achievement_unlocked
- pet_evolved
- streak_milestone
```

### Performance Monitoring:
- **Startup Time:** App-Launch Performance
- **Network Requests:** Firebase Latency
- **Crashes:** Automatische Crash-Reports

## 7. Deployment Checklist

- [ ] Firebase Projekt erstellt
- [ ] iOS App konfiguriert
- [ ] GoogleService-Info.plist heruntergeladen
- [ ] Authentication aktiviert
- [ ] Firestore Rules deployed
- [ ] Storage Rules deployed
- [ ] Cloud Functions deployed
- [ ] Analytics konfiguriert
- [ ] Performance Monitoring aktiviert
- [ ] Crashlytics aktiviert

## 8. Testing

### Firebase Emulator Suite:
```bash
npm install -g firebase-tools
firebase init emulators
firebase emulators:start
```

### Test-Daten:
- Demo-Users mit verschiedenen Pet-Typen
- Sample Habit-Logs
- Test Battle-Questions
- Achievement-Templates