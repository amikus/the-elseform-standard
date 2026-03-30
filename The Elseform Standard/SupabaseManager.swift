//
//  SupabaseManager.swift
//  The Elseform Standard
//

import Foundation
import Supabase
import AuthenticationServices

class SupabaseManager {
    static let shared = SupabaseManager()
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://rdywvvjludftvayfkgff.supabase.co")!,
        supabaseKey: "sb_publishable_B5tPZj4HpwTLFZKyQpWFuA_EkuCuqcA"
    )
    
    private init() {}
    
    func fetchTodaysHeadlines() async throws -> [DailyHeadline] {
        let todayEastern = DateFormatter.supabaseDate.string(from: Date())

        let response: [DailyHeadline] = try await supabase
            .from("daily_headlines")
            .select("""
                id,
                story_id,
                position,
                display_date,
                stories (
                    id,
                    headline,
                    teaser,
                    body,
                    story_type
                )
            """)
            .eq("display_date", value: todayEastern)
            .order("position")
            .execute()
            .value

        return response
    }

    // MARK: - Authentication Methods

    /// Signs up a new user with email and password
    /// - Parameters:
    ///   - email: The user's email address
    ///   - password: The user's password (will be securely hashed by Supabase)
    /// - Returns: The authentication session containing user info and access tokens
    /// - Throws: Error if email already exists, password too weak, or network issues
    func signUp(email: String, password: String) async throws -> Session {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password
        )

        // If email confirmation is enabled in Supabase, session will be nil
        // User must click confirmation link in email before they can sign in
        guard let session = response.session else {
            throw AuthError.noSession
        }

        return session
    }

    /// Signs in an existing user with email and password
    /// - Parameters:
    ///   - email: The user's email address
    ///   - password: The user's password
    /// - Returns: The authentication session containing user info and access tokens
    /// - Throws: Error if credentials are invalid or network issues
    func signIn(email: String, password: String) async throws -> Session {
        let session = try await supabase.auth.signIn(
            email: email,
            password: password
        )

        return session
    }

    /// Signs out the current user and invalidates their session
    /// - Throws: Error if sign out fails (rare, usually network issues)
    func signOut() async throws {
        try await supabase.auth.signOut()
    }

    /// Sends a password reset email to the user
    /// - Parameter email: The user's email address
    /// - Throws: Error if email sending fails or network issues
    /// - Note: Supabase will send an email with a reset link to their secure password reset page
    func resetPassword(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email)
    }

    /// Updates the password for the currently authenticated user
    /// - Parameter newPassword: The new password to set
    /// - Throws: Error if password update fails or user is not authenticated
    /// - Note: User must be authenticated (via password reset token or existing session) before calling this
    func updatePassword(newPassword: String) async throws {
        try await supabase.auth.update(user: UserAttributes(password: newPassword))
    }

    /// Exchanges a recovery code for a session
    /// - Parameter code: The recovery code from the password reset email
    /// - Throws: Error if code is invalid or session creation fails
    func exchangeCodeForSession(code: String) async throws {
        _ = try await supabase.auth.exchangeCodeForSession(authCode: code)
    }

    /// Fetches whether the current user has an active subscription
    /// - Returns: true if the user's profiles row has is_subscribed = true
    func fetchIsSubscribed() async throws -> Bool {
        let user = try await supabase.auth.user()
        let response: ProfileResponse = try await supabase
            .from("profiles")
            .select("is_subscribed")
            .eq("id", value: user.id.uuidString)
            .single()
            .execute()
            .value

        return response.is_subscribed
    }

    /// Gets the current session if one exists
    /// - Returns: The current session, or nil if not authenticated
    /// - Note: Supabase automatically refreshes expired access tokens using the refresh token
    func getCurrentSession() async throws -> Session? {
        return try await supabase.auth.session
    }

    /// Signs in with Apple using native iOS Sign in with Apple
    /// - Parameters:
    ///   - idToken: The identity token from Apple authorization
    ///   - nonce: Optional nonce for additional security
    /// - Returns: The authentication session
    func signInWithApple(idToken: String, nonce: String?) async throws -> Session {
        let session = try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )
        return session
    }
}

// MARK: - Response Types

private struct ProfileResponse: Codable {
    let is_subscribed: Bool
}

// MARK: - Custom Auth Errors

/// Custom errors for authentication flows
enum AuthError: LocalizedError {
    case noSession

    var errorDescription: String? {
        switch self {
        case .noSession:
            return "Please check your email to confirm your account before signing in."
        }
    }
}

extension DateFormatter {
    // converts date field from Supabase to Louisville time to avoid 1-hour-from-midnight errors
    static let supabaseDate: DateFormatter = {
        
        let formatter = DateFormatter()
        
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/Kentucky/Louisville")
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }()
}
