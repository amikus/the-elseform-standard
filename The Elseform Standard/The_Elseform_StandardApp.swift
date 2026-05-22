//
//  The_Elseform_StandardApp.swift
//  The Elseform Standard
//
//  Created by Andrew Klem on 8/17/25.
//

import SwiftUI
import RevenueCat

@main
struct The_Elseform_StandardApp: App {
    /// Shared authentication manager
    @State private var authManager = AuthenticationManager.shared

    /// Track if we should show the password reset view
    @State private var showUpdatePassword = false

    private let supabaseManager = SupabaseManager.shared

    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: "appl_rDIxZcqQFNeBdEXiijTcsHSesDP")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
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
        // Expected format: theelseformstandard://reset-password?code=xxx
        guard url.scheme == "theelseformstandard",
              url.host == "reset-password" else {
            return
        }

        // Parse query parameters
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return
        }

        // Extract recovery code
        guard let code = queryItems.first(where: { $0.name == "code" })?.value else {
            return
        }

        // Exchange the code for a session
        Task {
            do {
                try await supabaseManager.exchangeCodeForSession(code: code)

                // Show the update password view
                await MainActor.run {
                    showUpdatePassword = true
                }
            } catch {
                print("Error exchanging code for session: \(error)")
            }
        }
    }
}
