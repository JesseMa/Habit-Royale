import Foundation
import FirebaseFirestore
import FirebaseAuth

class LeaderboardViewModel: ObservableObject {
    @Published var entries: [LeaderboardEntry] = []
    @Published var isLoading = false
    @Published var userRank: Int?
    @Published var userScore: Int?
    
    private let db = Firestore.firestore()
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func loadLeaderboard(for period: LeaderboardPeriod) {
        isLoading = true
        
        Task {
            do {
                let snapshot = try await db.collection("leaderboard")
                    .document(period.rawValue)
                    .collection("entries")
                    .order(by: "score", descending: true)
                    .limit(to: 100)
                    .getDocuments()
                
                let entries = snapshot.documents.compactMap { doc in
                    try? doc.data(as: LeaderboardEntry.self)
                }
                
                await MainActor.run {
                    self.entries = entries
                    self.updateUserStats()
                    self.isLoading = false
                }
            } catch {
                print("Error loading leaderboard: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func updateUserStats() {
        guard let userId = currentUserId,
              let userEntry = entries.enumerated().first(where: { $0.element.userId == userId }) else {
            return
        }
        
        userRank = userEntry.offset + 1
        userScore = userEntry.element.score
    }
}