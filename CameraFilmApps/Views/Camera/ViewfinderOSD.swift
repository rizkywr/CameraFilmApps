//
//  ViewfinderOSD.swift
//  CameraFilmApps
//

import SwiftUI

/// On-screen display graphics (film badge, crosshair, and timer countdown).
struct ViewfinderOSD: View {
    @Environment(CameraModel.self) private var camera
    @Environment(FilmLibrary.self) private var library
    var onFilmTap: () -> Void

    var body: some View {
        ZStack {
            // Top-right: Film simulation indicator
            HStack(spacing: 8) {
                // Film simulation badge (tap to open film library)
                Button(action: onFilmTap) {
                    let film = library.film(id: camera.selectedFilmID)
                    HStack(spacing: 4) {
                        Image(systemName: "film")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.filmPrimary)
                        Text(film?.displayName ?? "Original")
                            .font(.system(size: 11, weight: .semibold))
                            .lineLimit(1)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .clipShape(.rect(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(14)

            // Bottom-right in viewfinder: Digital/Optical Zoom factor indicator
            if camera.displayZoom > 1.05 || camera.displayZoom < 0.95 {
                HStack(spacing: 3) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 9, weight: .bold))
                    Text(String(format: "%.1f×", camera.displayZoom))
                        .font(.system(size: 11, weight: .heavy).monospacedDigit())
                }
                .foregroundStyle(Color.filmPrimary)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.6))
                .clipShape(.capsule)
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(12)
            }

            // Center: Crosshair
            CrosshairReticle()

            // Screen flash pulse synchronised with timer LED torch
            if camera.isTorchPulsing {
                Color.white.opacity(0.25)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            // Timer countdown if active
            if let countdown = camera.timerCountdown {
                VStack(spacing: 8) {
                    Text("\(countdown)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)
                        .scaleEffect(camera.isTorchPulsing ? 1.15 : 1.0)
                        .shadow(color: .black.opacity(0.8), radius: 12)
                        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: camera.isTorchPulsing)

                    Text("TAP SHUTTER TO CANCEL")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .clipShape(.capsule)
                }
            }
        }
    }
}
