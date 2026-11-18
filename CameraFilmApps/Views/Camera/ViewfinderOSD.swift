//
//  ViewfinderOSD.swift
//  CameraFilmApps
//

import SwiftUI

/// On-screen display graphics (film badge, crosshair, and timer countdown).
struct ViewfinderOSD: View {
    @Environment(CameraModel.self) private var camera
    @Environment(FilmLibrary.self) private var library
    @Environment(ProStore.self) private var proStore
    var onFilmTap: () -> Void

    var body: some View {
        ZStack {
            // Top HUD: PRO Quota Badge (Left) & Film Emulation Badge (Right)
            HStack {
                // Top-Left: PRO / Roll Quota badge
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    camera.showsPaywall = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 0.95, green: 0.72, blue: 0.35))
                        if proStore.isPro {
                            Text("Pro")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        } else {
                            let shots = proStore.totalCapturedCount
                            Text(shots >= ProStore.maxFreeShots ? "25/25 Used" : "\(shots)/25 Free")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(shots >= ProStore.maxFreeShots ? Color(red: 0.95, green: 0.55, blue: 0.45) : .white)
                        }
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .clipShape(.rect(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(Color(red: 0.95, green: 0.72, blue: 0.35).opacity(0.4), lineWidth: 0.8)
                    )
                }
                .buttonStyle(.plain)

                Spacer()

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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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

            // Clean Timer Countdown (Simple & Native)
            if let countdown = camera.timerCountdown {
                Text("\(countdown)")
                    .font(.system(size: 84, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.7), radius: 8)
                    .transition(.opacity)
            }
        }
    }
}
