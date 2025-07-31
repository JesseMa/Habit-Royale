import SwiftUI

struct UserSearchView: View {
    let onChallenge: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var searchResults: [UserSearchResult] = []
    @State private var isSearching = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Search bar
                searchSection
                
                // Results
                if isSearching {
                    loadingView
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    emptyResultsView
                } else {
                    searchResultsList
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Spieler suchen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
        .alert("Fehler", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: searchText) { _ in
            performSearch()
        }
    }
    
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Benutzername eingeben:")
                .font(.headline)
            
            TextField("Benutzername...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Text("Suche nach Spielern, die du zu einem Kampf herausfordern möchtest.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Suche Spieler...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Keine Spieler gefunden")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Versuche einen anderen Benutzernamen.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(searchResults) { result in
                    UserSearchResultCard(
                        user: result,
                        onChallenge: {
                            challengeUser(result.username)
                        }
                    )
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty, searchText.count >= 3 else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        Task {
            do {
                // Simulate search delay
                try await Task.sleep(nanoseconds: 500_000_000)
                
                // Mock search results for development
                let mockResults = createMockResults(for: searchText)
                
                await MainActor.run {
                    self.searchResults = mockResults
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Fehler bei der Suche: \(error.localizedDescription)"
                    self.showError = true
                    self.isSearching = false
                }
            }
        }
    }
    
    private func challengeUser(_ username: String) {
        onChallenge(username)
        dismiss()
    }
    
    private func createMockResults(for query: String) -> [UserSearchResult] {
        // Mock data for development - replace with real Firebase search
        let mockUsers = [
            UserSearchResult(id: "1", username: "TestUser1", level: 5, petType: "Tiger", isOnline: true),
            UserSearchResult(id: "2", username: "TestUser2", level: 8, petType: "Wolf", isOnline: false),
            UserSearchResult(id: "3", username: "TestUser3", level: 12, petType: "Eagle", isOnline: true)
        ]
        
        return mockUsers.filter { $0.username.lowercased().contains(query.lowercased()) }
    }
}

struct UserSearchResult: Identifiable, Codable {
    let id: String
    let username: String
    let level: Int
    let petType: String
    let isOnline: Bool
}

struct UserSearchResultCard: View {
    let user: UserSearchResult
    let onChallenge: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(user.username.prefix(2).uppercased())
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.username)
                        .font(.headline)
                    
                    if user.isOnline {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text("Level \(user.level) • \(user.petType)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Challenge button
            Button(action: onChallenge) {
                Image(systemName: "sword")
                    .font(.title3)
                    .foregroundColor(.red)
                    .frame(width: 40, height: 40)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    UserSearchView { username in
        print("Challenge user: \(username)")
    }
}