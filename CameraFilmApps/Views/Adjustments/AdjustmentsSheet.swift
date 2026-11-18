//
//  AdjustmentsSheet.swift
//  Film Camera
//

import SwiftUI

/// VSCO-style studio editor:
/// Top horizontal category slider tabs (FRAME, FILM, LIGHT, COLOR, EFFECTS)
/// Bottom parameter sliders for the currently selected category with live preview.
struct AdjustmentsSheet: View {
    @Environment(CameraModel.self) private var camera
    @Environment(\.dismiss) private var dismiss

    enum EditTab: String, CaseIterable, Identifiable {
        case skin = "SKIN"
        case frame = "FRAME"
        case film = "FILM"
        case light = "LIGHT"
        case color = "COLOR"
        case effects = "EFFECTS"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .skin: return "camera.macro"
            case .frame: return "viewfinder"
            case .film: return "film"
            case .light: return "sun.max"
            case .color: return "paintpalette"
            case .effects: return "sparkles"
            }
        }
    }

    private static let compact = PresentationDetent.fraction(0.42)
    @State private var detent = AdjustmentsSheet.compact
    @State private var selectedTab: EditTab = .skin

    var body: some View {
        @Bindable var camera = camera
        NavigationStack {
            ZStack {
                // Authentic vintage camera leather texture body
                LeatherBackground(skin: camera.cameraSkin)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.35), value: camera.cameraSkin)

                VStack(spacing: 0) {
                    // 1. VSCO-Style Horizontal Category Slide Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(EditTab.allCases) { tab in
                                let isSelected = selectedTab == tab
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    withAnimation(.spring(duration: 0.25)) {
                                        selectedTab = tab
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: tab.icon)
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                        Text(tab.rawValue)
                                            .font(.system(size: 11, weight: .heavy))
                                            .tracking(1)
                                    }
                                    .foregroundStyle(isSelected ? .black : Color(white: 0.8))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? Color.filmPrimary : Color(white: 0.16))
                                    .clipShape(.capsule)
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(isSelected ? Color.clear : Color.white.opacity(0.12), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .background(Color.black.opacity(0.3))

                    Divider().background(Color.white.opacity(0.1))

                    // 2. Sliders & Controls for the active selected category
                    ScrollView {
                        VStack(spacing: 16) {
                            switch selectedTab {
                            case .skin:
                                cameraSkinSection
                            case .frame:
                                frameCompositionSection
                            case .film:
                                controlsFor(group: .film)
                            case .light:
                                controlsFor(group: .light)
                            case .color:
                                controlsFor(group: .color)
                            case .effects:
                                controlsFor(group: .effects)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("STUDIO CALIBRATION")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.warning)
                        withAnimation { camera.adjustments = .default }
                    } label: {
                        Text("RESET")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(camera.adjustments == .default ? Color(white: 0.4) : Color.filmPrimary)
                    }
                    .disabled(camera.adjustments == .default)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        dismiss()
                    } label: {
                        Text("DONE")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundStyle(Color.filmPrimary)
                    }
                }
            }
        }
        .presentationDetents([Self.compact, .large], selection: $detent)
        .presentationBackgroundInteraction(.enabled(upThrough: Self.compact))
        .presentationContentInteraction(.scrolls)
    }

    // MARK: - Camera Body Leather Skin Selection
    @ViewBuilder
    private var cameraSkinSection: some View {
        analogCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("BODY LEATHER SKIN", systemImage: "camera.macro")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(white: 0.7))
                    Spacer()
                    Text(camera.cameraSkin.displayName.capitalized)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(Color.filmPrimary)
                }

                // Grid of 3 vintage skins (+ classic option)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(CameraSkin.allCases) { skin in
                        let isSelected = camera.cameraSkin == skin
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                camera.cameraSkin = skin
                            }
                        } label: {
                            VStack(spacing: 8) {
                                // Real leather preview circle with chrome ring
                                ZStack {
                                    Circle()
                                        .fill(skin.baseColor)
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Circle()
                                                .strokeBorder(
                                                    LinearGradient(
                                                        colors: isSelected
                                                            ? [Color.filmPrimary, Color.white]
                                                            : [Color.white.opacity(0.3), Color.black.opacity(0.6)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: isSelected ? 3 : 1.5
                                                )
                                        )
                                        .shadow(color: isSelected ? Color.filmPrimary.opacity(0.6) : .black.opacity(0.4), radius: isSelected ? 6 : 3)

                                    if isSelected {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                            .shadow(color: .black.opacity(0.8), radius: 2)
                                    }
                                }

                                Text(skin.displayName)
                                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                    .foregroundStyle(isSelected ? Color.filmPrimary : Color.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isSelected ? Color.white.opacity(0.08) : Color.black.opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(
                                        isSelected ? Color.filmPrimary.opacity(0.5) : Color.white.opacity(0.06),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Frame & Composition Tab Content
    @ViewBuilder
    private var frameCompositionSection: some View {
        @Bindable var camera = camera
        VStack(spacing: 16) {
            analogCard {
                VStack(spacing: 14) {
                    // Frame Ratio
                    HStack {
                        Text("ASPECT RATIO")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(white: 0.7))
                        Spacer()
                        HStack(spacing: 6) {
                            ForEach(CameraModel.AspectRatioMode.allCases, id: \.self) { mode in
                                let isSel = camera.aspectRatioMode == mode
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    withAnimation(.spring(duration: 0.2)) {
                                        camera.aspectRatioMode = mode
                                    }
                                } label: {
                                    Text(mode.rawValue)
                                        .font(.system(size: 12, weight: .bold).monospacedDigit())
                                        .foregroundStyle(isSel ? .black : Color(white: 0.8))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(isSel ? Color.filmPrimary : Color(white: 0.22))
                                        .clipShape(.rect(cornerRadius: 6))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Divider().background(Color.white.opacity(0.1))

                    // Grid Lines Toggle
                    HStack {
                        Label("GRID LINES", systemImage: "grid")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(white: 0.7))
                        Spacer()
                        Toggle("", isOn: $camera.showsGrid)
                            .labelsHidden()
                            .tint(Color.filmPrimary)
                    }

                    Divider().background(Color.white.opacity(0.1))

                    // Level / Horizon Balance Toggle
                    HStack {
                        Label("LEVEL / HORIZON BALANCE", systemImage: "water.waves")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(white: 0.7))
                        Spacer()
                        Toggle("", isOn: $camera.showsLevel)
                            .labelsHidden()
                            .tint(Color.filmPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Parameter Sliders by Group
    @ViewBuilder
    private func controlsFor(group: AdjustmentControl.Group) -> some View {
        @Bindable var camera = camera
        let controls = AdjustmentControl.all.filter { $0.group == group }
        analogCard {
            VStack(spacing: 16) {
                ForEach(controls) { control in
                    AnalogAdjustmentRow(
                        control: control,
                        value: $camera.adjustments[dynamicMember: control.keyPath]
                    )
                    .disabled(control.group == .film && camera.selectedFilmID == nil)

                    if control.id != controls.last?.id {
                        Divider().background(Color.white.opacity(0.08))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func analogCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack {
            content()
        }
        .padding(14)
        .background(Color(red: 0.16, green: 0.16, blue: 0.17))
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.black.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}

private struct AnalogAdjustmentRow: View {
    let control: AdjustmentControl
    @Binding var value: Float

    private var isModified: Bool { abs(value - control.defaultValue) > 0.001 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: control.systemImage)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(iconColor)

                    Text(control.title.capitalized)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(white: 0.9))
                }

                Spacer()

                // Color swatch or numerical indicator
                HStack(spacing: 6) {
                    if let swatch = activeColorSwatch {
                        Circle()
                            .fill(swatch)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().strokeBorder(Color.white.opacity(0.4), lineWidth: 1))
                    }

                    Text(control.formatted(value))
                        .font(.system(size: 12, weight: .bold).monospacedDigit())
                        .foregroundStyle(isModified ? Color.filmPrimary : Color(white: 0.5))
                }
            }

            // Visual gradient indicator bar for Color tools (Warmth, Tint, Saturation)
            if let gradient = trackGradient {
                ZStack(alignment: .leading) {
                    // Visual spectrum background strip
                    RoundedRectangle(cornerRadius: 3)
                        .fill(gradient)
                        .frame(height: 6)
                        .opacity(0.85)

                    // Native slider layered seamlessly on top
                    Slider(value: $value, in: control.range, neutralValue: control.isBipolar ? 0 : nil) {
                        Text(control.title)
                    }
                    .tint(.clear)
                    .labelsHidden()
                }
            } else {
                Slider(value: $value, in: control.range, neutralValue: control.isBipolar ? 0 : nil) {
                    Text(control.title)
                }
                .tint(Color.filmPrimary)
                .labelsHidden()
            }
        }
        .contentShape(.rect)
        .onTapGesture(count: 2) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            withAnimation { value = control.defaultValue }
        }
        .sensoryFeedback(.selection, trigger: value)
        .accessibilityHint("Double-tap to reset")
    }

    private var iconColor: Color {
        if !isModified { return Color.filmPrimary }
        switch control.id {
        case "temperature":
            return value > 0 ? Color(red: 1.0, green: 0.6, blue: 0.2) : Color(red: 0.3, green: 0.65, blue: 1.0)
        case "tint":
            return value > 0 ? Color(red: 0.9, green: 0.35, blue: 0.8) : Color(red: 0.35, green: 0.85, blue: 0.45)
        case "saturation":
            return Color.filmPrimary
        default:
            return Color.filmPrimary
        }
    }

    private var activeColorSwatch: Color? {
        guard isModified else { return nil }
        switch control.id {
        case "temperature":
            // Warm (+ amber/orange), Cool (- blue)
            return value > 0 ? Color(red: 1.0, green: 0.6, blue: 0.2) : Color(red: 0.3, green: 0.65, blue: 1.0)
        case "tint":
            // Magenta (+), Green (-)
            return value > 0 ? Color(red: 0.9, green: 0.35, blue: 0.8) : Color(red: 0.35, green: 0.85, blue: 0.45)
        default:
            return nil
        }
    }

    private var trackGradient: LinearGradient? {
        switch control.id {
        case "temperature":
            // Industry standard: Cool Blue -> Neutral Slate -> Warm Amber/Orange
            return LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.55, blue: 0.95),
                    Color(red: 0.35, green: 0.35, blue: 0.38),
                    Color(red: 0.98, green: 0.58, blue: 0.15)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case "tint":
            // Industry standard: Green -> Neutral Slate -> Magenta
            return LinearGradient(
                colors: [
                    Color(red: 0.25, green: 0.85, blue: 0.4),
                    Color(red: 0.35, green: 0.35, blue: 0.38),
                    Color(red: 0.92, green: 0.3, blue: 0.75)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case "saturation":
            // Industry standard: Monochromatic Gray -> Vibrant Full Spectrum
            return LinearGradient(
                colors: [
                    Color(white: 0.35),
                    Color(red: 0.9, green: 0.4, blue: 0.3),
                    Color(red: 0.95, green: 0.75, blue: 0.2),
                    Color(red: 0.25, green: 0.75, blue: 0.85)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        default:
            return nil
        }
    }
}
