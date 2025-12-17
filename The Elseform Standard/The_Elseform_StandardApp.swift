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
        }
        .environment(authManager)
    }
}
