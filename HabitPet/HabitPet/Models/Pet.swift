import Foundation
import FirebaseFirestoreSwift

struct Pet: Codable, Identifiable {
    @DocumentID var id: String?
    let templateId: String
    var name: String
    var level: Int
    var experience: Int
    var health: Int
    var maxHealth: Int
    var attack: Int
    var defense: Int
    var evolution: Evolution
    var slotIndex: Int
    var isActive: Bool
    var customImageUrl: String?
    let createdAt: Date
    var lastFed: Date
    
    // MARK: - Initializers
    init(templateId: String, name: String, slotIndex: Int) {
        self.templateId = templateId
        self.name = name
        self.level = 1
        self.experience = 0
        self.health = 100
        self.maxHealth = 100
        self.attack = 10
        self.defense = 10
        self.evolution = .baby
        self.slotIndex = slotIndex
        self.isActive = false
        self.customImageUrl = nil
        self.createdAt = Date()
        self.lastFed = Date()
    }
    
    // Computed properties
    var healthPercentage: Double {
        Double(health) / Double(maxHealth)
    }
    
    var experienceToNextLevel: Int {
        let nextLevel = level + 1
        let requiredXP = nextLevel * 50
        return requiredXP - experience
    }
    
    var levelProgress: Double {
        let currentLevelXP = (level - 1) * 50  // Level 1 starts at 0 XP
        let nextLevelXP = level * 50
        let progressXP = experience - currentLevelXP
        let totalRequired = nextLevelXP - currentLevelXP
        
        guard totalRequired > 0 else { return 1.0 }
        return max(0.0, min(1.0, Double(progressXP) / Double(totalRequired)))
    }
    
    enum Evolution: Int, Codable, CaseIterable {
        case egg = 0
        case baby = 1
        case young = 2
        case adult = 3
        case elite = 4
        case legendary = 5
        
        var name: String {
            switch self {
            case .egg: return "Ei"
            case .baby: return "Baby"
            case .young: return "Jung"
            case .adult: return "Erwachsen"
            case .elite: return "Elite"
            case .legendary: return "Legendär"
            }
        }
        
        var emoji: String {
            switch self {
            case .egg: return "🥚"
            case .baby: return "🐣"
            case .young: return "🐥"
            case .adult: return "🦅"
            case .elite: return "⚔️"
            case .legendary: return "👑"
            }
        }
        
        var minLevel: Int {
            switch self {
            case .egg: return 0
            case .baby: return 1
            case .young: return 3
            case .adult: return 8
            case .elite: return 15
            case .legendary: return 25
            }
        }
    }
    
    static func getEvolution(for level: Int) -> Evolution {
        if level >= 25 { return .legendary }
        if level >= 15 { return .elite }
        if level >= 8 { return .adult }
        if level >= 3 { return .young }
        if level >= 1 { return .baby }
        return .egg
    }
}

struct PetTemplate: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let type: String
    let description: String
    let category: PetCategory
    let baseHealth: Int
    let baseAttack: Int
    let baseDefense: Int
    let unlockLevel: Int
    var evolutions: [PetEvolution]
    var isVisible: Bool
    let createdBy: String?
    
    enum PetCategory: String, Codable, CaseIterable {
        case common = "COMMON"
        case rare = "RARE"
        case epic = "EPIC"
        case legendary = "LEGENDARY"
        
        var color: String {
            switch self {
            case .common: return "gray"
            case .rare: return "blue"
            case .epic: return "purple"
            case .legendary: return "yellow"
            }
        }
    }
}

struct PetEvolution: Codable {
    let name: String
    let minLevel: Int
    let maxLevel: Int
    var statsImageUrl: String?
    var fullCamUrl: String?
    var legacyAssetUrl: String?
}