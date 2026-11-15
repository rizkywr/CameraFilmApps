//
//  FilmColors.swift
//  Film Camera
//

import SwiftUI

extension Color {
    /// Warm golden accent tone reminiscent of classic film packaging.
    static let filmPrimary = Color(red: 0xE8 / 255.0, green: 0x9B / 255.0, blue: 0x5B / 255.0)
    static let filmSurfaceContainerHigh = Color(red: 0x2E / 255.0, green: 0x2A / 255.0, blue: 0x21 / 255.0)
    static let filmSurfaceContainerHighest = Color(red: 0x39 / 255.0, green: 0x34 / 255.0, blue: 0x2B / 255.0)
    static let filmOnSurfaceVariant = Color(red: 0xCF / 255.0, green: 0xC5 / 255.0, blue: 0xB4 / 255.0)
    static let filmBackground = Color(red: 0x16 / 255.0, green: 0x13 / 255.0, blue: 0x0C / 255.0)
}

extension ShapeStyle where Self == Color {
    static var filmPrimary: Color { .filmPrimary }
    static var filmSurfaceContainerHigh: Color { .filmSurfaceContainerHigh }
    static var filmSurfaceContainerHighest: Color { .filmSurfaceContainerHighest }
    static var filmOnSurfaceVariant: Color { .filmOnSurfaceVariant }
    static var filmBackground: Color { .filmBackground }
}
