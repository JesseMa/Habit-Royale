import SwiftUI

struct ProgressTrackingView: View {
    @StateObject private var viewModel = ProgressViewModel()
    @State private var selectedMonth = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress stats
                progressStatsSection
                
                // Weekly progress
                weeklyProgressSection
                
                // Calendar view
                calendarSection
            }
            .padding(.vertical)
        }
        .onAppear {
            viewModel.loadProgress()
        }
    }
    
    private var progressStatsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ProgressStatCard(
                    value: "\(viewModel.currentStreak)",
                    label: "Aktuelle Serie",
                    icon: "flame.fill",
                    color: .orange
                )
                
                ProgressStatCard(
                    value: "\(viewModel.longestStreak)",
                    label: "Beste Serie",
                    icon: "star.fill",
                    color: .yellow
                )
            }
            
            HStack(spacing: 16) {
                ProgressStatCard(
                    value: "\(viewModel.totalCompletions)",
                    label: "Gesamt-Abschlüsse",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                ProgressStatCard(
                    value: "\(viewModel.perfectDays)",
                    label: "Perfekte Tage",
                    icon: "sparkles",
                    color: .purple
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var weeklyProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wochenfortschritt")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                HStack {
                    Text("\(viewModel.weeklyCompletions) von \(viewModel.weeklyGoal) Habits abgeschlossen")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.weeklyProgress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * viewModel.weeklyProgress, height: 12)
                            .animation(.easeInOut, value: viewModel.weeklyProgress)
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
    }
    
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
                .disabled(isCurrentMonth)
            }
            .padding(.horizontal)
            
            // Calendar grid
            CalendarGridView(
                month: selectedMonth,
                calendarDays: viewModel.calendarDays
            )
            .padding(.horizontal)
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .month)
    }
    
    private func previousMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
        viewModel.loadCalendarData(for: selectedMonth)
    }
    
    private func nextMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
        viewModel.loadCalendarData(for: selectedMonth)
    }
}

struct ProgressStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct CalendarGridView: View {
    let month: Date
    let calendarDays: [String: CalendarDay]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    
    var body: some View {
        VStack(spacing: 8) {
            // Weekday headers
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }
            
            // Calendar days
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let dateString = date {
                        CalendarDayView(
                            date: dateString,
                            calendarDay: calendarDays[dateString]
                        )
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func getDaysInMonth() -> [String?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let numberOfDays = range.count
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leadingSpaces = (firstWeekday + 5) % 7 // Adjust for Monday start
        
        var days: [String?] = Array(repeating: nil, count: leadingSpaces)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(formatter.string(from: date))
            }
        }
        
        return days
    }
}

struct CalendarDayView: View {
    let date: String
    let calendarDay: CalendarDay?
    
    private var dayNumber: String {
        let components = date.split(separator: "-")
        return String(components.last ?? "")
    }
    
    private var backgroundColor: Color {
        guard let day = calendarDay else { return Color.gray.opacity(0.1) }
        
        switch day.completionColor {
        case "green": return Color.green.opacity(0.3)
        case "lightGreen": return Color.green.opacity(0.2)
        case "yellow": return Color.yellow.opacity(0.3)
        case "orange": return Color.orange.opacity(0.3)
        case "red": return Color.red.opacity(0.3)
        default: return Color.gray.opacity(0.1)
        }
    }
    
    private var isToday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return date == formatter.string(from: Date())
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(dayNumber)
                .font(.caption)
                .fontWeight(isToday ? .bold : .regular)
            
            if let streak = calendarDay?.streak, streak > 0 {
                Text("🔥")
                    .font(.caption2)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .background(backgroundColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}