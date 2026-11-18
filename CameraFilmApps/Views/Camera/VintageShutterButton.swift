//
//  VintageShutterButton.swift
//  CameraFilmApps
//

import SwiftUI

/// Authentic two-tone concentric brushed metal / chrome shutter release button.
struct VintageShutterButton: View {
    var isBusy: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer knurled metallic bezel with bevel
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(white: 0.65),
                                Color(white: 0.35),
                                Color(white: 0.20)
                            ],
                            center: .center,
                            startRadius: 28,
                            endRadius: 42
                        )
                    )
                    .frame(width: 82, height: 82)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.8), Color.black.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: .black.opacity(0.7), radius: 8, x: 0, y: 4)

                // Middle dark chrome recession rim
                Circle()
                    .strokeBorder(Color.black.opacity(0.6), lineWidth: 3)
                    .frame(width: 66, height: 66)

                // Inner raised domed brushed aluminum button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(white: 0.90),
                                Color(white: 0.68),
                                Color(white: 0.45)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 62, height: 62)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.6), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)

                if isBusy {
                    ProgressView()
                        .tint(.black)
                }
            }
        }
        .buttonStyle(VintageShutterPressStyle())
        .disabled(isBusy)
        .accessibilityLabel("Shutter Release")
    }
}

private struct VintageShutterPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
