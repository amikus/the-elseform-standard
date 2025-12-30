//
//  The_Elseform_StandardApp.swift
//  The Elseform Standard
//
//  Created by Andrew Klem on 8/17/25.
//

import SwiftUI

@main
struct The_Elseform_StandardApp: App {
    /// Shared authentication manager
    @State private var authManager = AuthenticationManager.shared

    /// Track if we should show the password reset view
    @State private var showUpdatePassword = false

    private let supabaseManager = SupabaseManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    // User is logged in - show headlines
                    ContentView()
                } else {
                    // User is not logged in - show login screen
                    LoginView()
                }
            }
            .background(Color("SwissCoffee"))
            .ignoresSafeArea()
            .task {
                // Check for existing session when app launches
                await authManager.checkAuthentication()
            }
            .sheet(isPresented: $showUpdatePassword) {
                UpdatePasswordView()
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
        .environment(authManager)
    }

    // MARK: - Deep Link Handler

    private func handleDeepLink(_ url: URL) {
        // Check if this is a password reset link
        // Expected format: theelseformstandard://reset-password?access_token=xxx&refresh_token=yyy
        guard url.scheme == "theelseformstandard",
              url.host == "reset-password" else {
            return
        }

        // Parse query parameters
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return
        }

        // Extract tokens
        let accessToken = queryItems.first(where: { $0.name == "access_token" })?.value
        let refreshToken = queryItems.first(where: { $0.name == "refresh_token" })?.value

        guard let accessToken = accessToken,
              let refreshToken = refreshToken else {
            return
        }

        // Set the session with the recovery tokens
        Task {
            do {
                try await supabaseManager.setSession(accessToken: accessToken, refreshToken: refreshToken)

                // Show the update password view
                await MainActor.run {
                    showUpdatePassword = true
                }
            } catch {
                print("Error setting session from recovery tokens: \(error)")
            }
        }
    }
}
