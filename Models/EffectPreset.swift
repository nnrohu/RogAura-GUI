//
//  EffectPreset.swift
//  RogAura
//
//  Created by Rohit on 01/07/25.
//

import Foundation
import SwiftUI

// Data model for savable presets
struct EffectPreset: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var effectID: String
    var colors: [CodableColor]
    var speed: Int

    var swiftUIColors: [Color] {
        colors.compactMap { Color(hex: $0.hex) }
    }
}

// Helper struct to make Color Codable and Identifiable
struct CodableColor: Codable, Hashable, Identifiable {
    let id: UUID
    var hex: String

    init(id: UUID = UUID(), hex: String) {
        self.id = id
        self.hex = hex
    }
}

// Helper extension to convert Color to and from Hex strings
extension Color {
    func toHex() -> String? {
        guard let srgbColor = NSColor(self).usingColorSpace(.sRGB) else {
            return nil
        }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        srgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(
            format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0)
    }
}
