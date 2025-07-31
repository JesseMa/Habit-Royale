import Foundation
import FirebaseFirestoreSwift

struct Battle: Codable, Identifiable {
    @DocumentID var id: String?
    let challengerId: String
    let defenderId: String
    var status: BattleStatus
    let questions: [BattleQuestion]
    var challengerRatings: [Int]
    var defenderRatings: [Int]
    var winnerId: String?
    var challengerScore: Int?
    var defenderScore: Int?
    let createdAt: Date
    var completedAt: Date?
    
    // Computed properties
    var isCompleted: Bool {
        status == .completed
    }
    
    var challengerReady: Bool {
        !challengerRatings.isEmpty && challengerRatings.count == questions.count
    }
    
    var defenderReady: Bool {
        !defenderRatings.isEmpty && defenderRatings.count == questions.count
    }
    
    enum BattleStatus: String, Codable {
        case pending = "PENDING"
        case active = "ACTIVE"
        case completed = "COMPLETED"
        case declined = "DECLINED"
        case expired = "EXPIRED"
    }
}

struct BattleQuestion: Codable, Identifiable {
    let id: String
    let question: String
    let description: String?
    let category: QuestionCategory
    let icon: String
    let positiveWeighting: Bool
    
    enum QuestionCategory: String, Codable, CaseIterable {
        case health = "HEALTH"
        case relationships = "RELATIONSHIPS"
        case spirituality = "SPIRITUALITY"
        case productivity = "PRODUCTIVITY"
        case habits = "HABITS"
        
        var name: String {
            switch self {
            case .health: return "Gesundheit"
            case .relationships: return "Beziehungen"
            case .spirituality: return "Spiritualität"
            case .productivity: return "Produktivität"
            case .habits: return "Gewohnheiten"
            }
        }
        
        var color: String {
            switch self {
            case .health: return "green"
            case .relationships: return "pink"
            case .spirituality: return "purple"
            case .productivity: return "orange"
            case .habits: return "blue"
            }
        }
    }
}

struct BattleStats: Codable {
    var totalBattles: Int
    var wins: Int
    var losses: Int
    var currentStreak: Int
    var bestStreak: Int
    var averageScore: Double
    var categoryScores: [String: Double]
    
    // Computed properties
    var winRate: Double {
        guard totalBattles > 0 else { return 0 }
        return Double(wins) / Double(totalBattles) * 100
    }
    
    var performance: PerformanceLevel {
        if winRate >= 70 { return .excellent }
        if winRate >= 50 { return .good }
        if winRate >= 30 { return .average }
        return .needsImprovement
    }
    
    enum PerformanceLevel {
        case excellent
        case good
        case average
        case needsImprovement
        
        var emoji: String {
            switch self {
            case .excellent: return "🏆"
            case .good: return "⭐"
            case .average: return "👍"
            case .needsImprovement: return "💪"
            }
        }
        
        var message: String {
            switch self {
            case .excellent: return "Exzellente Leistung!"
            case .good: return "Gute Arbeit!"
            case .average: return "Weiter so!"
            case .needsImprovement: return "Übung macht den Meister!"
            }
        }
    }
    
    init() {
        self.totalBattles = 0
        self.wins = 0
        self.losses = 0
        self.currentStreak = 0
        self.bestStreak = 0
        self.averageScore = 0
        self.categoryScores = [:]
    }
}