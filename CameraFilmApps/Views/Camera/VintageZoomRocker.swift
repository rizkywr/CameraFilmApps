//
//  VintageZoomRocker.swift
//  Film Camera
//

import SwiftUI

/// Vintage metallic vertical zoom rocker switch (Telephoto 'T' / Wide-angle 'W')
/// Inspired by classic digicam hardware zoom levers.
struct VintageZoomRocker: View {
    @Environment(CameraModel.self) private var camera

    @State private var activeDirection: Direction? = nil
    @State private var timerTask: Task<Void, Never>? = nil

    enum Direction {
        case telephoto // T (Zoom In)
        case wide // W (Zoom Out)
    }

    var body: some View {
        HStack(spacing: 6) {
            // Metallic Vertical Rocker Switch Body
            ZStack {
                // Outer Recessed Slot with Chrome Bezel
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.1), Color(white: 0.22), Color(white: 0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 78)
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.black.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.7), radius: 3, x: 0, y: 2)

                // Brushed Aluminum Rocker Button Face
                VStack(spacing: 0) {
                    // Top Half: TELEPHOTO (T / Zoom In)
                    Button {
                        stepZoom(direction: .telephoto)
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: activeDirection == .telephoto
                                            ? [Color(white: 0.5), Color(white: 0.65)]
                                            : [Color(white: 0.82), Color(white: 0.68)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))

                            Text("T")
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white, Color(white: 0.85)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color.black.opacity(0.35), radius: 1, x: 0, y: 1)
                                .offset(y: -2)
                        }
                    }
                    .buttonStyle(RockerPressStyle())
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if activeDirection != .telephoto {
                                    startContinuousZoom(direction: .telephoto)
                                }
                            }
                            .onEnded { _ in
                                stopContinuousZoom()
                            }
                    )

                    // Center Groove Divider
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.black.opacity(0.45), Color.white.opacity(0.6), Color.black.opacity(0.45)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 1.5)

                    // Bottom Half: WIDE (W / Zoom Out)
                    Button {
                        stepZoom(direction: .wide)
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: activeDirection == .wide
                                            ? [Color(white: 0.5), Color(white: 0.65)]
                                            : [Color(white: 0.68), Color(white: 0.55)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(.rect(bottomLeadingRadius: 16, bottomTrailingRadius: 16))

                            Text("W")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white, Color(white: 0.85)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color.black.opacity(0.35), radius: 1, x: 0, y: 1)
                                .offset(y: 2)
                        }
                    }
                    .buttonStyle(RockerPressStyle())
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if activeDirection != .wide {
                                    startContinuousZoom(direction: .wide)
                                }
                            }
                            .onEnded { _ in
                                stopContinuousZoom()
                            }
                    )
                }
                .frame(width: 32, height: 72)
                .clipShape(.capsule)
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 0.75)
                )
            }

            // Side magnifying icons (+) and (-)
            VStack(spacing: 20) {
                Image(systemName: "plus.magnifyingglass")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(white: 0.65))

                Image(systemName: "minus.magnifyingglass")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(white: 0.65))
            }
        }
    }

    // MARK: - Discrete Step Zoom
    private func stepZoom(direction: Direction) {
        guard let info = camera.deviceInfo else { return }
        let current = camera.zoomFactor
        let stops = info.zoomStops

        let target: CGFloat
        switch direction {
        case .telephoto:
            // Find next stop above current
            target = stops.first { $0 > current + 0.05 } ?? info.maxZoom
        case .wide:
            // Find next stop below current
            target = stops.last { $0 < current - 0.05 } ?? info.minZoom
        }

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        camera.setZoom(target, animated: true)
    }

    // MARK: - Continuous Smooth Zoom on Hold
    private func startContinuousZoom(direction: Direction) {
        activeDirection = direction
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            let generator = UIImpactFeedbackGenerator(style: .light)
            // Initial click
            generator.impactOccurred()
            try? await Task.sleep(for: .milliseconds(250))

            while !Task.isCancelled && activeDirection == direction {
                guard let info = camera.deviceInfo else { break }
                let current = camera.zoomFactor
                let step: CGFloat = direction == .telephoto ? 0.08 : -0.08
                let next = min(max(current + step, info.minZoom), info.maxZoom)
                camera.setZoom(next, animated: false)

                generator.impactOccurred()
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
    }

    private func stopContinuousZoom() {
        activeDirection = nil
        timerTask?.cancel()
        timerTask = nil
    }
}

private struct RockerPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
