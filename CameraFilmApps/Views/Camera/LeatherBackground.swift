//
//  LeatherBackground.swift
//  CameraFilmApps
//

import SwiftUI

/// Renders a rich vintage camera leather textured background with reactive color skin.
struct LeatherBackground: View {
    var skin: CameraSkin = .classicBlack

    var body: some View {
        ZStack {
            // 1. Base reactive skin leather color
            skin.baseColor
            
            // 2. Subtle directional gradient for natural leather luster
            LinearGradient(
                colors: [
                    skin.highlightColor.opacity(0.35),
                    skin.baseColor,
                    Color.black.opacity(0.35)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .allowsHitTesting(false)

            // 3. Realistic pebble leather grain pattern
            Canvas { context, size in
                for y in stride(from: 0, to: size.height, by: 4) {
                    for x in stride(from: (Int(y) % 8 == 0 ? 0 : 2), to: size.width, by: 4) {
                        let rect = CGRect(x: x, y: y, width: 1.6, height: 1.6)
                        let pseudoRandom = Int(x * 17 + y * 11) % 7
                        let highlightOpacity = Double(pseudoRandom) * 0.02 + 0.03
                        let shadowOpacity = Double(pseudoRandom) * 0.03 + 0.05
                        
                        // Tiny grain highlight
                        context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(highlightOpacity)))
                        // Tiny grain pit shadow
                        let shadowRect = CGRect(x: x + 0.8, y: y + 0.8, width: 1.4, height: 1.4)
                        context.fill(Path(ellipseIn: shadowRect), with: .color(.black.opacity(shadowOpacity)))
                    }
                }
            }
            .opacity(0.85)
            .allowsHitTesting(false)
            
            // 4. Subtle camera chassis edge vignette
            LinearGradient(
                colors: [Color.black.opacity(0.25), Color.clear, Color.black.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)
        }
    }
}
