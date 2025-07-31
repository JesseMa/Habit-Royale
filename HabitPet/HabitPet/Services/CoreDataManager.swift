import Foundation
import CoreData
import FirebaseFirestore

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HabitRoyale")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - Save Context
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Offline Sync
    
    func syncWithFirebase() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.syncUsers() }
            group.addTask { await self.syncPets() }
            group.addTask { await self.syncHabits() }
        }
    }
    
    private func syncUsers() async {
        // Sync logic for users
        print("Syncing users with Firebase...")
    }
    
    private func syncPets() async {
        // Sync logic for pets
        print("Syncing pets with Firebase...")
    }
    
    private func syncHabits() async {
        // Sync logic for habits
        print("Syncing habits with Firebase...")
    }
    
    // MARK: - Offline Data Management
    
    func hasOfflineData() -> Bool {
        let userRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let count = try context.count(for: userRequest)
            return count > 0
        } catch {
            return false
        }
    }
    
    func clearAllData() {
        let entities = ["UserEntity", "PetEntity", "HabitLogEntity", "CustomHabitEntity"]
        
        for entityName in entities {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Error deleting \(entityName): \(error)")
            }
        }
        
        save()
    }
}

// MARK: - Core Data Extensions

extension CoreDataManager {
    
    // MARK: - User Management
    
    func createOfflineUser(from user: User) {
        let userEntity = UserEntity(context: context)
        userEntity.id = user.id
        userEntity.username = user.username
        userEntity.email = user.email
        userEntity.level = Int32(user.level)
        userEntity.experience = Int32(user.experience)
        userEntity.activePetId = user.activePetId
        userEntity.createdAt = user.createdAt
        userEntity.lastLoginAt = user.lastLoginAt
        userEntity.needsSync = false
        
        save()
    }
    
    func fetchOfflineUser() -> User? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let userEntities = try context.fetch(request)
            return userEntities.first?.toUser()
        } catch {
            print("Error fetching offline user: \(error)")
            return nil
        }
    }
    
    // MARK: - Pet Management
    
    func createOfflinePet(from pet: Pet, userId: String) {
        let petEntity = PetEntity(context: context)
        petEntity.id = pet.id
        petEntity.userId = userId
        petEntity.templateId = pet.templateId
        petEntity.name = pet.name
        petEntity.level = Int32(pet.level)
        petEntity.experience = Int32(pet.experience)
        petEntity.health = Int32(pet.health)
        petEntity.maxHealth = Int32(pet.maxHealth)
        petEntity.attack = Int32(pet.attack)
        petEntity.defense = Int32(pet.defense)
        petEntity.evolution = pet.evolution.rawValue
        petEntity.slotIndex = Int32(pet.slotIndex)
        petEntity.isActive = pet.isActive
        petEntity.customImageUrl = pet.customImageUrl
        petEntity.createdAt = pet.createdAt
        petEntity.lastFed = pet.lastFed
        petEntity.needsSync = false
        
        save()
    }
    
    func fetchOfflinePets(for userId: String) -> [Pet] {
        let request: NSFetchRequest<PetEntity> = PetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PetEntity.slotIndex, ascending: true)]
        
        do {
            let petEntities = try context.fetch(request)
            return petEntities.compactMap { $0.toPet() }
        } catch {
            print("Error fetching offline pets: \(error)")
            return []
        }
    }
    
    // MARK: - Habit Log Management
    
    func createOfflineHabitLog(from log: HabitLog, userId: String) {
        let logEntity = HabitLogEntity(context: context)
        logEntity.id = log.id
        logEntity.userId = userId
        logEntity.habitId = log.habitId
        logEntity.habitType = log.habitType.rawValue
        logEntity.date = log.date
        logEntity.value = log.value ?? 0
        logEntity.percentage = log.percentage
        logEntity.notes = log.notes
        logEntity.createdAt = log.createdAt
        logEntity.needsSync = true // New logs need sync
        
        save()
    }
    
    func fetchOfflineHabitLogs(for userId: String, date: Date) -> [HabitLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        
        let request: NSFetchRequest<HabitLogEntity> = HabitLogEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@ AND date >= %@ AND date < %@", 
                                       userId, startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HabitLogEntity.date, ascending: false)]
        
        do {
            let logEntities = try context.fetch(request)
            return logEntities.compactMap { $0.toHabitLog() }
        } catch {
            print("Error fetching offline habit logs: \(error)")
            return []
        }
    }
    
    // MARK: - Sync Status
    
    func getPendingSyncCount() -> Int {
        let habitLogRequest: NSFetchRequest<HabitLogEntity> = HabitLogEntity.fetchRequest()
        habitLogRequest.predicate = NSPredicate(format: "needsSync == YES")
        
        let userRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        userRequest.predicate = NSPredicate(format: "needsSync == YES")
        
        let petRequest: NSFetchRequest<PetEntity> = PetEntity.fetchRequest()
        petRequest.predicate = NSPredicate(format: "needsSync == YES")
        
        do {
            let habitLogs = try context.count(for: habitLogRequest)
            let users = try context.count(for: userRequest)
            let pets = try context.count(for: petRequest)
            
            return habitLogs + users + pets
        } catch {
            print("Error getting pending sync count: \(error)")
            return 0
        }
    }
}

// MARK: - Core Data Entity Extensions

extension UserEntity {
    func toUser() -> User {
        return User(
            id: self.id,
            username: self.username ?? "",
            email: self.email ?? "",
            level: Int(self.level),
            experience: Int(self.experience),
            activePetId: self.activePetId,
            createdAt: self.createdAt ?? Date(),
            lastLoginAt: self.lastLoginAt ?? Date()
        )
    }
}

extension PetEntity {
    func toPet() -> Pet? {
        guard let id = self.id,
              let templateId = self.templateId,
              let name = self.name,
              let createdAt = self.createdAt,
              let lastFed = self.lastFed,
              let evolution = Pet.Evolution(rawValue: Int(self.evolution)) else {
            return nil
        }
        
        var pet = Pet(templateId: templateId, name: name, slotIndex: Int(slotIndex))
        pet.id = id
        pet.level = Int(level)
        pet.experience = Int(experience)
        pet.health = Int(health)
        pet.maxHealth = Int(maxHealth)
        pet.attack = Int(attack)
        pet.defense = Int(defense)
        pet.evolution = evolution
        pet.isActive = isActive
        pet.customImageUrl = customImageUrl
        pet.createdAt = createdAt
        pet.lastFed = lastFed
        
        return pet
    }
}

extension HabitLogEntity {
    func toHabitLog() -> HabitLog? {
        guard let id = self.id,
              let habitId = self.habitId,
              let habitTypeString = self.habitType,
              let habitType = HabitLog.HabitType(rawValue: habitTypeString),
              let date = self.date,
              let createdAt = self.createdAt else {
            return nil
        }
        
        return HabitLog(
            id: id,
            habitId: habitId,
            habitType: habitType,
            date: date,
            value: value == 0 ? nil : value,
            percentage: percentage,
            notes: notes,
            createdAt: createdAt
        )
    }
}