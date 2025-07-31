import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    let username: String
    let email: String
    var activePetId: String?
    var experience: Int
    var level: Int
    var role: UserRole
    var createdAt: Date
    var lastActive: Date
    
    // Computed properties
    var experienceToNextLevel: Int {
        let nextLevel = level + 1
        let requiredXP = nextLevel * 100
        return requiredXP - experience
    }
    
    var levelProgress: Double {
        let currentLevelXP = (level - 1) * 100  // Fixed: Level 1 starts at 0 XP
        let nextLevelXP = level * 100
        let progressXP = experience - currentLevelXP
        let totalRequired = nextLevelXP - currentLevelXP
        
        guard totalRequired > 0 else { return 1.0 }
        return max(0.0, min(1.0, Double(progressXP) / Double(totalRequired)))
    }
    
    enum UserRole: String, Codable {
        case user = "USER"
        case petCreator = "PET_CREATOR"
        case petManager = "PET_MANAGER"
        case admin = "ADMIN"
    }
    
    init(username: String, email: String) {
        self.username = username
        self.email = email
        self.experience = 0
        self.level = 1
        self.role = .user
        self.createdAt = Date()
        self.lastActive = Date()
    }
}