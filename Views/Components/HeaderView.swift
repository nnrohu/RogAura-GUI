//
//  HeaderView.swift
//  RogAura
//
//  Created by Rohit on 02/07/25.
//
import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            Text("Rog Aura")
                .font(.title2.bold())
            Spacer()
            Image(systemName: "lightbulb.2.fill")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .purple, .orange],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}

#Preview {
    HeaderView()
        .padding()
}
