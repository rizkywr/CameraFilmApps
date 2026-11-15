//
//  ProccdStatusStrip.swift
//  CameraFilmApps
//

import SwiftUI

/// Digital camera LCD status bar showing WB, EV, Aspect Ratio, and Grid status.
struct ProccdStatusStrip: View {
    @Environment(CameraModel.self) private var camera

    var body: some View {
        HStack(spacing: 0) {
            // 1. White Balance
            Button {
                cycleWB()
            } label: {
                itemContent {
                    Text("WB")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .clipShape(.rect(cornerRadius: 2))
                } subtext: {
                    Text(camera.whiteBalanceMode.rawValue)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)

            divider

            // 2. Exposure Bias
            Button {
                cycleEV()
            } label: {
                itemContent {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                } subtext: {
                    Text(String(format: "%+.1f", camera.exposureBias))
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)

            divider

            // 3. Aspect Ratio
            Button {
                cycleAspectRatio()
            } label: {
                itemContent {
                    Image(systemName: "rectangle.portrait")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                } subtext: {
                    Text(camera.aspectRatioMode.rawValue)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)

            divider

            // 4. Grid
            Button {
                camera.showsGrid.toggle()
            } label: {
                itemContent {
                    Image(systemName: "grid")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                } subtext: {
                    Text(camera.showsGrid ? "ON" : "OFF")
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 52)
        .background(Color.black.opacity(0.85))
        .overlay(
            Rectangle()
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.15))
            .frame(width: 0.5, height: 32)
    }

    @ViewBuilder
    private func itemContent<Top: View, Sub: View>(
        @ViewBuilder icon: () -> Top,
        @ViewBuilder subtext: () -> Sub
    ) -> some View {
        VStack(spacing: 3) {
            icon()
            subtext()
                .font(.system(size: 10, weight: .medium).monospacedDigit())
                .foregroundStyle(Color(white: 0.8))
        }
    }

    private func cycleWB() {
        let all = CameraModel.WhiteBalanceMode.allCases
        if let idx = all.firstIndex(of: camera.whiteBalanceMode) {
            camera.whiteBalanceMode = all[(idx + 1) % all.count]
        }
    }

    private func cycleEV() {
        // -2.0, -1.0, -0.5, 0.0, +0.5, +1.0, +2.0
        let steps: [Float] = [-2.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0]
        if let idx = steps.firstIndex(where: { abs($0 - camera.exposureBias) < 0.01 }) {
            camera.exposureBias = steps[(idx + 1) % steps.count]
        } else {
            camera.exposureBias = 0.0
        }
    }

    private func cycleAspectRatio() {
        let all = CameraModel.AspectRatioMode.allCases
        if let idx = all.firstIndex(of: camera.aspectRatioMode) {
            camera.aspectRatioMode = all[(idx + 1) % all.count]
        }
    }
}
