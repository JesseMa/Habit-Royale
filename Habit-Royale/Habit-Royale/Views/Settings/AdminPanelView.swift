import SwiftUI

struct AdminPanelView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var selectedTab = 0
    
    var userRole: User.UserRole {
        userManager.currentUser?.role ?? .user
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab selector based on role
            if userRole == .admin {
                adminTabSelector
            } else {
                roleBasedTabSelector
            }
            
            // Content
            TabView(selection: $selectedTab) {
                if userRole == .petCreator || userRole == .admin {
                    PetCreatorView()
                        .tag(0)
                }
                
                if userRole == .petManager || userRole == .admin {
                    PetManagerView()
                        .tag(userRole == .admin ? 1 : 0)
                }
                
                if userRole == .admin {
                    UserManagementView()
                        .tag(2)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("Admin Panel")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var adminTabSelector: some View {
        Picker("Admin", selection: $selectedTab) {
            Text("Pets erstellen").tag(0)
            Text("Pets verwalten").tag(1)
            Text("Benutzer").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    private var roleBasedTabSelector: some View {
        Group {
            if userRole == .petCreator {
                Text("Pet Creator")
                    .font(.headline)
                    .padding()
            } else if userRole == .petManager {
                Text("Pet Manager")
                    .font(.headline)
                    .padding()
            }
        }
    }
}

struct PetCreatorView: View {
    @State private var currentStep = 1
    @State private var petData = PetCreationData()
    @State private var isCreating = false
    @State private var showSuccess = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress indicator
                progressIndicator
                
                // Content based on step
                switch currentStep {
                case 1:
                    basicInfoStep
                case 2:
                    evolutionStep
                case 3:
                    previewStep
                default:
                    basicInfoStep
                }
                
                // Navigation buttons
                navigationButtons
            }
            .padding()
        }
        .alert("Pet erstellt!", isPresented: $showSuccess) {
            Button("OK") {
                resetForm()
            }
        } message: {
            Text("Das neue Pet wurde erfolgreich erstellt und ist jetzt verfügbar.")
        }
    }
    
    private var progressIndicator: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(1...3, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                    
                    if step < 3 {
                        Rectangle()
                            .fill(step < currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                    }
                }
            }
            
            Text("Schritt \(currentStep) von 3")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var basicInfoStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Grundinformationen")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Pet-Name")
                    .font(.headline)
                TextField("z.B. Feuertiger", text: $petData.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Pet-Typ")
                    .font(.headline)
                TextField("z.B. FIRE_TIGER", text: $petData.type)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Beschreibung")
                    .font(.headline)
                TextField("Beschreibung des Pets...", text: $petData.description, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Kategorie")
                    .font(.headline)
                Picker("Kategorie", selection: $petData.category) {
                    ForEach(PetTemplate.PetCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Basis-Stats")
                    .font(.headline)
                
                HStack {
                    Text("Gesundheit:")
                    Spacer()
                    TextField("100", value: $petData.baseHealth, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                
                HStack {
                    Text("Angriff:")
                    Spacer()
                    TextField("10", value: $petData.baseAttack, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                
                HStack {
                    Text("Freischaltung Level:")
                    Spacer()
                    TextField("1", value: $petData.unlockLevel, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var evolutionStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Evolution-Stufen")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Definiere die verschiedenen Entwicklungsstufen deines Pets")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(Array(petData.evolutions.enumerated()), id: \.offset) { index, evolution in
                EvolutionStepEditor(
                    evolution: Binding(
                        get: { petData.evolutions[index] },
                        set: { petData.evolutions[index] = $0 }
                    ),
                    onRemove: {
                        petData.evolutions.remove(at: index)
                    }
                )
            }
            
            Button("Evolution hinzufügen") {
                petData.evolutions.append(PetEvolution(name: "", minLevel: 0, maxLevel: 0))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var previewStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vorschau")
                .font(.title2)
                .fontWeight(.bold)
            
            PetPreviewCard(petData: petData)
            
            Text("Überprüfe alle Eingaben vor der Erstellung.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 1 {
                Button("Zurück") {
                    currentStep -= 1
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            
            if currentStep < 3 {
                Button("Weiter") {
                    currentStep += 1
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canProceed ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(!canProceed)
            } else {
                Button("Pet erstellen") {
                    createPet()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canProceed ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(!canProceed || isCreating)
            }
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 1:
            return !petData.name.isEmpty && !petData.type.isEmpty
        case 2:
            return !petData.evolutions.isEmpty
        case 3:
            return true
        default:
            return false
        }
    }
    
    private func createPet() {
        isCreating = true
        
        Task {
            do {
                // Create pet template in Firebase
                try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate creation
                
                await MainActor.run {
                    showSuccess = true
                    isCreating = false
                }
            } catch {
                await MainActor.run {
                    isCreating = false
                }
            }
        }
    }
    
    private func resetForm() {
        currentStep = 1
        petData = PetCreationData()
    }
}

struct PetManagerView: View {
    @State private var pets: [PetTemplate] = []
    @State private var searchText = ""
    @State private var selectedCategory: PetTemplate.PetCategory?
    @State private var showActiveOnly = false
    
    var filteredPets: [PetTemplate] {
        pets.filter { pet in
            let matchesSearch = searchText.isEmpty || 
                pet.name.localizedCaseInsensitiveContains(searchText) ||
                pet.type.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == nil || pet.category == selectedCategory
            let matchesActive = !showActiveOnly || pet.isVisible
            
            return matchesSearch && matchesCategory && matchesActive
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Filters
            filtersSection
            
            // Pets list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredPets) { pet in
                        PetManagementCard(
                            pet: pet,
                            onToggleVisibility: { togglePetVisibility(pet) },
                            onEdit: { editPet(pet) },
                            onDelete: { deletePet(pet) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            loadPets()
        }
    }
    
    private var filtersSection: some View {
        VStack(spacing: 12) {
            // Search
            TextField("Pet suchen...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Filters
            HStack {
                Picker("Kategorie", selection: $selectedCategory) {
                    Text("Alle").tag(nil as PetTemplate.PetCategory?)
                    ForEach(PetTemplate.PetCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category as PetTemplate.PetCategory?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Spacer()
                
                Toggle("Nur aktive", isOn: $showActiveOnly)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func loadPets() {
        // Load pets from Firebase
        pets = createMockPets()
    }
    
    private func togglePetVisibility(_ pet: PetTemplate) {
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[index] = PetTemplate(
                name: pet.name,
                type: pet.type,
                description: pet.description,
                category: pet.category,
                baseHealth: pet.baseHealth,
                baseAttack: pet.baseAttack,
                baseDefense: pet.baseDefense,
                unlockLevel: pet.unlockLevel,
                evolutions: pet.evolutions,
                isVisible: !pet.isVisible,
                createdBy: pet.createdBy
            )
        }
    }
    
    private func editPet(_ pet: PetTemplate) {
        // Navigate to edit view
    }
    
    private func deletePet(_ pet: PetTemplate) {
        pets.removeAll { $0.id == pet.id }
    }
    
    private func createMockPets() -> [PetTemplate] {
        [
            PetTemplate(
                name: "Feuertiger",
                type: "FIRE_TIGER",
                description: "Ein mächtiger Feuertiger",
                category: .rare,
                baseHealth: 100,
                baseAttack: 15,
                baseDefense: 10,
                unlockLevel: 1,
                evolutions: [],
                isVisible: true,
                createdBy: "admin"
            ),
            PetTemplate(
                name: "Wasserwolf",
                type: "WATER_WOLF",
                description: "Ein mystischer Wasserwolf",
                category: .epic,
                baseHealth: 120,
                baseAttack: 12,
                baseDefense: 15,
                unlockLevel: 5,
                evolutions: [],
                isVisible: false,
                createdBy: "admin"
            )
        ]
    }
}

struct UserManagementView: View {
    var body: some View {
        VStack {
            Text("User Management")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Hier können Administratoren Benutzerrollen verwalten")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

// Supporting structs and views
struct PetCreationData {
    var name = ""
    var type = ""
    var description = ""
    var category: PetTemplate.PetCategory = .common
    var baseHealth = 100
    var baseAttack = 10
    var unlockLevel = 1
    var evolutions: [PetEvolution] = []
}

struct EvolutionStepEditor: View {
    @Binding var evolution: PetEvolution
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Evolution")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button("Entfernen") {
                    onRemove()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            
            TextField("Name", text: $evolution.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                TextField("Min Level", value: $evolution.minLevel, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Max Level", value: $evolution.maxLevel, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct PetPreviewCard: View {
    let petData: PetCreationData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(petData.name)
                    .font(.headline)
                
                Spacer()
                
                Text(petData.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.categoryColor(for: petData.category).opacity(0.2))
                    .cornerRadius(4)
            }
            
            Text(petData.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Health: \(petData.baseHealth)")
                Text("Attack: \(petData.baseAttack)")
                Text("Unlock Level: \(petData.unlockLevel)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Text("Evolutionen: \(petData.evolutions.count)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct PetManagementCard: View {
    let pet: PetTemplate
    let onToggleVisibility: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pet.name)
                        .font(.headline)
                    
                    Text(pet.type)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: onToggleVisibility) {
                        Image(systemName: pet.isVisible ? "eye" : "eye.slash")
                            .foregroundColor(pet.isVisible ? .green : .gray)
                    }
                    
                    Button("Bearbeiten", action: onEdit)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                    
                    Button("Löschen", action: onDelete)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                }
            }
            
            Text(pet.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .opacity(pet.isVisible ? 1.0 : 0.6)
    }
}

#Preview {
    NavigationView {
        AdminPanelView()
            .environmentObject(UserManager.shared)
    }
}