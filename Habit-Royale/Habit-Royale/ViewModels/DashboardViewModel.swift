import Foundation
import FirebaseFirestore

class DashboardViewModel: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var todayHabits: [HabitLog] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    func loadDashboardData() {
        guard let userId = UserManager.shared.currentUser?.id else { return }
        
        isLoading = true
        
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.fetchCurrentStreak(userId: userId) }
                group.addTask { await self.fetchTodayHabits(userId: userId) }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func fetchCurrentStreak(userId: String) async {
        do {
            let doc = try await db.collection("users").document(userId)
                .collection("streak").document("current")
                .getDocument()
            
            if let streak = try? doc.data(as: UserStreak.self) {
                await MainActor.run {
                    self.currentStreak = streak.count
                }
            }
        } catch {
            print("Error fetching streak: \(error)")
        }
    }
    
    private func fetchTodayHabits(userId: String) async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            print("Error: Could not calculate end of day")
            return
        }
        
        do {
            let snapshot = try await db.collection("users").document(userId)
                .collection("habitLogs")
                .whereField("date", isGreaterThanOrEqualTo: startOfDay)
                .whereField("date", isLessThan: endOfDay)
                .getDocuments()
            
            let habits = snapshot.documents.compactMap { doc in
                try? doc.data(as: HabitLog.self)
            }
            
            await MainActor.run {
                self.todayHabits = habits
            }
        } catch {
            print("Error fetching today's habits: \(error)")
        }
    }
}