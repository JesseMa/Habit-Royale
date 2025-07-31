import SwiftUI

struct HabitsView: View {
    @StateObject private var viewModel = HabitsViewModel()
    @State private var showCustomHabitCreator = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Standard habits section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Standard Gewohnheiten")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        StandardHabitCard(
                            title: "Schlaf",
                            icon: "moon.fill",
                            color: .purple,
                            target: viewModel.sleepGoal,
                            unit: "Stunden",
                            currentValue: viewModel.todaySleep,
                            onLog: { viewModel.showSleepLogger = true }
                        )
                        
                        StandardHabitCard(
                            title: "Sport",
                            icon: "figure.run",
                            color: .green,
                            target: viewModel.exerciseGoal,
                            unit: "Minuten",
                            currentValue: viewModel.todayExercise,
                            onLog: { viewModel.showExerciseLogger = true }
                        )
                        
                        StandardHabitCard(
                            title: "Bildschirmzeit",
                            icon: "iphone",
                            color: .orange,
                            target: viewModel.screenTimeGoal,
                            unit: "Stunden",
                            currentValue: viewModel.todayScreenTime,
                            onLog: { viewModel.showScreenTimeLogger = true }
                        )
                    }
                    
                    // Custom habits section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Eigene Gewohnheiten")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: { showCustomHabitCreator = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        if viewModel.customHabits.isEmpty {
                            EmptyCustomHabitsCard(onAdd: { showCustomHabitCreator = true })
                        } else {
                            ForEach(viewModel.customHabits) { habit in
                                CustomHabitCard(
                                    habit: habit,
                                    todayLog: viewModel.getTodayLog(for: habit.id ?? ""),
                                    onLog: { viewModel.showCustomHabitLogger(for: habit) },
                                    onDelete: { viewModel.deleteCustomHabit(habit) }
                                )
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Gewohnheiten")
            .background(Color.gray.opacity(0.1))
            .sheet(isPresented: $showCustomHabitCreator) {
                CustomHabitCreatorView()
            }
            .sheet(item: $viewModel.habitToLog) { habit in
                CustomHabitLoggerView(habit: habit)
            }
        }
    }
}

struct StandardHabitCard: View {
    let title: String
    let icon: String
    let color: Color
    let target: Double
    let unit: String
    let currentValue: Double
    let onLog: () -> Void
    
    var progress: Double {
        guard target > 0 else { return 0 }
        return min(currentValue / target, 1.0)
    }
    
    var isCompleted: Bool {
        currentValue >= target
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Icon and title
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                        .frame(width: 40, height: 40)
                        .background(color.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline)
                        
                        Text("\(Int(currentValue)) / \(Int(target)) \(unit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Log button
                Button(action: onLog) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "plus.circle")
                        .font(.title2)
                        .foregroundColor(isCompleted ? .green : .blue)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct CustomHabitCard: View {
    let habit: CustomHabit
    let todayLog: HabitLog?
    let onLog: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    var isCompleted: Bool {
        guard let log = todayLog else { return false }
        
        if habit.targetType == .yesno {
            return log.percentage >= 100
        } else {
            return (log.value ?? 0) >= habit.targetValue
        }
    }
    
    var progress: Double {
        guard let log = todayLog else { return 0 }
        
        if habit.targetType == .yesno {
            return log.percentage / 100
        } else {
            return min((log.value ?? 0) / habit.targetValue, 1.0)
        }
    }
    
    var effectColor: Color {
        switch habit.effect {
        case .attack: return .yellow
        case .defense: return .blue
        case .health: return .red
        case .experience: return .purple
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Habit info
                HStack(spacing: 12) {
                    Text(habit.emoji)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(effectColor.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(habit.name)
                            .font(.headline)
                        
                        HStack(spacing: 4) {
                            Text(habit.effect.emoji)
                                .font(.caption)
                            
                            Text("+\(habit.intensity.value)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(effectColor)
                        }
                    }
                }
                
                Spacer()
                
                // Actions
                HStack(spacing: 12) {
                    Button(action: onLog) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "plus.circle")
                            .font(.title2)
                            .foregroundColor(isCompleted ? .green : .blue)
                    }
                    
                    Menu {
                        Button(role: .destructive, action: { showDeleteAlert = true }) {
                            Label("Löschen", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Progress bar
            if habit.targetType == .numeric {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(Int(todayLog?.value ?? 0)) / \(Int(habit.targetValue)) \(habit.targetUnit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(progress * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(effectColor)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(effectColor)
                                .frame(width: geometry.size.width * progress, height: 8)
                                .animation(.easeInOut, value: progress)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .alert("Gewohnheit löschen?", isPresented: $showDeleteAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Löschen", role: .destructive) { onDelete() }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
        }
    }
}

struct EmptyCustomHabitsCard: View {
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle")
                .font(.system(size: 50))
                .foregroundColor(.blue.opacity(0.5))
            
            Text("Noch keine eigenen Gewohnheiten")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Erstelle deine eigenen Gewohnheiten und verbessere die Stats deines Pets!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onAdd) {
                Text("Gewohnheit erstellen")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}