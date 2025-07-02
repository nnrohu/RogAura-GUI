//
//  ZoneHotspotView.swift
//  RogAura
//
//  Created by Rohit on 02/07/25.
//
import SwiftUI

struct ZoneHotspotView: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(isSelected ? color.opacity(0.4) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(
                        isSelected ? Color.accentColor : Color.clear,
                        lineWidth: 2)
            )
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
    }
}
