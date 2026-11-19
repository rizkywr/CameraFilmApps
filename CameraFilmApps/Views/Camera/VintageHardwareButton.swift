//
//  VintageHardwareButton.swift
//  CameraFilmApps
//

import SwiftUI

/// Vintage metallic round push button found on classic digital/film cameras.
struct VintageHardwareButton: View {
    var icon: String? = nil
    var text: String? = nil
    var subtext: String? = nil
    var isActive: Bool = false
    var action: () -> Void

    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        } label: {
            ZStack {
                // Outer dark bezel with metallic highlight
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(white: 0.32), Color(white: 0.16), Color(white: 0.08)],
                            center: .center,
                            startRadius: 8,
                            endRadius: 26
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.35), Color.black.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 2)

                // Inner button face
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isActive
                                ? [Color(white: 0.45), Color(white: 0.28)]
                                : [Color(white: 0.28), Color(white: 0.18)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                // Label / icon
                VStack(spacing: 1) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(isActive ? Color.filmPrimary : Color(white: 0.85))
                    }
                    if let text {
                        Text(text)
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(isActive ? Color.filmPrimary : Color(white: 0.85))
                    }
                    if let subtext {
                        Text(subtext)
                            .font(.system(size: 9.5, weight: .heavy, design: .rounded))
                            .foregroundStyle(isActive ? Color.filmPrimary : Color.white.opacity(0.85))
                    }
                }
            }
        }
        .buttonStyle(VintagePressStyle())
    }
}

/// The salmon/coral-red round button labeled "CAMERA" for switching films / cameras
struct VintageSalmonButton: View {
    var title: String = "CAMERA"
    var action: () -> Void

    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        } label: {
            ZStack {
                // Outer ring
                Circle()
                    .fill(Color(red: 0.18, green: 0.14, blue: 0.14))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle().strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)

                // Salmon/coral button body
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.92, green: 0.45, blue: 0.42),
                                Color(red: 0.78, green: 0.32, blue: 0.30)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle().strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                    )

                VStack(spacing: 2) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(title)
                        .font(.system(size: 7, weight: .black, design: .rounded))
                        .tracking(0.5)
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(VintagePressStyle())
    }
}

struct VintagePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}


/// Visual appearance of the vintage metallic push button (used standalone or inside pickers/links)
struct VintageHardwareButtonFace: View {
    var icon: String? = nil
    var text: String? = nil
    var subtext: String? = nil
    var isActive: Bool = false

    var body: some View {
        ZStack {
            // Outer dark bezel with metallic highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(white: 0.32), Color(white: 0.16), Color(white: 0.08)],
                        center: .center,
                        startRadius: 8,
                        endRadius: 26
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.35), Color.black.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 2)

            // Inner button face
            Circle()
                .fill(
                    LinearGradient(
                        colors: isActive
                            ? [Color(white: 0.45), Color(white: 0.28)]
                            : [Color(white: 0.28), Color(white: 0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)

            // Label / icon
            VStack(spacing: 1) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(isActive ? Color.filmPrimary : Color(white: 0.85))
                }
                if let text {
                    Text(text)
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(isActive ? Color.filmPrimary : Color(white: 0.85))
                }
                if let subtext {
                    Text(subtext)
                        .font(.system(size: 9.5, weight: .heavy, design: .rounded))
                        .foregroundStyle(isActive ? Color.filmPrimary : Color.white.opacity(0.85))
                }
            }
        }
    }
}
