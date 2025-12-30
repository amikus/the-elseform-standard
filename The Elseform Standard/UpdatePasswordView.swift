//
//  UpdatePasswordView.swift
//  The Elseform Standard
//

import SwiftUI

struct UpdatePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthenticationManager.self) private var authManager

    private let supabaseManager = SupabaseManager.shared

    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var passwordUpdated: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                BannerView()

                Spacer()

                if passwordUpdated {
                    // Success state - password updated confirmation
                    VStack(spacing: 24) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.green)

                        Text("Password Updated")
                            .font(.system(size: 24, weight: .semibold))

                        Text("Your password has been successfully updated. You can now sign in with your new password.")
                            .font(.system(size: 16))
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
                    // Password input state
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Create New Password")
                                .font(.system(size: 24, weight: .semibold))

                            Text("Enter your new password below.")
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

                        // New Password field
                        ZStack(alignment: .leading) {
                            if newPassword.isEmpty {
                                Text("New Password")
                                    .foregroundColor(Color(.placeholderText))
                                    .padding(.leading, 16)
                            }
                            SecureField("", text: $newPassword)
                                .textContentType(.newPassword)
                                .padding()
                        }
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                        // Confirm Password field
                        ZStack(alignment: .leading) {
                            if confirmPassword.isEmpty {
                                Text("Confirm New Password")
                                    .foregroundColor(Color(.placeholderText))
                                    .padding(.leading, 16)
                            }
                            SecureField("", text: $confirmPassword)
                                .textContentType(.newPassword)
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
                                await handleUpdatePassword()
                            }
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text("Update Password")
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
                            Text("Cancel")
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

    // MARK: - Update Password Function

    @MainActor
    private func handleUpdatePassword() async {
        // Clear any previous errors
        errorMessage = nil

        // Validation
        guard !newPassword.isEmpty else {
            errorMessage = "Please enter a new password"
            return
        }

        guard newPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        // Show loading spinner
        isLoading = true

        // Ensure loading state is cleared even if task is cancelled
        defer { isLoading = false }

        do {
            // Call Supabase password update
            try await supabaseManager.updatePassword(newPassword: newPassword)

            // Success! Show confirmation
            passwordUpdated = true

        } catch {
            // Handle errors with user-friendly messages
            errorMessage = "Unable to update password. Please try again."
        }
    }
}

#Preview {
    UpdatePasswordView()
}
