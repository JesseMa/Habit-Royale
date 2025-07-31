import SwiftUI

struct AchievementsView: View {
    @StateObject private var viewModel = AchievementsViewModel()
    @State private var selectedCategory: Achievement.AchievementCategory? = nil
    @State private var searchText = ""
    
    var filteredAchievements: [Achievement] {
        var achievements = viewModel.achievements
        
        // Filter by category
        if let category = selectedCategory {
            achievements = achievements.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            achievements = achievements.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return achievements
    }
    
    var unlockedCount: Int {
        viewModel.userAchievements.count
    }
    
    var totalCount: Int {
        viewModel.achievements.count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress summary
            progressSummaryCard
            
            // Filters
            filtersSection
            
            // Achievements grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(filteredAchievements) { achievement in
                        AchievementCard(
                            achievement: achievement,
                            userAchievement: viewModel.getUserAchievement(for: achievement.id),
                            progress: viewModel.getProgress(for: achievement.id)
                        )
                    }
                }
                .padding()
            }
        }
        .searchable(text: $searchText, prompt: "Erfolge durchsuchen...")
        .onAppear {
            viewModel.loadAchievements()
        }
    }
    
    private var progressSummaryCard: some View {
        VStack(spacing: 12) {
            Text("Deine Erfolge")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(unlockedCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Freigeschaltet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(totalCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Gesamt")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * Double(unlockedCount) / Double(totalCount), height: 12)
                        .animation(.easeInOut, value: unlockedCount)
                }
            }
            .frame(height: 12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var filtersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All filter
                FilterChip(
                    title: "Alle",
                    isSelected: selectedCategory == nil,
                    color: .blue
                ) {
                    selectedCategory = nil
                }
                
                // Category filters
                ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.name,
                        isSelected: selectedCategory == category,
                        color: categoryColor(for: category)
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func categoryColor(for category: Achievement.AchievementCategory) -> Color {
        switch category {
        case .streak: return .orange
        case .completion: return .green
        case .level: return .purple
        case .special: return .yellow
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let userAchievement: UserAchievement?
    let progress: Int
    
    var isUnlocked: Bool {
        userAchievement != nil
    }
    
    var progressPercentage: Double {
        Double(progress) / Double(achievement.requirement)
    }
    
    var gradientColors: [Color] {
        let colors = achievement.category.gradientColors
        return colors.map { colorName in
            switch colorName {
            case "orange": return Color.orange
            case "red": return Color.red
            case "green": return Color.green
            case "blue": return Color.blue
            case "purple": return Color.purple
            case "pink": return Color.pink
            case "yellow": return Color.yellow
            default: return Color.gray
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isUnlocked ?
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 80)
                
                if isUnlocked {
                    // Achievement icon
                    Text(achievement.icon)
                        .font(.system(size: 40))
                } else {
                    // Locked icon with progress
                    VStack {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        if progress > 0 {
                            Text("\(progress)/\(achievement.requirement)")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            if !isUnlocked && progress > 0 {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(gradientColors.first ?? .blue)
                            .frame(width: geometry.size.width * progressPercentage, height: 4)
                            .animation(.easeInOut, value: progress)
                    }
                }
                .frame(height: 4)
            }
            
            if let unlockDate = userAchievement?.unlockedAt {
                Text(formatDate(unlockDate))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .scaleEffect(isUnlocked ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isUnlocked)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}