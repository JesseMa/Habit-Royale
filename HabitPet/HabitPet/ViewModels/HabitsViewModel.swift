import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class HabitsViewModel: ObservableObject {
    @Published var sleepGoal: Double = 8.0
    @Published var exerciseGoal: Double = 30.0
    @Published var screenTimeGoal: Double = 2.0
    
    @Published var todaySleep: Double = 0.0
    @Published var todayExercise: Double = 0.0
    @Published var todayScreenTime: Double = 0.0
    
    @Published var customHabits: [CustomHabit] = []
    @Published var todayLogs: [String: HabitLog] = [:]
    
    @Published var showSleepLogger = false
    @Published var showExerciseLogger = false
    @Published var showScreenTimeLogger = false
    @Published var habitToLog: CustomHabitWrapper?
    
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadGoals()
        loadCustomHabits()
        loadTodayLogs()
    }
    
    deinit {
        listeners.forEach { $0.remove() }
    }
    
    // MARK: - Load Data
    
    private func loadGoals() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let listener = db.collection("users").document(userId)
            .collection("goals").document("default")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let data = snapshot?.data(),
                      let goals = try? snapshot?.data(as: Goal.self) else { return }
                
                self?.sleepGoal = goals.sleep.target
                self?.exerciseGoal = goals.exercise.target
                self?.screenTimeGoal = goals.screenTime.target
            }
        
        listeners.append(listener)
    }
    
    private func loadCustomHabits() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let listener = db.collection("users").document(userId)
            .collection("customHabits")
            .whereField("isActive", isEqualTo: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                self?.customHabits = documents.compactMap { doc in
                    try? doc.data(as: CustomHabit.self)
                }
            }
        
        listeners.append(listener)
    }
    
    private func loadTodayLogs() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let listener = db.collection("users").document(userId)
            .collection("habitLogs")
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThan: endOfDay)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                var logs: [String: HabitLog] = [:]
                var sleep = 0.0
                var exercise = 0.0
                var screenTime = 0.0
                
                for doc in documents {
                    if let log = try? doc.data(as: HabitLog.self) {
                        logs[log.habitId] = log
                        
                        switch log.habitType {
                        case .sleep:
                            sleep = log.value ?? 0
                        case .exercise:
                            exercise = log.value ?? 0
                        case .screenTime:
                            screenTime = log.value ?? 0
                        case .custom:
                            break
                        }
                    }
                }
                
                self?.todayLogs = logs
                self?.todaySleep = sleep
                self?.todayExercise = exercise
                self?.todayScreenTime = screenTime
            }
        
        listeners.append(listener)
    }
    
    // MARK: - Actions
    
    func getTodayLog(for habitId: String) -> HabitLog? {
        todayLogs[habitId]
    }
    
    func showCustomHabitLogger(for habit: CustomHabit) {
        habitToLog = CustomHabitWrapper(habit: habit)
    }
    
    func deleteCustomHabit(_ habit: CustomHabit) {
        guard let userId = Auth.auth().currentUser?.uid,
              let habitId = habit.id else { return }
        
        Task {
            do {
                try await db.collection("users").document(userId)
                    .collection("customHabits").document(habitId)
                    .updateData(["isActive": false])
            } catch {
                print("Error deleting habit: \(error)")
            }
        }
    }
    
    func logHabit(type: HabitLog.HabitType, value: Double) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let log = HabitLog(
            habitId: type.rawValue,
            habitType: type,
            date: Date(),
            value: value,
            percentage: calculatePercentage(for: type, value: value),
            createdAt: Date()
        )
        
        try await db.collection("users").document(userId)
            .collection("habitLogs")
            .addDocument(from: log)
        
        // Update pet health based on goal achievement
        await updatePetHealth(for: type, value: value)
    }
    
    private func calculatePercentage(for type: HabitLog.HabitType, value: Double) -> Double {
        switch type {
        case .sleep:
            return min(value / sleepGoal * 100, 100)
        case .exercise:
            return min(value / exerciseGoal * 100, 100)
        case .screenTime:
            return screenTimeGoal > 0 ? max((screenTimeGoal - value) / screenTimeGoal * 100, 0) : 100
        case .custom:
            return 0
        }
    }
    
    private func updatePetHealth(for type: HabitLog.HabitType, value: Double) async {
        let percentage = calculatePercentage(for: type, value: value)
        let healthChange = Int(percentage / 10) // 10 health per 100%
        
        if let petId = UserManager.shared.activePet?.id {
            try? await UserManager.shared.updatePetHealth(petId: petId, healthChange: healthChange)
        }
    }
}

// MARK: - Goals ViewModel

class GoalsViewModel: ObservableObject {
    @Published var sleepGoal: Double = 8.0
    @Published var exerciseGoal: Double = 30.0
    @Published var screenTimeGoal: Double = 2.0
    @Published var isSaving = false
    
    private let db = Firestore.firestore()
    
    init() {
        loadGoals()
    }
    
    private func loadGoals() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                let doc = try await db.collection("users").document(userId)
                    .collection("goals").document("default")
                    .getDocument()
                
                if let goals = try? doc.data(as: Goal.self) {
                    await MainActor.run {
                        self.sleepGoal = goals.sleep.target
                        self.exerciseGoal = goals.exercise.target
                        self.screenTimeGoal = goals.screenTime.target
                    }
                }
            } catch {
                print("Error loading goals: \(error)")
            }
        }
    }
    
    func saveSleepGoal() {
        saveGoal(field: "sleep.target", value: sleepGoal)
    }
    
    func saveExerciseGoal() {
        saveGoal(field: "exercise.target", value: exerciseGoal)
    }
    
    func saveScreenTimeGoal() {
        saveGoal(field: "screenTime.target", value: screenTimeGoal)
    }
    
    func saveAllGoals() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let goals = Goal()
        var updatedGoals = goals
        updatedGoals.sleep = Goal.GoalTarget(target: sleepGoal, unit: "hours")
        updatedGoals.exercise = Goal.GoalTarget(target: exerciseGoal, unit: "minutes")
        updatedGoals.screenTime = Goal.GoalTarget(target: screenTimeGoal, unit: "hours")
        
        isSaving = true
        
        Task {
            do {
                try await db.collection("users").document(userId)
                    .collection("goals").document("default")
                    .setData(from: updatedGoals)
                
                await MainActor.run {
                    self.isSaving = false
                }
            } catch {
                print("Error saving goals: \(error)")
                await MainActor.run {
                    self.isSaving = false
                }
            }
        }
    }
    
    private func saveGoal(field: String, value: Double) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                try await db.collection("users").document(userId)
                    .collection("goals").document("default")
                    .updateData([field: value])
            } catch {
                print("Error saving goal: \(error)")
            }
        }
    }
}