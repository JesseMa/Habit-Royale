import SwiftUI

struct CustomHabitsSettingsView: View {
    @StateObject private var viewModel = CustomHabitsSettingsViewModel()
    @State private var showHabitCreator = false
    @State private var selectedHabit: CustomHabit?
    @State private var showDeleteAlert = false
    @State private var habitToDelete: CustomHabit?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header section
                headerSection
                
                // Habits list
                if viewModel.customHabits.isEmpty {
                    emptyStateView
                } else {
                    habitsListSection
                }
                
                // Statistics section
                if !viewModel.customHabits.isEmpty {
                    statisticsSection
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Eigene Gewohnheiten")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showHabitCreator = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showHabitCreator) {
            CustomHabitCreatorView()
        }
        .sheet(item: $selectedHabit) { habit in
            CustomHabitEditorView(habit: habit)
        }
        .alert("Gewohnheit löschen?", isPresented: $showDeleteAlert) {
            Button("Abbrechen", role: .cancel) {
                habitToDelete = nil
            }
            Button("Löschen", role: .destructive) {
                if let habit = habitToDelete {
                    viewModel.deleteHabit(habit)
                    habitToDelete = nil
                }
            }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden. Alle Logs dieser Gewohnheit werden ebenfalls gelöscht.")
        }
        .onAppear {
            viewModel.loadCustomHabits()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Eigene Gewohnheiten verwalten")
                .font(.headline)
            
            Text("Erstelle und verwalte deine individuellen Gewohnheiten. Jede Gewohnheit kann verschiedene Auswirkungen auf dein Pet haben.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Add habit button
            Button(action: { showHabitCreator = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    
                    Text("Neue Gewohnheit erstellen")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "plus.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Noch keine eigenen Gewohnheiten")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("Erstelle deine erste eigene Gewohnheit und verbessere die Stats deines Pets!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Jetzt erstellen") {
                showHabitCreator = true
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var habitsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Deine Gewohnheiten (\(viewModel.customHabits.count))")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(viewModel.customHabits) { habit in
                CustomHabitSettingsCard(
                    habit: habit,
                    onEdit: { selectedHabit = habit },
                    onDelete: {
                        habitToDelete = habit
                        showDeleteAlert = true
                    },
                    onToggleActive: { viewModel.toggleHabitActive(habit) }
                )
            }
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistiken")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                StatisticCard(
                    title: "Aktive Gewohnheiten",
                    value: "\(viewModel.activeHabitsCount)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatisticCard(
                    title: "Gesamt erstellt",
                    value: "\(viewModel.customHabits.count)",
                    icon: "plus.circle.fill",
                    color: .blue
                )
            }
            .padding(.horizontal)
            
            // Effect distribution
            EffectDistributionView(habits: viewModel.customHabits)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct CustomHabitSettingsCard: View {
    let habit: CustomHabit
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleActive: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Habit info
                HStack(spacing: 12) {
                    Text(habit.emoji)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(Color.effectColor(for: habit.effect).opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.name)
                            .font(.headline)
                            .foregroundColor(habit.isActive ? .primary : .secondary)
                        
                        HStack(spacing: 8) {
                            Text(habit.effect.emoji)
                                .font(.caption)
                            
                            Text(habit.effect.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(habit.intensity.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.effectColor(for: habit.effect).opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                // Active toggle
                Toggle("", isOn: Binding(
                    get: { habit.isActive },
                    set: { _ in onToggleActive() }
                ))
                .toggleStyle(SwitchToggleStyle())
            }
            
            // Target info
            if habit.targetType == .numeric {
                Text("Ziel: \(Int(habit.targetValue)) \(habit.targetUnit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button("Bearbeiten") {
                    onEdit()
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
                
                Button("Löschen") {
                    onDelete()
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(8)
                
                Spacer()
                
                Text("Erstellt: \(habit.createdAt.formatForDisplay())")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(habit.isActive ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .opacity(habit.isActive ? 1.0 : 0.6)
        .padding(.horizontal)
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct EffectDistributionView: View {
    let habits: [CustomHabit]
    
    private var effectCounts: [CustomHabit.PetEffect: Int] {
        var counts: [CustomHabit.PetEffect: Int] = [:]
        for habit in habits.filter({ $0.isActive }) {
            counts[habit.effect, default: 0] += 1
        }
        return counts
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Effekt-Verteilung")
                .font(.subheadline)
                .fontWeight(.medium)
            
            if effectCounts.isEmpty {
                Text("Keine aktiven Gewohnheiten")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(CustomHabit.PetEffect.allCases, id: \.self) { effect in
                        if let count = effectCounts[effect], count > 0 {
                            HStack {
                                HStack(spacing: 8) {
                                    Text(effect.emoji)
                                    Text(effect.rawValue)
                                        .font(.caption)
                                }
                                
                                Spacer()
                                
                                Text("\(count)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.effectColor(for: effect).opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

// ViewModel
class CustomHabitsSettingsViewModel: ObservableObject {
    @Published var customHabits: [CustomHabit] = []
    @Published var isLoading = false
    
    var activeHabitsCount: Int {
        customHabits.filter { $0.isActive }.count
    }
    
    func loadCustomHabits() {
        // Load custom habits from Firebase
        // For now, using mock data
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.customHabits = self.createMockHabits()
            self.isLoading = false
        }
    }
    
    func toggleHabitActive(_ habit: CustomHabit) {
        // Toggle habit active state in Firebase
        if let index = customHabits.firstIndex(where: { $0.id == habit.id }) {
            customHabits[index] = CustomHabit(
                name: habit.name,
                emoji: habit.emoji,
                description: habit.description,
                targetType: habit.targetType,
                targetValue: habit.targetValue,
                targetUnit: habit.targetUnit,
                effect: habit.effect,
                intensity: habit.intensity,
                createdAt: habit.createdAt,
                isActive: !habit.isActive
            )
        }
    }
    
    func deleteHabit(_ habit: CustomHabit) {
        // Delete habit from Firebase
        customHabits.removeAll { $0.id == habit.id }
    }
    
    private func createMockHabits() -> [CustomHabit] {
        [
            CustomHabit(
                name: "Lesen",
                emoji: "📚",
                description: "Täglich lesen",
                targetType: .numeric,
                targetValue: 30,
                targetUnit: "Minuten",
                effect: .experience,
                intensity: .medium,
                createdAt: Date().addingTimeInterval(-86400 * 7),
                isActive: true
            ),
            CustomHabit(
                name: "Meditation",
                emoji: "🧘‍♂️",
                description: "Tägliche Meditation",
                targetType: .numeric,
                targetValue: 10,
                targetUnit: "Minuten",
                effect: .defense,
                intensity: .light,
                createdAt: Date().addingTimeInterval(-86400 * 3),
                isActive: true
            )
        ]
    }
}

// Placeholder for CustomHabitEditorView
struct CustomHabitEditorView: View {
    let habit: CustomHabit
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Habit Editor for \(habit.name)")
                .navigationTitle("Gewohnheit bearbeiten")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Fertig") { dismiss() }
                    }
                }
        }
    }
}

#Preview {
    NavigationView {
        CustomHabitsSettingsView()
    }
}