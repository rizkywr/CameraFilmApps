//
//  CustomScopeIcons.swift
//  CameraFilmApps
//

import SwiftUI

/// Custom vectorized icon of a 35mm film canister (referencing yellow/black Kodak canister with film leader).
struct FilmCanisterIconView: View {
    var isSelected: Bool

    var body: some View {
        HStack(spacing: 0) {
            // Canister body
            ZStack(alignment: .top) {
                // Spool spool top pin
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(white: 0.3))
                    .frame(width: 5, height: 2.5)
                    .offset(y: -2.5)

                // Main cylindrical canister
                VStack(spacing: 0) {
                    // Top rim cap
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color(white: 0.25))
                        .frame(width: 14, height: 2.5)

                    // Canister label (Kodak yellow)
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.82, blue: 0.18),
                                        Color(red: 0.95, green: 0.70, blue: 0.05)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        // Black stripe on edge
                        HStack {
                            Rectangle()
                                .fill(Color(white: 0.15))
                                .frame(width: 2.5)
                            Spacer()
                        }
                    }
                    .frame(width: 13, height: 13)

                    // Bottom rim cap
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color(white: 0.25))
                        .frame(width: 14, height: 2.5)
                }
            }

            // Extended film leader with sprocket hole
            ZStack {
                // Brown film emulsion strip
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 2,
                    topTrailingRadius: 2
                )
                .fill(Color(red: 0.42, green: 0.24, blue: 0.16))
                .frame(width: 7, height: 10)

                // Sprocket notch
                RoundedRectangle(cornerRadius: 0.5)
                    .fill(Color(white: 0.1))
                    .frame(width: 2, height: 3.5)
                    .offset(x: 0.5)
            }
        }
        .frame(width: 24, height: 22)
        .opacity(isSelected ? 1.0 : 0.65)
    }
}

/// Custom vectorized icon of a retro vintage rangefinder camera (referencing silver/black Fujifilm X100 style).
struct RangefinderCameraIconView: View {
    var isSelected: Bool

    var body: some View {
        ZStack {
            // Camera Body outer shape
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(white: 0.18))
                .frame(width: 25, height: 16)
                .overlay(
                    // Two-tone: Silver chrome top plate
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [Color(white: 0.88), Color(white: 0.68)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 5.5)
                        Spacer()
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 2.5)
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5)
                )

            // Top control dials
            HStack(spacing: 3) {
                RoundedRectangle(cornerRadius: 0.5)
                    .fill(Color(white: 0.8))
                    .frame(width: 4, height: 2)
                RoundedRectangle(cornerRadius: 0.5)
                    .fill(Color(white: 0.75))
                    .frame(width: 5, height: 2)
                Spacer()
            }
            .frame(width: 22)
            .offset(y: -9)

            // Rangefinder Viewfinder window (Top right)
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(red: 0.15, green: 0.25, blue: 0.35))
                .frame(width: 4.5, height: 3.5)
                .overlay(
                    RoundedRectangle(cornerRadius: 1)
                        .strokeBorder(Color(white: 0.4), lineWidth: 0.5)
                )
                .offset(x: 7.5, y: -2.8)

            // Central Lens with concentric chrome rings and dark glass aperture
            ZStack {
                // Outer lens barrel
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.85), Color(white: 0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 11, height: 11)

                // Black inner aperture ring
                Circle()
                    .fill(Color(white: 0.12))
                    .frame(width: 8.5, height: 8.5)

                // Lens glass element with reflection glare
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 0.2, green: 0.35, blue: 0.45), Color.black],
                            center: .center,
                            startRadius: 0.5,
                            endRadius: 3
                        )
                    )
                    .frame(width: 5.5, height: 5.5)

                // Glint / reflection
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 1.5, height: 1.5)
                    .offset(x: -1, y: -1)
            }
            .offset(x: -1, y: 1.5)
        }
        .frame(width: 26, height: 22)
        .opacity(isSelected ? 1.0 : 0.65)
    }
}
