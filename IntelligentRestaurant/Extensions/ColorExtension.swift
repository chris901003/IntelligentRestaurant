//
//  ColorExtension.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/8.
//

import Foundation
import SwiftUI

struct ColorTheme {
    
    let loginBackground = Color(hex: "#DCD1C3")
    let loginInfoBackground = Color(hex: "FFFBFB")
    let buttonBackground = Color(hex: "#715428")
}

extension Color {
    
    static let theme = ColorTheme()
}

extension Color {
    
    // Source Code: https://juejin.cn/post/6948250295549820942
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

