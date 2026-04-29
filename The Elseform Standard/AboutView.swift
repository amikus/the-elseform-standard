//
//  AboutView.swift
//  The Elseform Standard
//

import SwiftUI

struct AboutView: View {
    @State private var showPrivacy = false
    @State private var showSupport = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("What is The Elseform Standard?")
                    .font(.custom("Georgia-Bold", size: 28))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
                
                Divider()
                
                let blurb = """
                 The Elseform Standard first emerged in the mid-2020s, during a cultural moment defined by deep distrust of institutions, oversaturation of algorithmic feeds, and the collapse of any clear boundary between news, entertainment, and propaganda. While many commentators dismissed it as an eccentric “art project,” or "meaningless collage," the Standard proved prescient in crystallizing a new way of interpretting reality itself: as a forest of competing signals rather than a singular narrative.
                 
                 At its inception, the Standard functioned like a mythopoetic newspaper, blending ritualized selection processes with deliberate artificiality. Its readers were asked not to believe in it, but to regard its outputs as seeds, as signals from nearby realities. This refusal of truth-claims paradoxically gave it credibility: at a time when mainstream journalism still clung to the ideal of objectivity while being shaped by algorithms, the Elseform openly dramatized its memetic ecology
                 
                 Reception was mixed. Avant-garde communities, queer networks, and certain speculative tech circles embraced it as a form of cultural counter-programming. Traditional media critics dismissed it as decadent, symptomatic of a collapsing epistemic order. But the Standard spread quietly, carried by artists, mystics, scientists, and disillusioned readers who found in it both satire and a sanctuary.
                 
                 By the early 2030s, the Elseform had become a recognizable subcultural current, influencing visual design, political memes, and even experimental pedagogy. Though it never reached mass adoption on the scale of major platforms, its legacy lay in normalizing the idea that media is not a mirror of reality but an ecosystem of evolving fragments. Historians now regard the Elseform as one of the earliest intentional “hyperreal laboratories” — not just reporting the news of the forest, but becoming the forest itself.
                 """
                
                Text(blurb)
                    .multilineTextAlignment(.leading)
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .lineSpacing(4)

                Divider()

                Text("For questions, feedback, or curiosity, we're reachable. We're a small team, and we read every email.")
                    .font(.custom("Georgia", size: 14))
                    .foregroundColor(.gray)
                    .lineSpacing(4)

                Button("Privacy Policy") { showPrivacy = true }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)

                Button("Support") { showSupport = true }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(24)

        }
        .background(Color("SwissCoffee"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPrivacy) {
            SafariView(url: URL(string: "https://theelseformstandard.netlify.app/privacy")!)
        }
        .sheet(isPresented: $showSupport) {
            SafariView(url: URL(string: "https://theelseformstandard.netlify.app/support")!)
        }
    }
}

#Preview {
    AboutView()
}
