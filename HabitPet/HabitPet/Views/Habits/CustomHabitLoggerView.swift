import SwiftUI

struct CustomHabitLoggerView: View {
    let habit: CustomHabit
    @Environment(\.dismiss) private var dismiss
    @State private var value: Double = 0
    @State private var percentage: Double = 100
    @State private var notes = ""
    @State private var isLogging = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Habit Info
                    habitInfoSection
                    
                    // Input Section
                    inputSection
                    
                    // Preview Section
                    previewSection
                }
                .padding()
            }
            .navigationTitle("Habit loggen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        logHabit()
                    }
                    .disabled(isLogging)
                }
            }
        }
        .alert("Fehler", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var habitInfoSection: some View {
        HStack {
            Text(habit.emoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(Color.effectColor(for: habit.effect).opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(habit.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Text(habit.effect.emoji)
                        .font(.caption)
                    
                    Text("+\(habit.intensity.value)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.effectColor(for: habit.effect))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Heute's Fortschritt")
                .font(.headline)
            
            if habit.targetType == .numeric {
                numericInputView
            } else {
                yesNoInputView
            }
            
            // Notes
            VStack(alignment: .leading, spacing: 8) {
                Text("Notizen (optional)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Deine Gedanken zu heute...", text: $notes, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var numericInputView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Wert:")
                Spacer()
                TextField("0", value: $value, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(width: 80)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text(habit.targetUnit)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Ziel: \(Int(habit.targetValue)) \(habit.targetUnit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(min(value / habit.targetValue * 100, 100)))% erreicht")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.effectColor(for: habit.effect))
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.effectColor(for: habit.effect))
                        .frame(width: geometry.size.width * min(value / habit.targetValue, 1.0), height: 8)
                        .animation(.easeInOut, value: value)
                }
            }
            .frame(height: 8)
        }
    }
    
    private var yesNoInputView: some View {
        VStack(spacing: 12) {
            Text("Wie gut hast du dich heute geschlagen?")
                .font(.subheadline)
            
            Slider(value: $percentage, in: 0...100, step: 10)
                .accentColor(Color.effectColor(for: habit.effect))
            
            HStack {
                Text("0%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(percentage))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.effectColor(for: habit.effect))
                
                Spacer()
                
                Text("100%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Description labels
            HStack {
                Text("Garnicht")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Perfekt")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pet-Belohnung")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(habit.effect.emoji + " " + habit.effect.rawValue.capitalized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    let effectValue = calculateEffectValue()
                    Text("+\(effectValue) Punkte")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.effectColor(for: habit.effect))
                }
                
                Spacer()
                
                if calculateEffectValue() > 0 {
                    Text("🎉")
                        .font(.system(size: 30))
                }
            }
            .padding()
            .background(Color.effectColor(for: habit.effect).opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func calculateEffectValue() -> Int {
        let progress = habit.targetType == .numeric ? 
            min(value / habit.targetValue, 1.0) : 
            percentage / 100.0
        
        return Int(Double(habit.intensity.value) * progress)
    }
    
    private func logHabit() {
        isLogging = true
        
        Task {
            do {
                let log = HabitLog(
                    habitId: habit.id ?? "",
                    habitType: .custom,
                    date: Date(),
                    value: habit.targetType == .numeric ? value : nil,
                    percentage: habit.targetType == .numeric ? min(value / habit.targetValue * 100, 100) : percentage,
                    notes: notes.isEmpty ? nil : notes,
                    createdAt: Date()
                )
                
                // Save to Firebase and update pet stats
                // try await HabitService.shared.logCustomHabit(log, effectValue: calculateEffectValue())
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLogging = false
                }
            }
        }
    }
}

#Preview {
    CustomHabitLoggerView(habit: CustomHabit(
        name: "Lesen",
        emoji: "📚",
        description: "30 Minuten lesen",
        targetType: .numeric,
        targetValue: 30,
        targetUnit: "Minuten",
        effect: .experience,
        intensity: .medium,
        createdAt: Date(),
        isActive: true
    ))
}