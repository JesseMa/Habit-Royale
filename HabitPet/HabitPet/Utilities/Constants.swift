import Foundation
import SwiftUI

struct Constants {
    
    // MARK: - App Configuration
    struct App {
        static let name = "Habit Royale"
        static let version = "1.0.0"
        static let bundleIdentifier = "com.yourcompany.habitroyale"
    }
    
    // MARK: - Firebase Collections
    struct FirebaseCollections {
        static let users = "users"
        static let pets = "pets"
        static let petTemplates = "petTemplates"
        static let battles = "battles"
        static let battleQuestions = "battleQuestions"
        static let achievements = "achievements"
        static let leaderboard = "leaderboard"
        static let customHabits = "customHabits"
        static let habitLogs = "habitLogs"
        static let calendar = "calendar"
        static let progress = "progress"
        static let battleStats = "battleStats"
        static let streak = "streak"
        static let goals = "goals"
    }
    
    // MARK: - User Defaults Keys
    struct UserDefaults {
        static let isFirstLaunch = "isFirstLaunch"
        static let lastSyncTimestamp = "lastSyncTimestamp"
        static let notificationsEnabled = "notificationsEnabled"
        static let darkModeEnabled = "darkModeEnabled"
    }
    
    // MARK: - Notification Names
    struct NotificationNames {
        static let petHealthLow = "PetHealthLow"
        static let newBattleChallenge = "NewBattleChallenge"
        static let habitReminder = "HabitReminder"
        static let streakMilestone = "StreakMilestone"
        static let achievementUnlocked = "AchievementUnlocked"
    }
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let accent = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let success = Color.green
        
        // Pet Categories
        static let common = Color.gray
        static let rare = Color.blue
        static let epic = Color.purple
        static let legendary = Color.yellow
        
        // Habit Effects
        static let attack = Color.yellow
        static let defense = Color.blue
        static let health = Color.red
        static let experience = Color.purple
    }
    
    // MARK: - Dimensions
    struct Dimensions {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 5
        static let buttonHeight: CGFloat = 50
        static let cardPadding: CGFloat = 16
        static let screenPadding: CGFloat = 20
    }
    
    // MARK: - Animation
    struct Animation {
        static let defaultDuration: Double = 0.3
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.8
    }
    
    // MARK: - Pet Configuration
    struct Pet {
        static let maxSlots = 3
        static let unlockLevels = [1, 5, 10]
        static let evolutionLevels = [0, 1, 3, 8, 15, 25]
        static let maxHealth = 100
        static let dailyHealthDecay = 10
        static let habitHealthBonus = 15
    }
    
    // MARK: - Battle Configuration
    struct Battle {
        static let questionsPerBattle = 3
        static let winnerXP = 30
        static let loserXP = 10
        static let ratingScale = 1...10
        static let expirationHours = 48
    }
    
    // MARK: - Habit Configuration
    struct Habit {
        static let standardHabits = ["sleep", "exercise", "screenTime"]
        static let maxCustomHabits = 10
        static let streakMinimumPercentage = 0.7
        static let perfectDayPercentage = 1.0
    }
    
    // MARK: - Achievement Configuration
    struct Achievement {
        static let streakMilestones = [3, 7, 30, 100]
        static let completionMilestones = [10, 50, 200, 500]
        static let levelMilestones = [5, 10, 20, 50]
        static let xpReward = 25
    }
    
    // MARK: - Leaderboard Configuration
    struct Leaderboard {
        static let maxEntries = 100
        static let pointsPerHabit = 10
        static let pointsPerPetLevel = 50
        static let pointsPerUserLevel = 25
        static let pointsPerAchievement = 25
    }
    
    // MARK: - URL Schemes
    struct URLSchemes {
        static let app = "habitroyale"
        static let battle = "habitroyale://battle"
        static let pet = "habitroyale://pet"
        static let habits = "habitroyale://habits"
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let genericError = "Ein Fehler ist aufgetreten. Bitte versuche es erneut."
        static let networkError = "Keine Internetverbindung. Bitte überprüfe deine Verbindung."
        static let authenticationError = "Anmeldung fehlgeschlagen. Bitte überprüfe deine Anmeldedaten."
        static let petCreationError = "Pet konnte nicht erstellt werden. Bitte versuche es erneut."
        static let habitLogError = "Gewohnheit konnte nicht gespeichert werden. Bitte versuche es erneut."
        static let battleError = "Kampf konnte nicht gestartet werden. Bitte versuche es erneut."
    }
    
    // MARK: - Success Messages
    struct SuccessMessages {
        static let petCreated = "Pet erfolgreich erstellt! 🎉"
        static let habitLogged = "Gewohnheit erfolgreich eingetragen! ✅"
        static let goalAchieved = "Ziel erreicht! Dein Pet ist glücklich! 😊"
        static let battleWon = "Kampf gewonnen! +30 XP! 🏆"
        static let achievementUnlocked = "Neuer Erfolg freigeschaltet! 🌟"
        static let evolutionUnlocked = "Pet hat sich weiterentwickelt! 🎊"
    }
    
    // MARK: - Validation
    struct Validation {
        static let minUsernameLength = 3
        static let maxUsernameLength = 20
        static let minPasswordLength = 6
        static let maxPetNameLength = 15
        static let maxHabitNameLength = 30
        static let maxNotesLength = 100
    }
    
    // MARK: - Image Configuration
    struct Images {
        static let maxImageSize: Int64 = 5 * 1024 * 1024 // 5MB
        static let supportedFormats = ["jpg", "jpeg", "png", "heic"]
        static let thumbnailSize = CGSize(width: 150, height: 150)
        static let fullImageSize = CGSize(width: 500, height: 500)
    }
}

// MARK: - Extensions
extension Color {
    static func categoryColor(for category: PetTemplate.PetCategory) -> Color {
        switch category {
        case .common: return Constants.Colors.common
        case .rare: return Constants.Colors.rare
        case .epic: return Constants.Colors.epic
        case .legendary: return Constants.Colors.legendary
        }
    }
    
    static func effectColor(for effect: CustomHabit.PetEffect) -> Color {
        switch effect {
        case .attack: return Constants.Colors.attack
        case .defense: return Constants.Colors.defense
        case .health: return Constants.Colors.health
        case .experience: return Constants.Colors.experience
        }
    }
}

extension Animation {
    static var habitRoyaleDefault: Animation {
        .spring(response: Constants.Animation.springResponse, dampingFraction: Constants.Animation.springDamping)
    }
    
    static var habitRoyaleQuick: Animation {
        .easeInOut(duration: Constants.Animation.defaultDuration)
    }
}