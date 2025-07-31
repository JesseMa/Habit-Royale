import Foundation

extension Date {
    
    // MARK: - Formatting
    
    func formatForDisplay() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    func formatForAPI() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    func formatForHabitLog() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self)
    }
    
    func formatTimeOnly() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    func formatRelative() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    // MARK: - Calendar Operations
    
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay()) ?? self
    }
    
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        guard let startOfMonth = startOfMonth(),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return self
        }
        return endOfMonth
    }
    
    // MARK: - Comparison
    
    func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func isSameWeek(as date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    
    func isSameMonth(as date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }
    
    func isToday() -> Bool {
        return isSameDay(as: Date())
    }
    
    func isYesterday() -> Bool {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            return false
        }
        return isSameDay(as: yesterday)
    }
    
    func isTomorrow() -> Bool {
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {
            return false
        }
        return isSameDay(as: tomorrow)
    }
    
    func isWithinLastWeek() -> Bool {
        guard let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return false
        }
        return self >= lastWeek
    }
    
    func isWithinLastMonth() -> Bool {
        guard let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else {
            return false
        }
        return self >= lastMonth
    }
    
    // MARK: - Age Calculation
    
    func daysSince() -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    }
    
    func weeksSince() -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
    }
    
    func monthsSince() -> Int {
        return Calendar.current.dateComponents([.month], from: self, to: Date()).month ?? 0
    }
    
    // MARK: - Adding/Subtracting
    
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func adding(weeks: Int) -> Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }
    
    func adding(months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    func subtracting(days: Int) -> Date {
        return adding(days: -days)
    }
    
    func subtracting(weeks: Int) -> Date {
        return adding(weeks: -weeks)
    }
    
    func subtracting(months: Int) -> Date {
        return adding(months: -months)
    }
    
    // MARK: - Time Components
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    // MARK: - Streak Calculations
    
    static func calculateStreak(from dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        let sortedDates = dates.sorted(by: >)
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date().startOfDay()
        
        for date in sortedDates {
            let dateStart = date.startOfDay()
            
            if calendar.isDate(dateStart, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if dateStart < currentDate {
                break
            }
        }
        
        return streak
    }
    
    // MARK: - Habit Logging
    
    func isValidForHabitLogging() -> Bool {
        // Allow logging for today and yesterday
        let calendar = Calendar.current
        let today = Date().startOfDay()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let dateStart = self.startOfDay()
        
        return dateStart >= yesterday && dateStart <= today
    }
}

// MARK: - Static Helpers

extension Date {
    
    static func datesInCurrentWeek() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return []
        }
        
        var dates: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                dates.append(date)
            }
        }
        return dates
    }
    
    static func datesInCurrentMonth() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let startOfMonth = today.startOfMonth()
        let range = calendar.range(of: .day, in: .month, for: startOfMonth) ?? 1..<32
        
        var dates: [Date] = []
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(date)
            }
        }
        return dates
    }
}