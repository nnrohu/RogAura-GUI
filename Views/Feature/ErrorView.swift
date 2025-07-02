//
//  ErrorView.swift
//  RogAura
//
//  Created by Rohit on 02/07/25.
//

import SwiftUI

struct ErrorView: View {
    private let downloadURL = URL(
        string: "https://github.com/nnrohu/macRogAuraCore")

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)

            Text("Required Tool Missing")
                .font(.headline)

            Text(
                "AuraController requires the `macRogAuraCore` command-line tool to function.\n\nPlease download it from GitHub and place it in `/usr/local/bin/`."
            )
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)

            if let url = downloadURL {
                Link("Go to GitHub", destination: url)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .padding(.top)
            }
        }
    }
}
