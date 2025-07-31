import SwiftUI

struct PetsView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showPetSelector = false
    @State private var selectedSlot: Int?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Pet slots grid
                    ForEach(0..<3) { slot in
                        PetSlotView(
                            slot: slot,
                            pet: getPet(at: slot),
                            isUnlocked: slot < userManager.unlockedSlots,
                            isActive: getPet(at: slot)?.isActive ?? false,
                            onTap: {
                                handleSlotTap(slot: slot)
                            }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Meine Pets")
            .background(Color.gray.opacity(0.1))
        }
        .sheet(isPresented: $showPetSelector) {
            if let slot = selectedSlot {
                PetSelectorView(slotIndex: slot)
            }
        }
    }
    
    private func getPet(at slot: Int) -> Pet? {
        userManager.pets.first { $0.slotIndex == slot }
    }
    
    private func handleSlotTap(slot: Int) {
        if slot >= userManager.unlockedSlots {
            // Show unlock requirement
            return
        }
        
        if let pet = getPet(at: slot) {
            // Set as active pet
            Task {
                try? await userManager.setActivePet(petId: pet.id ?? "")
            }
        } else {
            // Show pet selector
            selectedSlot = slot
            showPetSelector = true
        }
    }
}

struct PetSlotView: View {
    let slot: Int
    let pet: Pet?
    let isUnlocked: Bool
    let isActive: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                if !isUnlocked {
                    // Locked slot
                    lockedSlotView
                } else if let pet = pet {
                    // Pet card
                    petCardView(pet: pet)
                } else {
                    // Empty slot
                    emptySlotView
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(backgroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: isActive ? 3 : 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var lockedSlotView: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Slot \(slot + 1)")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Level \(slot == 1 ? 5 : 10) benötigt")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func petCardView(pet: Pet) -> some View {
        VStack(spacing: 12) {
            // Active indicator
            if isActive {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text("Aktiv")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(20)
            }
            
            // Pet image
            Text(pet.evolution.emoji)
                .font(.system(size: 50))
            
            // Pet info
            VStack(spacing: 4) {
                Text(pet.name)
                    .font(.headline)
                
                Text("Level \(pet.level) • \(pet.evolution.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Health bar
            HealthBarView(
                current: pet.health,
                max: pet.maxHealth,
                showLabel: true
            )
            .padding(.horizontal)
        }
    }
    
    private var emptySlotView: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Pet hinzufügen")
                .font(.headline)
                .foregroundColor(.blue)
        }
    }
    
    private var backgroundColor: Color {
        if !isUnlocked {
            return Color.gray.opacity(0.2)
        } else if pet != nil {
            return Color.white
        } else {
            return Color.blue.opacity(0.05)
        }
    }
    
    private var borderColor: Color {
        if isActive {
            return Color.red
        } else if !isUnlocked {
            return Color.gray.opacity(0.3)
        } else {
            return Color.clear
        }
    }
}

struct HealthBarView: View {
    let current: Int
    let max: Int
    let showLabel: Bool
    
    var healthPercentage: Double {
        Double(current) / Double(max)
    }
    
    var healthColor: Color {
        if healthPercentage > 0.6 {
            return .green
        } else if healthPercentage > 0.3 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if showLabel {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    
                    Text("\(current)/\(max) HP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(healthColor)
                        .frame(width: geometry.size.width * healthPercentage, height: 8)
                        .animation(.easeInOut, value: current)
                }
            }
            .frame(height: 8)
        }
    }
}

struct PetSelectorView: View {
    let slotIndex: Int
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PetSelectionViewModel()
    @State private var selectedPet: PetTemplate?
    @State private var petName = ""
    @State private var showNameInput = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Pets werden geladen...")
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(viewModel.availablePets) { pet in
                                PetSelectionCard(
                                    pet: pet,
                                    isSelected: selectedPet?.id == pet.id
                                )
                                .onTapGesture {
                                    selectedPet = pet
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Button(action: {
                        if selectedPet != nil {
                            showNameInput = true
                        }
                    }) {
                        Text("Auswählen")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(selectedPet != nil ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(selectedPet == nil)
                    .padding()
                }
            }
            .navigationTitle("Pet auswählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadRandomPets(count: 6)
            }
        }
        .sheet(isPresented: $showNameInput) {
            if let pet = selectedPet {
                PetNameInputView(
                    pet: pet,
                    petName: $petName,
                    onConfirm: {
                        createPet()
                    }
                )
            }
        }
    }
    
    private func createPet() {
        guard let pet = selectedPet, !petName.isEmpty else { return }
        
        Task {
            do {
                try await UserManager.shared.createPet(
                    templateId: pet.id ?? "",
                    name: petName,
                    slotIndex: slotIndex
                )
                dismiss()
            } catch {
                print("Error creating pet: \(error)")
            }
        }
    }
}