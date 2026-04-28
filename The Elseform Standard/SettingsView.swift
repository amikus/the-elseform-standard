//
//  SettingsView.swift
//  The Elseform Standard
//

import SwiftUI

struct SettingsView: View {
    @Environment(AuthenticationManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    private let supabaseManager = SupabaseManager.shared

    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                Button("Delete Account") {
                    showDeleteConfirmation = true
                }
                .foregroundColor(.red)
                .disabled(isDeleting)
                .confirmationDialog(
                    "Delete Account",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete Account", role: .destructive) {
                        Task { await deleteAccount() }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will permanently delete your account and all associated data. This cannot be undone.")
                }

                if isDeleting {
                    ProgressView()
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(24)
        }
        .background(Color("SwissCoffee"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Settings")
    }

    @MainActor
    private func deleteAccount() async {
        isDeleting = true
        errorMessage = nil
        do {
            try await supabaseManager.deleteAccount()
            authManager.signOut()
            dismiss()
        } catch {
            isDeleting = false
            errorMessage = "Could not delete your account. Please try again."
        }
    }
}
