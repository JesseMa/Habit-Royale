import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var currentUser: User?
    @Published var activePet: Pet?
    @Published var pets: [Pet] = []
    @Published var hasActivePet: Bool = false
    @Published var unlockedSlots: Int = 1
    
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupUserListener()
    }
    
    deinit {
        removeAllListeners()
    }
    
    // MARK: - Setup
    
    private func setupUserListener() {
        AuthenticationManager.shared.$currentUser
            .sink { [weak self] user in
                if let user = user {
                    self?.currentUser = user
                    self?.updateUnlockedSlots()
                    self?.setupPetsListener(userId: user.id ?? "")
                    if let activePetId = user.activePetId {
                        self?.fetchActivePet(petId: activePetId, userId: user.id ?? "")
                    }
                } else {
                    self?.removeAllListeners()
                    self?.currentUser = nil
                    self?.activePet = nil
                    self?.pets = []
                    self?.hasActivePet = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupPetsListener(userId: String) {
        let listener = db.collection("users").document(userId)
            .collection("pets")
            .order(by: "slotIndex")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching pets: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self?.pets = documents.compactMap { doc in
                    try? doc.data(as: Pet.self)
                }
                
                // Update active pet if needed
                if let activePet = self?.pets.first(where: { $0.isActive }) {
                    self?.activePet = activePet
                    self?.hasActivePet = true
                }
            }
        
        listeners.append(listener)
    }
    
    // MARK: - Pet Management
    
    func createPet(templateId: String, name: String, slotIndex: Int) async throws {
        guard let userId = currentUser?.id else { throw UserError.notAuthenticated }
        
        // Fetch pet template
        let template = try await fetchPetTemplate(templateId: templateId)
        
        // Create new pet
        var newPet = Pet(templateId: templateId, name: name, slotIndex: slotIndex)
        
        // Apply template stats
        newPet.health = template.baseHealth
        newPet.maxHealth = template.baseHealth  
        newPet.attack = template.baseAttack
        newPet.defense = template.baseDefense
        newPet.evolution = .egg
        newPet.isActive = (slotIndex == 0) // First pet is active by default
        
        // Save to Firestore
        let docRef = try db.collection("users").document(userId)
            .collection("pets")
            .addDocument(from: newPet)
        
        // If first pet, set as active
        if slotIndex == 0 {
            try await setActivePet(petId: docRef.documentID)
        }
    }
    
    func setActivePet(petId: String) async throws {
        guard let userId = currentUser?.id else { throw UserError.notAuthenticated }
        
        // Deactivate all pets
        let batch = db.batch()
        
        for pet in pets {
            if let id = pet.id {
                let ref = db.collection("users").document(userId)
                    .collection("pets").document(id)
                batch.updateData(["isActive": false], forDocument: ref)
            }
        }
        
        // Activate selected pet
        let selectedPetRef = db.collection("users").document(userId)
            .collection("pets").document(petId)
        batch.updateData(["isActive": true], forDocument: selectedPetRef)
        
        // Update user's active pet
        let userRef = db.collection("users").document(userId)
        batch.updateData(["activePetId": petId], forDocument: userRef)
        
        try await batch.commit()
    }
    
    func deletePet(petId: String) async throws {
        guard let userId = currentUser?.id else { throw UserError.notAuthenticated }
        
        // Don't allow deleting the only pet
        if pets.count <= 1 {
            throw UserError.cannotDeleteLastPet
        }
        
        // Delete pet
        try await db.collection("users").document(userId)
            .collection("pets").document(petId)
            .delete()
        
        // If deleted pet was active, activate another
        if activePet?.id == petId, let firstPet = pets.first(where: { $0.id != petId }) {
            try await setActivePet(petId: firstPet.id ?? "")
        }
    }
    
    // MARK: - Pet Stats Updates
    
    func updatePetHealth(petId: String, healthChange: Int) async throws {
        guard let userId = currentUser?.id else { throw UserError.notAuthenticated }
        
        let petRef = db.collection("users").document(userId)
            .collection("pets").document(petId)
        
        try await db.runTransaction { transaction, errorPointer in
            let petDoc = try transaction.getDocument(petRef)
            guard let pet = try? petDoc.data(as: Pet.self) else {
                throw UserError.petNotFound
            }
            
            let newHealth = max(0, min(pet.maxHealth, pet.health + healthChange))
            transaction.updateData([
                "health": newHealth,
                "lastFed": Date()
            ], forDocument: petRef)
            
            return nil
        }
    }
    
    func addPetExperience(petId: String, experience: Int) async throws {
        guard let userId = currentUser?.id else { throw UserError.notAuthenticated }
        
        let petRef = db.collection("users").document(userId)
            .collection("pets").document(petId)
        
        try await db.runTransaction { transaction, errorPointer in
            let petDoc = try transaction.getDocument(petRef)
            guard var pet = try? petDoc.data(as: Pet.self) else {
                throw UserError.petNotFound
            }
            
            pet.experience += experience
            
            // Check for level up
            while pet.experience >= (pet.level + 1) * 50 {
                pet.level += 1
                
                // Check for evolution
                let newEvolution = Pet.getEvolution(for: pet.level)
                if newEvolution.rawValue > pet.evolution.rawValue {
                    pet.evolution = newEvolution
                    // Increase stats on evolution
                    pet.maxHealth += 10
                    pet.health = pet.maxHealth
                    pet.attack += 5
                    pet.defense += 3
                }
            }
            
            transaction.updateData([
                "experience": pet.experience,
                "level": pet.level,
                "evolution": pet.evolution.rawValue,
                "maxHealth": pet.maxHealth,
                "health": pet.health,
                "attack": pet.attack,
                "defense": pet.defense
            ], forDocument: petRef)
            
            return nil
        }
        
        // Also update user experience
        try await addUserExperience(experience)
    }
    
    // MARK: - User Stats
    
    func addUserExperience(_ experience: Int) async throws {
        guard let userId = currentUser?.id else { throw UserError.notAuthenticated }
        
        let userRef = db.collection("users").document(userId)
        
        try await db.runTransaction { transaction, errorPointer in
            let userDoc = try transaction.getDocument(userRef)
            guard var user = try? userDoc.data(as: User.self) else {
                throw UserError.userNotFound
            }
            
            user.experience += experience
            
            // Check for level up
            while user.experience >= (user.level + 1) * 100 {
                user.level += 1
            }
            
            transaction.updateData([
                "experience": user.experience,
                "level": user.level
            ], forDocument: userRef)
            
            return nil
        }
        
        updateUnlockedSlots()
    }
    
    // MARK: - Helper Methods
    
    private func fetchActivePet(petId: String, userId: String) {
        let listener = db.collection("users").document(userId)
            .collection("pets").document(petId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching active pet: \(error)")
                    return
                }
                
                self?.activePet = try? snapshot?.data(as: Pet.self)
                self?.hasActivePet = self?.activePet != nil
            }
        
        listeners.append(listener)
    }
    
    private func fetchPetTemplate(templateId: String) async throws -> PetTemplate {
        let doc = try await db.collection("petTemplates").document(templateId).getDocument()
        guard let template = try? doc.data(as: PetTemplate.self) else {
            throw UserError.templateNotFound
        }
        return template
    }
    
    private func updateUnlockedSlots() {
        guard let level = currentUser?.level else { return }
        
        if level >= 10 {
            unlockedSlots = 3
        } else if level >= 5 {
            unlockedSlots = 2
        } else {
            unlockedSlots = 1
        }
    }
    
    private func removeAllListeners() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
}

// MARK: - Custom Errors

enum UserError: LocalizedError {
    case notAuthenticated
    case userNotFound
    case petNotFound
    case templateNotFound
    case cannotDeleteLastPet
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Benutzer nicht angemeldet."
        case .userNotFound:
            return "Benutzer nicht gefunden."
        case .petNotFound:
            return "Pet nicht gefunden."
        case .templateNotFound:
            return "Pet-Vorlage nicht gefunden."
        case .cannotDeleteLastPet:
            return "Das letzte Pet kann nicht gelöscht werden."
        }
    }
}