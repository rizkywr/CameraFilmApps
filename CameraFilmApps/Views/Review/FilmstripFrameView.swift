//
//  FilmstripFrameView.swift
//  CameraFilmApps
//

import SwiftUI

/// Authentic 35mm continuous negative filmstrip frame featuring precision-aligned side sprocket perforations,
/// edge DX barcode markings, and legible exposure numbering without any blank space or photo clipping.
struct FilmstripFrameView<Content: View>: View {
    let filmName: String
    let frameNumber: Int
    var isDetailView: Bool = false
    @ViewBuilder let content: () -> Content

    private var marginWidth: CGFloat {
        isDetailView ? 30 : 22
    }

    private var sprocketWidth: CGFloat {
        isDetailView ? 9 : 7
    }

    private var sprocketHeight: CGFloat {
        isDetailView ? 13 : 10
    }

    private var sprocketCount: Int {
        isDetailView ? 6 : 5
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left margin with sprocket holes & frame number / film name
            leftMargin

            // Photo frame (scaled to fill frame so no black bars/space at bottom)
            ZStack {
                Color.black
                content()
            }
            .clipped()

            // Right margin with sprocket holes & DX barcode markings
            rightMargin
        }
        .background(Color(red: 0.04, green: 0.04, blue: 0.05))
        .overlay(
            // Subtle vintage frame separator border at top and bottom
            VStack {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 0.8)
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 0.8)
            }
        )
    }

    // MARK: - Left Margin (Sprocket Perforations + Film Title + Frame Number)

    private var leftMargin: some View {
        VStack(spacing: 0) {
            ForEach(0..<sprocketCount, id: \.self) { idx in
                VStack(spacing: 2) {
                    sprocketHole

                    if idx == 1 {
                        Text(filmName.uppercased())
                            .font(.system(size: isDetailView ? 8.5 : 7, weight: .black, design: .rounded))
                            .foregroundStyle(Color(red: 0.95, green: 0.68, blue: 0.25))
                            .rotationEffect(.degrees(-90))
                            .fixedSize()
                            .frame(width: isDetailView ? 14 : 10, height: isDetailView ? 24 : 18)
                    } else if idx == (sprocketCount - 2) {
                        Text(String(format: "%02dA", frameNumber))
                            .font(.system(size: isDetailView ? 9 : 7.5, weight: .heavy, design: .monospaced))
                            .foregroundStyle(Color(red: 0.95, green: 0.68, blue: 0.25))
                            .rotationEffect(.degrees(-90))
                            .fixedSize()
                            .frame(width: isDetailView ? 14 : 10, height: isDetailView ? 20 : 14)
                    } else {
                        Spacer().frame(height: isDetailView ? 10 : 6)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(width: marginWidth)
        .padding(.vertical, 4)
        .background(Color(red: 0.05, green: 0.05, blue: 0.06))
    }

    // MARK: - Right Margin (Sprocket Perforations + DX Barcode + Exposure Mark)

    private var rightMargin: some View {
        VStack(spacing: 0) {
            ForEach(0..<sprocketCount, id: \.self) { idx in
                VStack(spacing: 2) {
                    sprocketHole

                    if idx == 2 {
                        // Simulated optical DX barcode lines
                        VStack(spacing: 1.5) {
                            ForEach(0..<4, id: \.self) { bar in
                                Rectangle()
                                    .fill(Color(white: 0.65).opacity(0.85))
                                    .frame(width: bar % 2 == 0 ? (isDetailView ? 11 : 8) : (isDetailView ? 6 : 5), height: 1.2)
                            }
                        }
                        .frame(height: isDetailView ? 16 : 12)
                    } else if idx == (sprocketCount - 2) {
                        Text("▶ \(frameNumber)")
                            .font(.system(size: isDetailView ? 9 : 7.5, weight: .heavy, design: .monospaced))
                            .foregroundStyle(Color(red: 0.95, green: 0.68, blue: 0.25))
                            .rotationEffect(.degrees(-90))
                            .fixedSize()
                            .frame(width: isDetailView ? 14 : 10, height: isDetailView ? 20 : 14)
                    } else {
                        Spacer().frame(height: isDetailView ? 10 : 6)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(width: marginWidth)
        .padding(.vertical, 4)
        .background(Color(red: 0.05, green: 0.05, blue: 0.06))
    }

    // MARK: - Sprocket Hole

    private var sprocketHole: some View {
        RoundedRectangle(cornerRadius: 1.6)
            .fill(Color(white: 0.16))
            .overlay(
                RoundedRectangle(cornerRadius: 1.6)
                    .strokeBorder(Color.black.opacity(0.9), lineWidth: 0.8)
            )
            .frame(width: sprocketWidth, height: sprocketHeight)
    }
}
