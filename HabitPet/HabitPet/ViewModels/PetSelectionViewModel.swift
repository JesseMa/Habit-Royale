import Foundation
import FirebaseFirestore

class PetSelectionViewModel: ObservableObject {
    @Published var availablePets: [PetTemplate] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    func loadRandomPets(count: Int) async {
        isLoading = true
        
        do {
            // Fetch all visible common pets for new users
            let snapshot = try await db.collection("petTemplates")
                .whereField("isVisible", isEqualTo: true)
                .whereField("category", isEqualTo: "COMMON")
                .whereField("unlockLevel", isLessThanOrEqualTo: 1)
                .getDocuments()
            
            var allPets = snapshot.documents.compactMap { doc in
                try? doc.data(as: PetTemplate.self)
            }
            
            // Shuffle and take requested count
            allPets.shuffle()
            let selectedPets = Array(allPets.prefix(count))
            
            await MainActor.run {
                self.availablePets = selectedPets
                self.isLoading = false
            }
        } catch {
            print("Error loading pets: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}