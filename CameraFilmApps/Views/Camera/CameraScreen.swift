//
//  CameraScreen.swift
//  Film Camera
//

import SwiftUI

struct CameraScreen: View {
    @Environment(CameraModel.self) private var camera
    @Environment(FilmLibrary.self) private var library
    @Environment(FilmRollStore.self) private var rollStore
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    @State private var showsLibrary = false
    @State private var showsAdjustments = false
    @State private var isShowingRollReview = false
    @State private var isThumbnailPopping = false

    var body: some View {
        ZStack {
            // Retro black camera body with leather grain texture
            LeatherBackground(skin: camera.cameraSkin)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.35), value: camera.cameraSkin)

            VStack(spacing: 12) {
                // 1. LCD Viewfinder Screen with classic border
                Viewfinder(onFilmTap: { showsLibrary = true })
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 2. Film Filter Picker Strip
                FilmStrip(onBrowse: { showsLibrary = true })
                    .padding(.vertical, 4)

                // 3. Lower Hardware Control Panel with authentic buttons
                hardwareControlPanel
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
            }
        }
        .environment(\.colorScheme, .dark)
        .persistentSystemOverlays(.hidden)
        .sheet(isPresented: $showsLibrary) {
            FilmLibraryView()
        }
        .sheet(isPresented: $showsAdjustments) {
            AdjustmentsSheet()
        }
        .sheet(isPresented: $isShowingRollReview) {
            FilmRollReviewView(skin: camera.cameraSkin)
        }

        .alert("Something Went Wrong", isPresented: errorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(camera.captureError ?? library.errorMessage ?? "")
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: camera.shutterCount)
        .onChange(of: rollStore.photos.count) { oldCount, newCount in
            guard newCount > oldCount else { return }
            withAnimation(.spring(response: 0.28, dampingFraction: 0.45)) {
                isThumbnailPopping = true
            }
            Task {
                try? await Task.sleep(for: .milliseconds(320))
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    isThumbnailPopping = false
                }
            }
        }
        .task {
            // If selectedFilmID is nil, default to Portra 400 from bundled films
            let filmID = camera.selectedFilmID ?? FilmLibrary.bundledIDs.first
            let film = library.film(id: filmID)
            if let film {
                if library.lutURL(for: film) == nil {
                    _ = await library.download(film, reportsErrors: false)
                }
                await camera.selectFilm(film, lutURL: library.lutURL(for: film))
            } else {
                await camera.selectFilm(nil, lutURL: nil)
            }
            await camera.start()
            await library.refreshCatalog()
        }
        #if DEBUG
        .onAppear {
            switch UserDefaults.standard.string(forKey: "FCOpenSheet") {
            case "library": showsLibrary = true
            case "adjustments": showsAdjustments = true
            default: break
            }
        }
        #endif
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                Task {
                    await camera.start()
                    camera.refreshLatestPhoto()
                }
            case .background:
                camera.stop()
            default:
                break
            }
        }
    }

    // MARK: - Lower Hardware Control Panel

    private var hardwareControlPanel: some View {
        VStack(spacing: 12) {
            // Top Row of Metallic Push Buttons: Flash, Timer, Import/Develop, Flip, Menu
            HStack {
                // Flash button (3 modes: OFF, AUTO, ON)
                VintageHardwareButton(
                    icon: camera.flashMode.systemImage,
                    subtext: camera.flashMode.rawValue,
                    isActive: camera.flashMode != .off
                ) {
                    let modes = CameraModel.FlashMode.allCases
                    let index = modes.firstIndex(of: camera.flashMode) ?? 0
                    camera.flashMode = modes[(index + 1) % modes.count]
                }

                Spacer()

                // Timer button
                VintageHardwareButton(
                    icon: "timer",
                    subtext: camera.timerMode.title,
                    isActive: camera.timerMode != .off
                ) {
                    let modes = CameraModel.TimerMode.allCases
                    let index = modes.firstIndex(of: camera.timerMode) ?? 0
                    camera.timerMode = modes[(index + 1) % modes.count]
                }

                Spacer()

                // Flip Camera button with smooth rotation haptic
                VintageHardwareButton(
                    icon: "arrow.triangle.2.circlepath",
                    isActive: camera.isFlipping
                ) {
                    Task { await camera.flipCamera() }
                }
                .disabled(camera.isFlipping)

                Spacer()

                // Menu button (Opens film adjustments)
                VintageHardwareButton(
                    text: "MENU",
                    isActive: camera.adjustments != .default
                ) {
                    showsAdjustments = true
                }
            }
            .padding(.horizontal, 10)

            // Bottom Row: Gallery Thumbnail (Left) - Shutter Button (Center) - Vintage Zoom Rocker (Right)
            HStack(alignment: .center) {
                // Left: Square Photo Record preview thumbnail (taps to open Film Roll Review)
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    isShowingRollReview = true
                } label: {
                    ZStack(alignment: .center) {
                        Group {
                            if let photo = rollStore.latestThumbnail ?? camera.lastPhoto {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Color.filmSurfaceContainerHigh
                                    .overlay {
                                        Image(systemName: "film.stack")
                                            .font(.system(size: 20))
                                            .foregroundStyle(.secondary)
                                    }
                            }
                        }
                        .frame(width: 54, height: 54)
                        .clipShape(.rect(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: isThumbnailPopping
                                            ? [Color.filmPrimary, Color.white]
                                            : [Color.white.opacity(0.6), Color.black.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(
                            color: isThumbnailPopping ? Color.filmPrimary.opacity(0.6) : Color.black.opacity(0.6),
                            radius: isThumbnailPopping ? 6 : 3,
                            x: 0,
                            y: 2
                        )
                    }
                    .scaleEffect(isThumbnailPopping ? 1.22 : 1.0)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Review Film Roll")

                Spacer()

                // Center: Big Chrome Domed Shutter Release Button
                VintageShutterButton(isBusy: camera.isCapturing) {
                    Task { await camera.capture() }
                }
                .disabled(camera.status != .running)

                Spacer()

                // Right: Metallic T/W Zoom Rocker Switch
                VintageZoomRocker()
                    .frame(width: 64, alignment: .trailing)
            }
            .padding(.horizontal, 16)
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding {
            camera.captureError != nil || (!showsLibrary && library.errorMessage != nil)
        } set: { isPresented in
            if !isPresented {
                camera.captureError = nil
                library.errorMessage = nil
            }
        }
    }
}

#Preview {
    CameraScreen()
        .environment(CameraModel())
        .environment(FilmLibrary())
}
