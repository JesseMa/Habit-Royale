import SwiftUI

struct AuthenticationView: View {
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo and title
                    VStack(spacing: 10) {
                        Text("🐾")
                            .font(.system(size: 80))
                        
                        Text("Habit Royale")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Verwandle deine Gewohnheiten in ein Abenteuer!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 50)
                    
                    // Auth form
                    VStack(spacing: 20) {
                        if isSignUp {
                            TextField("Benutzername", text: $username)
                                .textFieldStyle(AuthTextFieldStyle())
                                .autocapitalization(.none)
                        }
                        
                        TextField("E-Mail", text: $email)
                            .textFieldStyle(AuthTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Passwort", text: $password)
                            .textFieldStyle(AuthTextFieldStyle())
                        
                        Button(action: authenticate) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isSignUp ? "Registrieren" : "Anmelden")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                        .disabled(isLoading)
                        
                        Button(action: { isSignUp.toggle() }) {
                            Text(isSignUp ? "Bereits ein Konto? Anmelden" : "Noch kein Konto? Registrieren")
                                .foregroundColor(.white)
                                .font(.footnote)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .alert("Fehler", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func authenticate() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Bitte alle Felder ausfüllen."
            showError = true
            return
        }
        
        if isSignUp && username.isEmpty {
            errorMessage = "Bitte einen Benutzernamen eingeben."
            showError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                if isSignUp {
                    try await authManager.signUp(email: email, password: password, username: username)
                } else {
                    try await authManager.signIn(email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            
            isLoading = false
        }
    }
}

struct AuthTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}