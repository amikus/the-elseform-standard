//
//  LoginView.swift
//  The Elseform Standard
//

import SwiftUI

struct LoginView: View {
    // MARK: - Authentication Mode
    enum AuthMode {
        case signIn
        case signUp

        var buttonText: String {
            switch self {
            case .signIn: return "Sign In"
            case .signUp: return "Create Account"
            }
        }
    }

    private let supabaseManager = SupabaseManager.shared

    @State private var authMode: AuthMode = .signIn
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var isAuthenticated: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    BannerView()

                    Spacer()

                    VStack(spacing: 24) {
                        // Toggle between Sign In and Sign Up
                        HStack(spacing: 32) {
                            Button(action: { authMode = .signIn }) {
                                VStack(spacing: 4) {
                                    Text("Sign In")
                                        .font(.system(size: 18, weight: authMode == .signIn ? .semibold : .regular))
                                        .foregroundColor(authMode == .signIn ? .black : .gray)

                                    Rectangle()
                                        .fill(authMode == .signIn ? Color.black : Color.clear)
                                        .frame(height: 2)
                                }
                            }

                            Button(action: { authMode = .signUp }) {
                                VStack(spacing: 4) {
                                    Text("Sign Up")
                                        .font(.system(size: 18, weight: authMode == .signUp ? .semibold : .regular))
                                        .foregroundColor(authMode == .signUp ? .black : .gray)

                                    Rectangle()
                                        .fill(authMode == .signUp ? Color.black : Color.clear)
                                        .frame(height: 2)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)

                        // Error message display
                        if let errorMessage = errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }

                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )

                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )

                        Button(action: {
                            Task {
                                await handleAuthentication()
                            }
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text(authMode.buttonText)
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isLoading ? Color.gray : Color.black)
                            .cornerRadius(8)
                        }
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, 24)
                    .navigationDestination(isPresented: $isAuthenticated) {
                        ContentView()
                    }

                    Spacer()

                    Spacer()
                        .frame(height: 60) // Space for footer
                }

                FooterView()
            }
            .background(Color("SwissCoffee"))
            .foregroundColor(Color.black)
        }
    }

    // MARK: - Authentication Function

    /// Handles authentication based on current mode (Sign In or Sign Up)
    @MainActor
    private func handleAuthentication() async {
        // Clear any previous errors
        errorMessage = nil

        // Basic validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            return
        }

        // Show loading spinner
        isLoading = true

        // Ensure loading state is cleared even if task is cancelled
        defer { isLoading = false }

        do {
            // Call appropriate Supabase method based on mode
            switch authMode {
            case .signIn:
                _ = try await supabaseManager.signIn(email: email, password: password)
            case .signUp:
                _ = try await supabaseManager.signUp(email: email, password: password)
            }

            // Success! Trigger navigation
            isAuthenticated = true

        } catch {
            // Handle errors with user-friendly messages
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    LoginView()
}
