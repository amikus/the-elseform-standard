//
//  StoryDetailView.swift
//  The Elseform Standard
//
import SwiftUI

struct StoryDetailView: View {
    let story: Story
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(story.headline)
                        .font(.custom("Georgia-Bold", size: 28))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(story.teaser)
                        .font(.custom("Georgia", size: 18))
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                Text(story.body)
                    .font(.custom("Georgia", size: 16))
                    .lineSpacing(4)
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
