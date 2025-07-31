import SwiftUI

struct BattleRatingView: View {
    let battle: Battle
    let onComplete: ([Int]) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentQuestionIndex = 0
    @State private var ratings: [Int] = []
    @State private var currentRating = 5
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private var currentQuestion: BattleQuestion {
        battle.questions[currentQuestionIndex]
    }
    
    private var isLastQuestion: Bool {
        currentQuestionIndex == battle.questions.count - 1
    }
    
    private var canProceed: Bool {
        currentRating >= 1 && currentRating <= 10
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                
                // Question content
                ScrollView {
                    VStack(spacing: 24) {
                        // Question header
                        questionHeader
                        
                        // Rating section
                        ratingSection
                        
                        // Explanation
                        explanationSection
                    }
                    .padding()
                }
                
                // Navigation buttons
                navigationButtons
            }
            .navigationTitle("Battle Bewertung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
        .alert("Fehler", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            setupInitialState()
        }
    }
    
    private var progressIndicator: some View {
        VStack(spacing: 8) {
            // Progress bar
            HStack {
                ForEach(0..<battle.questions.count, id: \.self) { index in
                    Rectangle()
                        .fill(index <= currentQuestionIndex ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .animation(.easeInOut, value: currentQuestionIndex)
                }
            }
            
            // Progress text
            Text("Frage \(currentQuestionIndex + 1) von \(battle.questions.count)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var questionHeader: some View {
        VStack(spacing: 16) {
            // Question icon and category
            VStack(spacing: 8) {
                Text(currentQuestion.icon)
                    .font(.system(size: 60))
                
                Text(currentQuestion.category.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(categoryColor.opacity(0.2))
                    .foregroundColor(categoryColor)
                    .cornerRadius(12)
            }
            
            // Question text
            Text(currentQuestion.question)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            if let description = currentQuestion.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var ratingSection: some View {
        VStack(spacing: 20) {
            // Current rating display
            VStack(spacing: 8) {
                Text("\(currentRating)")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(ratingColor)
                    .animation(.spring(response: 0.3), value: currentRating)
                
                Text(ratingLabel)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(ratingColor)
                    .animation(.easeInOut, value: currentRating)
            }
            
            // Rating slider
            VStack(spacing: 12) {
                Slider(value: Binding(
                    get: { Double(currentRating) },
                    set: { currentRating = Int($0.rounded()) }
                ), in: 1...10, step: 1)
                .accentColor(ratingColor)
                
                // Scale labels
                HStack {
                    VStack {
                        Text("1")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(currentQuestion.positiveWeighting ? "Sehr schlecht" : "Perfekt")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("10")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(currentQuestion.positiveWeighting ? "Perfekt" : "Sehr schlecht")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Quick rating buttons
            HStack(spacing: 8) {
                ForEach(1...10, id: \.self) { rating in
                    Button("\(rating)") {
                        currentRating = rating
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(width: 28, height: 28)
                    .background(currentRating == rating ? ratingColor : Color.gray.opacity(0.2))
                    .foregroundColor(currentRating == rating ? .white : .primary)
                    .clipShape(Circle())
                    .animation(.spring(response: 0.2), value: currentRating)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bewertungshilfe")
                .font(.headline)
            
            Text("Denke an die letzten 3 Tage zurück und bewerte ehrlich, wie gut du in diesem Bereich warst.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !currentQuestion.positiveWeighting {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.orange)
                    
                    Text("Bei dieser Frage ist weniger besser! (1 = perfekt, 10 = sehr schlecht)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var navigationButtons: some View {
        VStack(spacing: 12) {
            if isLastQuestion {
                // Submit button
                Button(action: submitRatings) {
                    if isSubmitting {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text("Wird übermittelt...")
                        }
                    } else {
                        Text("Bewertung abschließen")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(canProceed ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(!canProceed || isSubmitting)
            } else {
                // Next button
                Button("Nächste Frage") {
                    nextQuestion()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(canProceed ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(!canProceed)
            }
            
            // Back button (if not first question)
            if currentQuestionIndex > 0 {
                Button("Zurück") {
                    previousQuestion()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.gray.opacity(0.1))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    private var categoryColor: Color {
        switch currentQuestion.category {
        case .health: return .green
        case .relationships: return .pink
        case .spirituality: return .purple
        case .productivity: return .orange
        case .habits: return .blue
        }
    }
    
    private var ratingColor: Color {
        let normalizedRating = currentQuestion.positiveWeighting ? currentRating : (11 - currentRating)
        
        switch normalizedRating {
        case 1...3: return .red
        case 4...6: return .orange
        case 7...8: return .yellow
        case 9...10: return .green
        default: return .gray
        }
    }
    
    private var ratingLabel: String {
        let normalizedRating = currentQuestion.positiveWeighting ? currentRating : (11 - currentRating)
        
        switch normalizedRating {
        case 1...2: return "Sehr schlecht"
        case 3...4: return "Schlecht"
        case 5...6: return "Durchschnittlich"
        case 7...8: return "Gut"
        case 9...10: return "Perfekt"
        default: return "Bewertung"
        }
    }
    
    private func setupInitialState() {
        ratings = Array(repeating: 5, count: battle.questions.count)
        currentRating = 5
    }
    
    private func nextQuestion() {
        guard canProceed && currentQuestionIndex < battle.questions.count - 1 else { return }
        
        // Save current rating
        ratings[currentQuestionIndex] = currentRating
        
        // Move to next question
        currentQuestionIndex += 1
        currentRating = ratings[currentQuestionIndex]
    }
    
    private func previousQuestion() {
        guard currentQuestionIndex > 0 else { return }
        
        // Save current rating
        ratings[currentQuestionIndex] = currentRating
        
        // Move to previous question
        currentQuestionIndex -= 1
        currentRating = ratings[currentQuestionIndex]
    }
    
    private func submitRatings() {
        guard canProceed else { return }
        
        // Save final rating
        ratings[currentQuestionIndex] = currentRating
        
        isSubmitting = true
        
        Task {
            do {
                // Simulate submission delay
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                await MainActor.run {
                    onComplete(ratings)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Fehler beim Übermitteln der Bewertung."
                    showError = true
                    isSubmitting = false
                }
            }
        }
    }
}

#Preview {
    BattleRatingView(
        battle: Battle(
            challengerId: "user1",
            defenderId: "user2",
            status: .active,
            questions: [
                BattleQuestion(
                    id: "q1",
                    question: "Wie gut warst du mit deinem Schlaf?",
                    description: "Bewerte deine Schlafqualität der letzten 3 Tage",
                    category: .health,
                    icon: "🌙",
                    positiveWeighting: true
                ),
                BattleQuestion(
                    id: "q2",
                    question: "Wie viel Zeit hast du am Bildschirm verbracht?",
                    description: "Bewerte deine Bildschirmzeit",
                    category: .health,
                    icon: "📱",
                    positiveWeighting: false
                )
            ],
            challengerRatings: [],
            defenderRatings: [],
            createdAt: Date()
        )
    ) { ratings in
        print("Ratings submitted: \(ratings)")
    }
}