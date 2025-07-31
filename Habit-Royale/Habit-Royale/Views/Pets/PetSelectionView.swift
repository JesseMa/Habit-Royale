import SwiftUI

struct PetSelectionView: View {
    @State private var selectedPets: [PetTemplate] = []
    @State private var selectedPet: PetTemplate?
    @State private var petName = ""
    @State private var showNameInput = false
    @State private var isLoading = true
    
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = PetSelectionViewModel()
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Pets werden geladen...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            } else {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Wähle dein erstes Pet!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Dein treuer Begleiter auf deiner Reise")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Pet selection grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(selectedPets) { pet in
                                PetSelectionCard(pet: pet, isSelected: selectedPet?.id == pet.id)
                                    .onTapGesture {
                                        selectedPet = pet
                                    }
                            }
                        }
                        .padding()
                    }
                    
                    // Continue button
                    Button(action: {
                        if selectedPet != nil {
                            showNameInput = true
                        }
                    }) {
                        Text("Weiter")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(selectedPet != nil ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(selectedPet == nil)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showNameInput) {
            PetNameInputView(
                pet: selectedPet!,
                petName: $petName,
                onConfirm: createPet
            )
        }
        .onAppear {
            loadRandomPets()
        }
    }
    
    private func loadRandomPets() {
        Task {
            await viewModel.loadRandomPets(count: 3)
            selectedPets = viewModel.availablePets
            isLoading = false
        }
    }
    
    private func createPet() {
        guard let pet = selectedPet, !petName.isEmpty else { return }
        
        Task {
            do {
                try await userManager.createPet(
                    templateId: pet.id ?? "",
                    name: petName,
                    slotIndex: 0
                )
            } catch {
                print("Error creating pet: \(error)")
            }
        }
    }
}

struct PetSelectionCard: View {
    let pet: PetTemplate
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Pet image placeholder
            ZStack {
                Circle()
                    .fill(categoryGradient)
                    .frame(width: 80, height: 80)
                
                Text("🐾")
                    .font(.system(size: 40))
            }
            
            Text(pet.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            // Category badge
            Text(pet.category.rawValue)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(categoryColor.opacity(0.2))
                .foregroundColor(categoryColor)
                .cornerRadius(4)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
    
    private var categoryColor: Color {
        switch pet.category {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .yellow
        }
    }
    
    private var categoryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [categoryColor.opacity(0.3), categoryColor.opacity(0.5)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct PetNameInputView: View {
    let pet: PetTemplate
    @Binding var petName: String
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Pet preview
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Text("🐾")
                            .font(.system(size: 60))
                    }
                    
                    Text(pet.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                // Name input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gib deinem Pet einen Namen:")
                        .font(.headline)
                    
                    TextField("Name eingeben...", text: $petName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title3)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Confirm button
                Button(action: {
                    onConfirm()
                    dismiss()
                }) {
                    Text("Pet erstellen")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(petName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(petName.isEmpty)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("Pet benennen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }
}