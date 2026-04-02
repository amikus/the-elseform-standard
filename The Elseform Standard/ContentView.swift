//
//  ContentView.swift
//  The Elseform Standard
//
import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AuthenticationManager.self) private var authManager

    private let supabaseManager = SupabaseManager.shared

    @State private var headlines: [DailyHeadline] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showSubscribeAlert = false

    private let featureStoryDetailEnabled = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        BannerView()
                        
                        if isLoading {
                            VStack {
                                ProgressView()
                                Text("Loading today's headlines...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let errorMessage = errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.orange)
                                Text("Error loading headlines")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .multilineTextAlignment(.center)
                                
                                Button("Retry") {
                                    Task {
                                        await loadHeadlines()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                // TODO: ELSE-StoreKit — When StoreKit is added, wire purchase confirmation
                                // to set is_subscribed = true in Supabase (via webhook or client call).
                                // AuthenticationManager.isSubscribed will then reflect this automatically.
                                ForEach(headlines.sorted(by: { $0.position < $1.position })) { headline in
                                    if let story = headline.stories {
                                        if featureStoryDetailEnabled {
                                            ZStack(alignment: .bottomTrailing) {
                                                NavigationLink(destination: StoryDetailView(story: story)) {
                                                    HeadlineView(
                                                        text: story.headline,
                                                        position: headline.position,
                                                        storyType: story.story_type
                                                    )
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .accessibilityLabel(story.headline)
                                                .accessibilityHint(headline.position == 1 || authManager.isSubscribed ? "Opens full story" : "Subscribe to read")
                                                .blur(radius: headline.position == 1 || authManager.isSubscribed ? 0 : 3)
                                                .disabled(headline.position != 1 && !authManager.isSubscribed)
                                            }
                                        } else {
                                            HeadlineView(
                                                text: story.headline,
                                                position: headline.position,
                                                storyType: story.story_type
                                            )
                                            .accessibilityLabel(story.headline)
                                            .blur(radius: headline.position == 1 || authManager.isSubscribed ? 0 : 3)
                                        }

                                        if headline.position < 5 {
                                            Divider()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                            .frame(height: 60) // Space for footer
                    }
                }
                .refreshable { await loadHeadlines() }
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
                        Task { await loadHeadlines() }
                    }
                }

                if !authManager.isSubscribed {
                    // TODO: ELSE-StoreKit — Replace Button branch with StoreKit purchase sheet
                    Group {
                        if authManager.isAuthenticated {
                            Button {
                                showSubscribeAlert = true
                            } label: {
                                badgeLabel("Subscribe")
                            }
                            .accessibilityLabel("Subscribe to read all headlines")
                        } else {
                            NavigationLink(destination: LoginView()) {
                                badgeLabel("Subscribe / Sign In")
                            }
                            .accessibilityLabel("Subscribe or sign in to read all headlines")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 16)
                    .padding(.bottom, 76)
                    .alert("Subscriptions Coming Soon", isPresented: $showSubscribeAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("In-app subscriptions are not yet available. Check back soon!")
                    }
                }

                FooterView(isSignedIn: authManager.isAuthenticated, onSignOut: handleSignOut)
            }
            .background(Color("SwissCoffee"))
            .foregroundColor(Color.black)
        }
        .task { await loadHeadlines() }
    }

    @MainActor
    private func loadHeadlines() async {
        
        // show spinner only for the first load (or after a hard error)
        if headlines.isEmpty { isLoading = true }
        
        errorMessage = nil
        
        // make sure spinner doesn't get stuck in cancelled mid-fetch
        defer { if !Task.isCancelled { isLoading = false } }
        
        do {
            let rows = try await supabaseManager.fetchTodaysHeadlines()
            
            // if this task was superseded (user pulled down to refresh, etc.), bail quietly
            if Task.isCancelled { return }
            
            headlines = rows
            
        } catch is CancellationError {
            // common error with .refreshable/scene changes
            return
        } catch let urlErr as URLError where urlErr.code == .cancelled {
            // URLSession cancel, also normal
            return
        } catch {
            if Task.isCancelled { return }
            errorMessage = error.localizedDescription
        }

    }

    // MARK: - Sign Out Function

    /// Handles user sign out and returns to login screen
    private func handleSignOut() {
        Task {
            do {
                try await supabaseManager.signOut()
                // Update auth state - App will automatically switch to LoginView
                authManager.signOut()
            } catch {
                // If sign out fails, still update auth state
                // (rare, usually means already signed out)
                authManager.signOut()
            }
        }
    }
}

private func badgeLabel(_ text: String) -> some View {
    Text(text)
        .font(.system(size: 16, weight: .bold))
        .tracking(4)
        .foregroundColor(.black)
        .padding(.horizontal, 18)
        .padding(.vertical, 9)
        .background(Color("SwissCoffee").opacity(0.95))
        .overlay(
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.black, lineWidth: 0.5)
        )
        .cornerRadius(3)
}

struct HeadlineView: View {
    let text: String
    let position: Int
    let storyType: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {

                Text(text)
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)

            }
            
            Spacer()
        }
        .padding(.vertical, 16)
    }
}

struct BannerView: View {
    var body: some View {
        
        Image("Banner")
            .accessibilityHidden(true)
        Divider()
            .frame(height: 5)

    }
}

struct FooterView: View {
    var isSignedIn: Bool = false
    var onSignOut: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .frame(height:2)

            HStack(alignment: .top) {
                Text ("© 2026 The Elseform Standard")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    NavigationLink(destination: AboutView()) {
                        Text("About")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.black)
                    }

                    // Sign Out button - invisible when not signed in, but takes up space
                    Button(action: {
                        onSignOut?()
                    }) {
                        Text("Sign Out")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .opacity(isSignedIn ? 1.0 : 0.0)
                    .disabled(!isSignedIn)
                    .accessibilityHidden(!isSignedIn)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(height: 60)
        }
    }
}

#Preview {
    ContentView()
}

