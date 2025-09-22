//
//  ContentView.swift
//  The Elseform Standard
//
import SwiftUI

struct ContentView: View {
    private let supabaseManager = SupabaseManager.shared
    @State private var headlines: [DailyHeadline] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
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
            .background(.white)
            .foregroundColor(Color.black)
            .refreshable {
                await loadHeadlines()
            }
        }
        .task {
            await loadHeadlines()
        }
    }
    
    private func loadHeadlines() async {
        isLoading = true
        errorMessage = nil
        
        do {
            headlines = try await supabaseManager.fetchTodaysHeadlines()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct HeadlineView: View {
    let text: String
    let position: Int
    let storyType: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(position)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(storyType == "lore" ? Color.purple : Color.black)
                        .clipShape(Circle())
                    
                    if storyType == "lore" {
                        Text("LORE")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.purple)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                }
                
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
