//
//  ContentView.swift
//  The Elseform Standard
//
import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    private let supabaseManager = SupabaseManager.shared

    @State private var headlines: [DailyHeadline] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
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
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
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
                            ForEach(headlines.sorted(by: { $0.position < $1.position })) { headline in
                                if let story = headline.stories {
                                    NavigationLink(destination: StoryDetailView(story: story)) {
                                        HeadlineView(
                                            text: story.headline,
                                            position: headline.position,
                                            storyType: story.story_type
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if headline.position < 5 {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .refreshable { await loadHeadlines() }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    Task { await loadHeadlines() }
                }
            }
            .background(.white)
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
        Text("The Elseform Standard")
            .font(.custom("Georgia-Bold", size: 32))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.top, 8)
            .background(Color.black)
            .foregroundColor(.white)
            .kerning(-0.5)
    }
}

#Preview {
    ContentView()
}
