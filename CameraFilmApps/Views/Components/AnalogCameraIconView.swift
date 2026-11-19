//
//  AnalogCameraIconView.swift
//  CameraFilmApps
//

import SwiftUI

/// Vector-drawn miniature vintage 35mm point-and-shoot camera icon (inspired by classic Kodak Ultra F9).
/// Features a two-tone body (black top band + bright light-grey leatherette plate),
/// large circular lens barrel with glass reflection, optical viewfinder window, and flash element.
struct AnalogCameraIconView: View {
    var isSelected: Bool = false
    var size: CGFloat = 18

    // Proportions relative to unit dimensions
    var body: some View {
        let width = size * 1.35
        let height = size

        ZStack(alignment: .topLeading) {
            // Main Camera Chassis
            RoundedRectangle(cornerRadius: height * 0.16)
                .fill(Color.black.opacity(0.85))
                .frame(width: width, height: height)

            // Lower two-tone leatherette plate (Bright Light Grey for high contrast)
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: height * 0.12)
                    .fill(
                        isSelected
                        ? Color(white: 0.88)
                        : Color(white: 0.75)
                    )
                    .frame(width: width, height: height * 0.58)
            }
            .clipShape(RoundedRectangle(cornerRadius: height * 0.16))

            // Optical Viewfinder Window & Flash Window on upper black plate
            HStack(spacing: width * 0.08) {
                Spacer()

                // Optical Viewfinder
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(white: 0.4))
                    .frame(width: width * 0.18, height: height * 0.22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 1)
                            .strokeBorder(Color.white.opacity(0.4), lineWidth: 0.5)
                    )

                // Flash Diffuser
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(white: 0.9))
                    .frame(width: width * 0.22, height: height * 0.22)
                    .overlay(
                        // Flash Fresnel ribs
                        HStack(spacing: 0.8) {
                            ForEach(0..<3, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(width: 0.5, height: height * 0.16)
                            }
                        }
                    )
            }
            .padding(.trailing, width * 0.08)
            .padding(.top, height * 0.10)

            // Main Lens Assembly (Off-center to the left, prominent circular barrel)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.25), Color(white: 0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: height * 0.64, height: height * 0.64)
                .overlay(
                    // Outer bezel ring
                    Circle()
                        .strokeBorder(isSelected ? Color.black : Color.white.opacity(0.3), lineWidth: 0.8)
                )
                .overlay(
                    // Inner lens element with glass flare reflection
                    Circle()
                        .fill(Color(red: 0.08, green: 0.12, blue: 0.20))
                        .frame(width: height * 0.36, height: height * 0.36)
                        .overlay(
                            // Glass anti-reflective blue-cyan coating flare
                            Circle()
                                .strokeBorder(Color.cyan.opacity(0.7), lineWidth: 0.7)
                        )
                )
                .offset(x: width * 0.18, y: height * 0.26)

            // Strap Lug on Left Side
            RoundedRectangle(cornerRadius: 1)
                .strokeBorder(Color.white.opacity(0.4), lineWidth: 0.7)
                .frame(width: width * 0.08, height: height * 0.25)
                .offset(x: -width * 0.06, y: height * 0.22)
        }
        .frame(width: width, height: height)
    }
}
