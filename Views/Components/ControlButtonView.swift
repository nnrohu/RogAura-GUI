//
//  ControlButtonView.swift
//  RogAura
//
//  Created by Rohit on 02/07/25.
//
import SwiftUI

struct ControlButtonView: View {
    let id: String
    let isActive: Bool
    let systemName: String
    let title: String
    var color: Color = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemName)
                    .font(.title2)
                    .frame(height: 25)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, minHeight: 45)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(
                    isActive ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .animation(.easeIn, value: isActive)
    }
}

