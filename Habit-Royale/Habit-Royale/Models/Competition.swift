import Foundation
import FirebaseFirestoreSwift

// Leaderboard
struct LeaderboardEntry: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let username: String
    var score: Int
    var rank: Int
    let petType: String?
    let petLevel: Int
    let lastUpdated: Date
    
    var isTopThree: Bool {
        rank <= 3
    }
    
    var rankEmoji: String {
        switch rank {
        case 1: return "👑"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "🏆"
        }
    }
}

enum LeaderboardPeriod: String, CaseIterable {
    case weekly = "WEEKLY"
    case monthly = "MONTHLY"
    case allTime = "ALL_TIME"
    
    var name: String {
        switch self {
        case .weekly: return "Wöchentlich"
        case .monthly: return "Monatlich"
        case .allTime: return "Gesamt"
        }
    }
}

// Progress
struct UserProgress: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var totalCompletions: Int
    var perfectDays: Int
    var lastStreakDate: Date?
    
    init() {
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalCompletions = 0
        self.perfectDays = 0
    }
}

struct CalendarDay: Codable, Identifiable {
    var id: String { date }
    let date: String // Format: yyyy-MM-dd
    var habitCompletions: [String: Bool]
    var completionRate: Double
    var streak: Int
    
    var completionColor: String {
        if completionRate == 1.0 { return "green" }
        if completionRate >= 0.8 { return "lightGreen" }
        if completionRate >= 0.6 { return "yellow" }
        if completionRate >= 0.4 { return "orange" }
        if completionRate > 0 { return "red" }
        return "gray"
    }
}

// Achievements
struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int
    let xpReward: Int
    
    enum AchievementCategory: String, Codable, CaseIterable {
        case streak = "STREAK"
        case completion = "COMPLETION"
        case level = "LEVEL"
        case special = "SPECIAL"
        
        var name: String {
            switch self {
            case .streak: return "Serien"
            case .completion: return "Abschlüsse"
            case .level: return "Level"
            case .special: return "Spezial"
            }
        }
        
        var gradientColors: [String] {
            switch self {
            case .streak: return ["orange", "red"]
            case .completion: return ["green", "blue"]
            case .level: return ["purple", "pink"]
            case .special: return ["yellow", "orange"]
            }
        }
    }
}

struct UserAchievement: Codable, Identifiable {
    @DocumentID var id: String?
    let achievementId: String
    let unlockedAt: Date
    var progress: Int
}