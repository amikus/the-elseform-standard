//
//  LoginView.swift
//  The Elseform Standard
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    BannerView()

                    Spacer()

                    NavigationLink(destination: ContentView()) {
                        Text("Go to Headlines")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    Spacer()
                        .frame(height: 60) // Space for footer
                }

                FooterView()
            }
            .background(Color("SwissCoffee"))
            .foregroundColor(Color.black)
        }
    }
}

#Preview {
    LoginView()
}
