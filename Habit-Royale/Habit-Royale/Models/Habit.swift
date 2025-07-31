import Foundation
import FirebaseFirestoreSwift

// Standard Habits
struct Goal: Codable {
    var sleep: GoalTarget
    var exercise: GoalTarget
    var screenTime: GoalTarget
    
    struct GoalTarget: Codable {
        var target: Double
        let unit: String
    }
    
    init() {
        self.sleep = GoalTarget(target: 8, unit: "hours")
        self.exercise = GoalTarget(target: 30, unit: "minutes")
        self.screenTime = GoalTarget(target: 2, unit: "hours")
    }
}

// Custom Habits
struct CustomHabitWrapper: Identifiable {
    let id = UUID()
    let habit: CustomHabit
}

struct CustomHabit: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let emoji: String
    let description: String
    let targetType: TargetType
    let targetValue: Double
    let targetUnit: String
    let effect: PetEffect
    let intensity: EffectIntensity
    let createdAt: Date
    var isActive: Bool
    
    enum TargetType: String, Codable {
        case numeric = "NUMERIC"
        case yesno = "YESNO"
    }
    
    enum PetEffect: String, Codable, CaseIterable {
        case attack = "ATTACK"
        case defense = "DEFENSE"
        case health = "HEALTH"
        case experience = "EXPERIENCE"
        
        var emoji: String {
            switch self {
            case .attack: return "⚡"
            case .defense: return "🛡️"
            case .health: return "❤️"
            case .experience: return "⭐"
            }
        }
        
        var color: String {
            switch self {
            case .attack: return "yellow"
            case .defense: return "blue"
            case .health: return "red"
            case .experience: return "purple"
            }
        }
    }
    
    enum EffectIntensity: String, Codable, CaseIterable {
        case light = "LIGHT"
        case medium = "MEDIUM"
        case strong = "STRONG"
        
        var value: Int {
            switch self {
            case .light: return 2
            case .medium: return 5
            case .strong: return 10
            }
        }
        
        var color: String {
            switch self {
            case .light: return "green"
            case .medium: return "yellow"
            case .strong: return "red"
            }
        }
    }
}

// Habit Logs
struct HabitLog: Codable, Identifiable {
    @DocumentID var id: String?
    let habitId: String
    let habitType: HabitType
    let date: Date
    var value: Double?
    var percentage: Double
    var notes: String?
    let createdAt: Date
    
    enum HabitType: String, Codable {
        case sleep = "SLEEP"
        case exercise = "EXERCISE"
        case screenTime = "SCREEN_TIME"
        case custom = "CUSTOM"
    }
}

// Streak tracking
struct UserStreak: Codable {
    var count: Int
    var lastDate: Date
    var startDate: Date
    var longestStreak: Int
    
    init() {
        self.count = 0
        self.lastDate = Date()
        self.startDate = Date()
        self.longestStreak = 0
    }
}