//
//  ResetPasswordView.swift
//  The Elseform Standard
//

import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.dismiss) private var dismiss

    private let supabaseManager = SupabaseManager.shared

    @State private var email: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var emailSent: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                BannerView()

                Spacer()

                if emailSent {
                    // Success state - email sent confirmation
                    VStack(spacing: 24) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.black)

                        Text("Check Your Email")
                            .font(.system(size: 24, weight: .semibold))

                        VStack(spacing: 12) {
                            Text("If an account exists with this email address, we've sent a password reset link to:")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)

                            Text(email)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                        }

                        Text("Check your inbox and follow the link to reset your password.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        Button(action: {
                            dismiss()
                        }) {
                            Text("Back to Sign In")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(8)
                        }
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 24)

                } else {
                    // Email input state
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reset Password")
                                .font(.system(size: 24, weight: .semibold))

                            Text("Enter your email address and we'll send you a link to reset your password.")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, -8)

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

                        // Email field with custom placeholder
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

                        Button(action: {
                            Task {
                                await handleResetPassword()
                            }
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text("Send Reset Link")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isLoading ? Color.gray : Color.black)
                            .cornerRadius(8)
                        }
                        .disabled(isLoading)

                        Button(action: {
                            dismiss()
                        }) {
                            Text("Back to Sign In")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                Spacer()
                    .frame(height: 60) // Space for footer
            }

            FooterView(isSignedIn: false, onSignOut: nil)
        }
        .background(Color("SwissCoffee"))
        .foregroundColor(Color.black)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Reset Password Function

    @MainActor
    private func handleResetPassword() async {
        // Clear any previous errors
        errorMessage = nil

        // Basic validation
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }

        // Basic email format check
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address"
            return
        }

        // Show loading spinner
        isLoading = true

        // Ensure loading state is cleared even if task is cancelled
        defer { isLoading = false }

        do {
            // Call Supabase password reset
            try await supabaseManager.resetPassword(email: email)

            // Success! Show confirmation
            emailSent = true

        } catch {
            // Handle errors with user-friendly messages
            errorMessage = "Unable to send reset email. Please try again."
        }
    }
}

#Preview {
    ResetPasswordView()
}
