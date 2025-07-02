//
//  ControlSectionView.swift
//  RogAura
//
//  Created by Rohit on 02/07/25.
//
import SwiftUI

struct ControlSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundColor(.secondary)
            content
        }
    }
}

