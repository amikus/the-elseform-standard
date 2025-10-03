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
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(story.teaser)
                        .font(.custom("Georgia", size: 18))
                        .foregroundColor(.black)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                Text(story.body)
                    .font(.custom("Georgia", size: 16))
                    .lineSpacing(4)
                    .foregroundColor(.black)
                
                Spacer(minLength: 50)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color("SwissCoffee"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
