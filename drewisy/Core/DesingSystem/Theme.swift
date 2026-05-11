//
//  Theme.swift
//  drewisy
//
//  Created by Onur Zaim on 10.05.2026.
//

import SwiftUI

enum Theme {
    // Colors
    static let primary = Color(hex: "#6366F1")
    static let background = Color(hex: "#09090B")
    static let surface = Color(hex: "#18181B")
    static let textPrimary = Color(hex: "#FAFAFA")
    static let textSecondary = Color(hex: "#D4D4D8")
    
    // Metrics
    static let spacing: CGFloat = 16
    static let cornerRadius: CGFloat = 12
    static let borderWidth: CGFloat = 0.5
    static let inputHeight: CGFloat = 50
    
    // Fonts
    static let titleFont = Font.system(.title2, design: .default).weight(.bold)
    static let bodyFont = Font.system(.subheadline, design: .default)
    static let captionFont = Font.system(.caption, design: .default)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b) = (255, 255, 255)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}
