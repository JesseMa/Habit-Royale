import Foundation
import FirebaseFirestore
import FirebaseAuth

class ProgressViewModel: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalCompletions: Int = 0
    @Published var perfectDays: Int = 0
    
    @Published var weeklyCompletions: Int = 0
    @Published var weeklyGoal: Int = 21 // 3 habits * 7 days
    @Published var weeklyProgress: Double = 0.0
    
    @Published var calendarDays: [String: CalendarDay] = [:]
    
    private let db = Firestore.firestore()
    
    func loadProgress() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            // Load progress stats
            do {
                let doc = try await db.collection("users").document(userId)
                    .collection("progress").document("current")
                    .getDocument()
                
                if let progress = try? doc.data(as: UserProgress.self) {
                    await MainActor.run {
                        self.currentStreak = progress.currentStreak
                        self.longestStreak = progress.longestStreak
                        self.totalCompletions = progress.totalCompletions
                        self.perfectDays = progress.perfectDays
                    }
                }
            } catch {
                print("Error loading progress: \(error)")
            }
            
            // Load weekly progress
            await loadWeeklyProgress(userId: userId)
            
            // Load current month calendar
            await loadCalendarData(for: Date())
        }
    }
    
    private func loadWeeklyProgress(userId: String) async {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? Date()
        
        do {
            let snapshot = try await db.collection("users").document(userId)
                .collection("habitLogs")
                .whereField("date", isGreaterThanOrEqualTo: startOfWeek)
                .whereField("date", isLessThan: endOfWeek)
                .getDocuments()
            
            let completions = snapshot.documents.count
            let customHabitsSnapshot = try await db.collection("users").document(userId)
                .collection("customHabits")
                .whereField("isActive", isEqualTo: true)
                .getDocuments()
            
            let dailyHabits = 3 + customHabitsSnapshot.documents.count // 3 standard + custom
            let weeklyGoal = dailyHabits * 7
            
            await MainActor.run {
                self.weeklyCompletions = completions
                self.weeklyGoal = weeklyGoal
                self.weeklyProgress = min(Double(completions) / Double(weeklyGoal), 1.0)
            }
        } catch {
            print("Error loading weekly progress: \(error)")
        }
    }
    
    func loadCalendarData(for month: Date) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            let calendar = Calendar.current
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
                  let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
                print("Error: Could not calculate month boundaries")
                return
            }
            
            do {
                let snapshot = try await db.collection("users").document(userId)
                    .collection("calendar")
                    .whereField("date", isGreaterThanOrEqualTo: formatDate(startOfMonth))
                    .whereField("date", isLessThan: formatDate(endOfMonth))
                    .getDocuments()
                
                var days: [String: CalendarDay] = [:]
                
                for document in snapshot.documents {
                    if let day = try? document.data(as: CalendarDay.self) {
                        days[day.date] = day
                    }
                }
                
                await MainActor.run {
                    self.calendarDays = days
                }
            } catch {
                print("Error loading calendar data: \(error)")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}