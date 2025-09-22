//
//  ContentView.swift
//  The Elseform Standard
//
//  Created by Andrew Klem on 8/17/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        VStack (spacing: 0) {
            
            BannerView()
            
            VStack (alignment: .leading, spacing: 0) {
                HeadlineView(text: "Human Influencers Stage Protest as 10th Synthetic Influencer Enters YouTube Top 100")
                Divider()
                
                HeadlineView(text: "Mutual Aid Networks Expand as Communities Fill Gaps Left by Federal Programs")
                Divider()
                
                HeadlineView(text: "Uniqlo Pivots to 'Sustainability Through Progress' Initiative, Abandons In-Store Recycling")
                Divider()
                
                HeadlineView(text: "AI-Powered Archive Hopes to Preserve LGBTQ+ History of Earth")
                Divider()
                
                HeadlineView(text: "Every Root is a Revolt: Urban Gardening for Anti-Facist Faggots")
                Divider()
            }
            .padding(.horizontal)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Align to top
        .background(.white)
        .foregroundColor(Color.black)
    }
}


// MARK: - Reusable Banner
struct BannerView: View {
    var body: some View {
        Text("The Elseform Standard")
            .font(.custom("Georgia-Bold", size: 32))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.top, 8)
            .background(Color.black)          // Black banner
            .foregroundColor(.white)          // White text
            .kerning(-0.5)
    }
}

// MARK: - Reusable Headline
struct HeadlineView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 18, weight: .semibold, design: .serif))
            .padding(.vertical, 16)
    }
}

#Preview {
    ContentView()
}
