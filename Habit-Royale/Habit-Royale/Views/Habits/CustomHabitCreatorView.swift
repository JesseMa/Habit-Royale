import SwiftUI

struct CustomHabitCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var emoji = "⭐"
    @State private var description = ""
    @State private var targetType: CustomHabit.TargetType = .numeric
    @State private var targetValue: Double = 1
    @State private var targetUnit = ""
    @State private var effect: CustomHabit.PetEffect = .health
    @State private var intensity: CustomHabit.EffectIntensity = .medium
    @State private var isCreating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var isValid: Bool {
        !name.isEmpty && !emoji.isEmpty && (targetType == .yesno || !targetUnit.isEmpty)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Basic Info
                    basicInfoSection
                    
                    // Target Configuration
                    targetConfigSection
                    
                    // Pet Effects
                    petEffectsSection
                    
                    // Preview Card
                    previewSection
                }
                .padding()
            }
            .navigationTitle("Neue Gewohnheit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Erstellen") {
                        createHabit()
                    }
                    .disabled(!isValid || isCreating)
                }
            }
        }
        .alert("Fehler", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Grundinformationen")
                .font(.headline)
            
            HStack {
                TextField("Emoji", text: $emoji)
                    .frame(width: 60)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                
                TextField("Name der Gewohnheit", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            TextField("Beschreibung (optional)", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var targetConfigSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Zielvorgabe")
                .font(.headline)
            
            Picker("Typ", selection: $targetType) {
                Text("Messbar (mit Menge)").tag(CustomHabit.TargetType.numeric)
                Text("Ja/Nein").tag(CustomHabit.TargetType.yesno)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if targetType == .numeric {
                HStack {
                    Text("Zielwert:")
                    Spacer()
                    TextField("0", value: $targetValue, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Einheit", text: $targetUnit)
                        .frame(width: 100)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var petEffectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pet-Auswirkungen")
                .font(.headline)
            
            HStack {
                Text("Effekt-Typ:")
                Spacer()
                Picker("Effekt", selection: $effect) {
                    ForEach(CustomHabit.PetEffect.allCases, id: \.self) { effect in
                        HStack {
                            Text(effect.emoji)
                            Text(effect.rawValue)
                        }.tag(effect)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            HStack {
                Text("Intensität:")
                Spacer()
                Picker("Intensität", selection: $intensity) {
                    ForEach(CustomHabit.EffectIntensity.allCases, id: \.self) { intensity in
                        Text("\(intensity.rawValue) (+\(intensity.value))").tag(intensity)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vorschau")
                .font(.headline)
            
            HStack {
                Text(emoji)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Color.effectColor(for: effect).opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name.isEmpty ? "Gewohnheitsname" : name)
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Text(effect.emoji)
                            .font(.caption)
                        
                        Text("+\(intensity.value)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.effectColor(for: effect))
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func createHabit() {
        guard isValid else { return }
        
        isCreating = true
        
        Task {
            do {
                let habit = CustomHabit(
                    name: name,
                    emoji: emoji,
                    description: description,
                    targetType: targetType,
                    targetValue: targetValue,
                    targetUnit: targetUnit,
                    effect: effect,
                    intensity: intensity,
                    createdAt: Date(),
                    isActive: true
                )
                
                // Save to Firebase (implement in service)
                // try await HabitService.shared.createCustomHabit(habit)
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isCreating = false
                }
            }
        }
    }
}

#Preview {
    CustomHabitCreatorView()
}