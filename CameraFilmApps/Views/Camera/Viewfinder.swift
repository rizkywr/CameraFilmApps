//
//  Viewfinder.swift
//  Film Camera
//

import SwiftUI

/// The viewfinder preview with authentic compact camera frame, reticle, aspect ratio, and status.
struct Viewfinder: View {
    @Environment(CameraModel.self) private var camera
    @Environment(FilmLibrary.self) private var library
    var onFilmTap: () -> Void

    @State private var focusPoint: CGPoint?
    @State private var focusID = 0
    @State private var pinchStartZoom: CGFloat?
    @State private var shutterFlash = false

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                if let renderer = camera.renderer {
                    CameraPreview(renderer: renderer, rotationReferenceLayer: camera.rotationReferenceLayer)
                        // Smoothly hide frame disorientation during camera hardware switch
                        .opacity(camera.isFlipping ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 0.22), value: camera.isFlipping)
                } else {
                    Color.black
                }

                // Smooth mechanical shutter iris curtain during flip
                if camera.isFlipping {
                    Color.black
                        .transition(.opacity)
                }

                if camera.showsGrid {
                    GridOverlay().allowsHitTesting(false)
                }

                if camera.showsLevel {
                    LevelBalanceOverlay(roll: camera.levelRoll)
                        .allowsHitTesting(false)
                }

                if let focusPoint {
                    FocusIndicator()
                        .position(x: focusPoint.x * size.width, y: focusPoint.y * size.height)
                        .id(focusID)
                        .allowsHitTesting(false)
                }

                // OSD Reticle and camera indicators
                ViewfinderOSD(onFilmTap: onFilmTap)

                statusOverlay

                Color.black
                    .opacity(shutterFlash ? 0.85 : 0)
                    .allowsHitTesting(false)
            }
            .contentShape(.rect)
            .onTapGesture { location in
                let point = CGPoint(x: location.x / size.width, y: location.y / size.height)
                camera.focus(atNormalized: point, previewSize: size)
                focusPoint = point
                focusID += 1
            }
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        let start = pinchStartZoom ?? camera.zoomFactor
                        pinchStartZoom = start
                        camera.setZoom(start * value.magnification, animated: false)
                    }
                    .onEnded { _ in pinchStartZoom = nil }
            )
        }
        .aspectRatio(aspectRatioValue, contentMode: .fit)
        // Outer dark chassis border replicating camera LCD screen casing
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), Color.black.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
        )

        .onChange(of: camera.shutterCount) {
            shutterFlash = true
            withAnimation(.easeOut(duration: 0.3)) { shutterFlash = false }
        }
        .task(id: focusID) {
            guard focusPoint != nil else { return }
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation { focusPoint = nil }
        }
    }

    private var aspectRatioValue: CGFloat {
        switch camera.aspectRatioMode {
        case .ratio3_4: return 3.0 / 4.0
        case .ratio1_1: return 1.0
        case .ratio16_9: return 9.0 / 16.0
        }
    }

    @ViewBuilder
    private var statusOverlay: some View {
        switch camera.status {
        case .unauthorized:
            ContentUnavailableView {
                Label("Camera Access Needed", systemImage: "camera.fill")
            } description: {
                Text("Allow camera access in Settings to start shooting on film.")
            } actions: {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.glassProminent)
            }
            .background(.black)
        case .failed(let message):
            ContentUnavailableView("Camera Unavailable", systemImage: "exclamationmark.triangle", description: Text(message))
                .background(.black)
        case .idle, .running:
            EmptyView()
        }
    }
}

private struct GridOverlay: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            for i in 1...2 {
                let x = size.width * CGFloat(i) / 3
                let y = size.height * CGFloat(i) / 3
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(path, with: .color(.white.opacity(0.35)), lineWidth: 0.5)
        }
    }
}

private struct FocusIndicator: View {
    @State private var settled = false

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .strokeBorder(Color.filmPrimary, lineWidth: 1.5)
            .frame(width: 60, height: 60)
            .scaleEffect(settled ? 1 : 1.3)
            .opacity(settled ? 1 : 0)
            .onAppear {
                withAnimation(.spring(duration: 0.3)) { settled = true }
            }
    }
}


/// Precision electronic horizon balance indicator
private struct LevelBalanceOverlay: View {
    var roll: Double // Degrees (-180 to 180)

    var body: some View {
        // Level when within +- 1.5 degrees
        let isLevel = abs(roll) <= 1.5
        let displayAngle = isLevel ? 0.0 : -roll

        GeometryReader { proxy in
            let midX = proxy.size.width / 2
            let midY = proxy.size.height / 2
            
            ZStack {
                // Fixed horizon brackets/crosshair on camera chassis
                HStack(spacing: 80) {
                    Rectangle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 18, height: 2)
                        .shadow(color: .black.opacity(0.8), radius: 2)

                    Rectangle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 18, height: 2)
                        .shadow(color: .black.opacity(0.8), radius: 2)
                }
                .position(x: midX, y: midY)

                // Rotating horizon line
                ZStack {
                    HStack(spacing: 36) {
                        Rectangle()
                            .fill(isLevel ? Color.filmPrimary : Color.white)
                            .frame(width: 52, height: isLevel ? 3 : 2)
                            .shadow(color: isLevel ? Color.filmPrimary : .black.opacity(0.8), radius: isLevel ? 6 : 2)

                        Rectangle()
                            .fill(isLevel ? Color.filmPrimary : Color.white)
                            .frame(width: 52, height: isLevel ? 3 : 2)
                            .shadow(color: isLevel ? Color.filmPrimary : .black.opacity(0.8), radius: isLevel ? 6 : 2)
                    }

                    Circle()
                        .fill(isLevel ? Color.filmPrimary : Color.white)
                        .frame(width: 6, height: 6)
                        .shadow(color: isLevel ? Color.filmPrimary : .black.opacity(0.8), radius: isLevel ? 6 : 2)
                }
                .position(x: midX, y: midY)
                .rotationEffect(.degrees(displayAngle))
                .animation(.easeOut(duration: 0.1), value: displayAngle)
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: abs(roll) <= 1.5)
    }
}
