//
//  ZoomControl.swift
//  Film Camera
//

import SwiftUI

/// Authentic camera lens zoom control:
/// - Quick discrete focal length stops (0.5x, 1x, 2x, 4x, 8x)
/// - Interactive tactile zoom wheel dial with mechanical tick haptics and focal length mm readout.
struct ZoomControl: View {
    @Environment(CameraModel.self) private var camera

    @State private var isDraggingWheel = false
    @State private var dragStartZoom: CGFloat = 1.0
    @State private var lastHapticFactor: CGFloat = 1.0
    @State private var hideWheelTask: Task<Void, Never>?

    var body: some View {
        if let info = camera.deviceInfo, info.zoomStops.count > 1 {
            let stops = info.zoomStops
            let active = activeStop(in: stops)

            VStack(spacing: 6) {
                // Expanded precision focal wheel when pinching or dragging
                if isDraggingWheel {
                    mechanicalWheelView(info: info)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity
                        ))
                }

                // Compact Lens Stops Pill (0.5x · 1x · 2x · 4x · 8x)
                HStack(spacing: 6) {
                    ForEach(stops, id: \.self) { stop in
                        let isSelected = isNear(stop: stop, current: camera.zoomFactor)
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            camera.setZoom(stop, animated: true)
                        } label: {
                            Text(label(for: stop, isActive: isSelected, multiplier: info.displayMultiplier))
                                .font(.system(size: isSelected ? 11 : 9.5, weight: isSelected ? .black : .bold).monospacedDigit())
                                .foregroundStyle(isSelected ? .black : Color(white: 0.85))
                                .frame(width: isSelected ? 36 : 28, height: 26)
                                .background(
                                    isSelected
                                        ? Color.filmPrimary
                                        : Color.black.opacity(0.4)
                                )
                                .clipShape(.capsule)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.12),
                                            lineWidth: 1
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color(white: 0.12).opacity(0.85))
                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.2), lineWidth: 1))
                )
                .shadow(color: .black.opacity(0.6), radius: 4, y: 2)
                .gesture(
                    DragGesture(minimumDistance: 4)
                        .onChanged { gesture in
                            if !isDraggingWheel {
                                isDraggingWheel = true
                                dragStartZoom = camera.zoomFactor
                            }
                            hideWheelTask?.cancel()

                            // Sensitivity: 120pt per 1x zoom factor
                            let delta = -gesture.translation.height * 0.02 + gesture.translation.width * 0.015
                            let target = min(max(dragStartZoom + delta, info.minZoom), info.maxZoom)
                            camera.setZoom(target, animated: false)

                            // Mechanical tick haptic every 0.15x increment
                            if abs(target - lastHapticFactor) >= 0.15 {
                                lastHapticFactor = target
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                        }
                        .onEnded { _ in
                            scheduleHideWheel()
                        }
                )
            }
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isDraggingWheel)
        }
    }

    // MARK: - Mechanical Zoom Wheel Dial
    @ViewBuilder
    private func mechanicalWheelView(info: CameraDeviceInfo) -> some View {
        let zoom = camera.zoomFactor
        let mm = Int((zoom * 24.0).rounded()) // 35mm equivalent focal length

        VStack(spacing: 3) {
            // Live focal length & zoom readout (e.g. "50mm · 2.1×")
            HStack(spacing: 6) {
                Text("\(mm)mm")
                    .font(.system(size: 11, weight: .heavy).monospacedDigit())
                    .foregroundStyle(Color.filmPrimary)

                Text("•")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.5))

                Text(String(format: "%.1f×", zoom))
                    .font(.system(size: 11, weight: .heavy).monospacedDigit())
                    .foregroundStyle(Color.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(Color.black.opacity(0.75))
            .clipShape(.capsule)
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5))

            // Lens barrel ruler notches
            GeometryReader { proxy in
                let width = proxy.size.width
                let midX = width / 2
                
                ZStack {
                    // Notches track
                    HStack(spacing: 8) {
                        ForEach(-12...12, id: \.self) { tick in
                            let isMajor = tick % 4 == 0
                            Rectangle()
                                .fill(isMajor ? Color.white.opacity(0.9) : Color.white.opacity(0.35))
                                .frame(width: isMajor ? 1.5 : 1, height: isMajor ? 12 : 7)
                        }
                    }
                    .offset(x: -CGFloat(zoom.truncatingRemainder(dividingBy: 0.5)) * 40)

                    // Center amber cursor indicator
                    Rectangle()
                        .fill(Color.filmPrimary)
                        .frame(width: 2, height: 16)
                        .shadow(color: Color.filmPrimary, radius: 4)
                        .position(x: midX, y: 10)
                }
            }
            .frame(width: 180, height: 20)
            .background(Color.black.opacity(0.6))
            .clipShape(.rect(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
        }
    }

    private func scheduleHideWheel() {
        hideWheelTask?.cancel()
        hideWheelTask = Task {
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.spring(duration: 0.25)) {
                isDraggingWheel = false
            }
        }
    }

    private func isNear(stop: CGFloat, current: CGFloat) -> Bool {
        abs(stop - current) < 0.12
    }

    private func activeStop(in stops: [CGFloat]) -> CGFloat {
        stops.last { $0 <= camera.zoomFactor + 0.05 } ?? stops[0]
    }

    private func label(for stop: CGFloat, isActive: Bool, multiplier: CGFloat) -> String {
        let value = isActive ? camera.displayZoom : stop * multiplier
        let text = value < 1 || value.truncatingRemainder(dividingBy: 1) > 0.05
            ? String(format: "%.1f", value)
            : String(format: "%.0f", value)
        return "\(text)×"
    }
}
