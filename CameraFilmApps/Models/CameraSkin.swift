//
//  CameraSkin.swift
//  CameraFilmApps
//

import SwiftUI

/// Available vintage camera body leather skins.
enum CameraSkin: String, CaseIterable, Identifiable {
    case classicBlack = "CLASSIC BLACK" // Premium Classic Camera Black Leather
    case agfaBrown = "AGFA BROWN"       // Warm Saddle Brown Leather (AgfaPhoto style)
    case mazuntBurgundy = "BURGUNDY"    // Deep Wine / Crimson Leather (Mazunt Edition style)
    case ektarSage = "SAGE GREEN"       // Vintage Sage Olive Green (Kodak Ektar H35 style)

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .agfaBrown: return "Agfa Saddle Brown"
        case .mazuntBurgundy: return "Mazunt Burgundy"
        case .ektarSage: return "Ektar Sage Green"
        case .classicBlack: return "Classic Noir Black"
        }
    }

    var shortName: String {
        switch self {
        case .agfaBrown: return "BROWN"
        case .mazuntBurgundy: return "BURGUNDY"
        case .ektarSage: return "SAGE"
        case .classicBlack: return "BLACK"
        }
    }

    var icon: String {
        switch self {
        case .agfaBrown: return "shield.fill"
        case .mazuntBurgundy: return "flame.fill"
        case .ektarSage: return "leaf.fill"
        case .classicBlack: return "circle.fill"
        }
    }

    var baseColor: Color {
        switch self {
        case .agfaBrown:
            // Authentic Agfa warm saddle textured brown
            return Color(red: 0.52, green: 0.30, blue: 0.17)
        case .mazuntBurgundy:
            // Rich deep wine / bordeaux crimson red
            return Color(red: 0.44, green: 0.11, blue: 0.16)
        case .ektarSage:
            // Muted retro pastel olive / sage green
            return Color(red: 0.43, green: 0.52, blue: 0.40)
        case .classicBlack:
            // Charcoal black leather
            return Color(red: 0.12, green: 0.12, blue: 0.13)
        }
    }

    var highlightColor: Color {
        switch self {
        case .agfaBrown:
            return Color(red: 0.65, green: 0.40, blue: 0.24)
        case .mazuntBurgundy:
            return Color(red: 0.58, green: 0.16, blue: 0.22)
        case .ektarSage:
            return Color(red: 0.52, green: 0.62, blue: 0.48)
        case .classicBlack:
            return Color(red: 0.20, green: 0.20, blue: 0.21)
        }
    }
}
