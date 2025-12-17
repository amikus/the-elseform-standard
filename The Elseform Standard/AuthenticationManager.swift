//
//  AuthenticationManager.swift
//  The Elseform Standard
//

import Foundation
import SwiftUI

/// Manages authentication state across the entire app
/// Uses @Observable to automatically update UI when auth state changes
@Observable
class AuthenticationManager {
    /// Singleton instance - shared across the entire app
    static let shared = AuthenticationManager()

    /// Tracks whether the user is currently authenticated
    /// When this changes, any views observing it will automatically update
    var isAuthenticated: Bool = false

    /// Reference to Supabase manager for auth operations
    private let supabaseManager = SupabaseManager.shared

    private init() {}

    // MARK: - Session Management

    /// Checks if there's an active Supabase session
    /// Call this when the app launches to restore authentication state
    @MainActor
    func checkAuthentication() async {
        do {
            // Ask Supabase if there's a current session
            // This will auto-refresh if needed
            let session = try await supabaseManager.getCurrentSession()

            // If we got a session, user is logged in
            isAuthenticated = session != nil

        } catch {
            // No valid session found (or error checking)
            isAuthenticated = false
        }
    }

    /// Call this after successful sign in or sign up
    @MainActor
    func signIn() {
        isAuthenticated = true
    }

    /// Call this after signing out
    @MainActor
    func signOut() {
        isAuthenticated = false
    }
}
