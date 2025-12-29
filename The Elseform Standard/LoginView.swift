//
//  LoginView.swift
//  The Elseform Standard
//

import SwiftUI
import AuthenticationServices
import CryptoKit

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

    @Environment(AuthenticationManager.self) private var authManager

    private let supabaseManager = SupabaseManager.shared

    @State private var authMode: AuthMode = .signIn
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    BannerView()

                    Spacer()

                    VStack(spacing: 24) {
                        // Apple Sign-In Button
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            Task {
                                await handleAppleSignIn(result)
                            }
                        }
                        .frame(height: 50)
                        .cornerRadius(8)

                        // "or" divider
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            Text("or")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 8)

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

                        ZStack(alignment: .leading) {
                            if email.isEmpty {
                                Text("Email")
                                    .foregroundColor(Color(.placeholderText))
                                    .padding(.leading, 16)
                            }
                            TextField("", text: $email)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .padding()
                        }
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                        ZStack(alignment: .leading) {
                            if password.isEmpty {
                                Text("Password")
                                    .foregroundColor(Color(.placeholderText))
                                    .padding(.leading, 16)
                            }
                            SecureField("", text: $password)
                                .textContentType(.password)
                                .padding()
                        }
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                        // Reset Password link
                        HStack {
                            Spacer()
                            Button(action: {
                                // TODO: Navigate to password reset flow
                            }) {
                                Text("Reset Password")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.top, -16)

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

                    Spacer()

                    Spacer()
                        .frame(height: 60) // Space for footer
                }

                FooterView(isSignedIn: false, onSignOut: nil)
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

            // Success! Update auth state
            // This will trigger the App to switch to ContentView
            authManager.signIn()

        } catch {
            // Handle errors with user-friendly messages
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Apple Sign-In Handler

    /// Handles Apple Sign-In authorization result
    @MainActor
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async {
        // Clear any previous errors
        errorMessage = nil

        do {
            let authorization = try result.get()

            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Unable to get Apple ID credentials"
                return
            }

            guard let identityTokenData = appleIDCredential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                errorMessage = "Unable to get identity token"
                return
            }

            // Sign in to Supabase with Apple ID token
            _ = try await supabaseManager.signInWithApple(
                idToken: identityToken,
                nonce: nil
            )

            // Success! Update auth state
            authManager.signIn()

        } catch {
            // Handle errors
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    LoginView()
}
