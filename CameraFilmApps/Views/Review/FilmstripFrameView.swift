//
//  FilmstripFrameView.swift
//  CameraFilmApps
//

import SwiftUI

/// Authentic 35mm negative filmstrip frame featuring side sprocket perforations, DX safety edge codes, and exposure numbering.
struct FilmstripFrameView<Content: View>: View {
    let filmName: String
    let frameNumber: Int
    var isDetailView: Bool = false
    @ViewBuilder let content: () -> Content

    private var marginWidth: CGFloat {
        isDetailView ? 34 : 22
    }

    private var sprocketWidth: CGFloat {
        isDetailView ? 11 : 7
    }

    private var sprocketHeight: CGFloat {
        isDetailView ? 15 : 10
    }

    private var sprocketCount: Int {
        isDetailView ? 7 : 5
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left margin with sprocket holes & frame number / film name
            leftMargin

            // Photo frame
            content()
                .clipped()

            // Right margin with sprocket holes & DX barcode markings
            rightMargin
        }
        .background(Color(red: 0.04, green: 0.04, blue: 0.05))
        .clipShape(RoundedRectangle(cornerRadius: isDetailView ? 8 : 6))
        .overlay(
            RoundedRectangle(cornerRadius: isDetailView ? 8 : 6)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: - Left Margin (Sprocket Perforations + Film Title + Frame Number)

    private var leftMargin: some View {
        VStack(spacing: 0) {
            ForEach(0..<sprocketCount, id: \.self) { idx in
                VStack(spacing: isDetailView ? 4 : 2) {
                    sprocketHole

                    if idx == 1 {
                        Text(filmName.uppercased())
                            .font(.system(size: isDetailView ? 7 : 5, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(red: 0.95, green: 0.65, blue: 0.25).opacity(0.85))
                            .rotationEffect(.degrees(-90))
                            .fixedSize()
                            .frame(height: isDetailView ? 20 : 12)
                    } else if idx == (sprocketCount - 2) {
                        Text(String(format: "%02dA", frameNumber))
                            .font(.system(size: isDetailView ? 7.5 : 5.5, weight: .heavy, design: .monospaced))
                            .foregroundStyle(Color(red: 0.95, green: 0.65, blue: 0.25).opacity(0.85))
                            .rotationEffect(.degrees(-90))
                            .fixedSize()
                            .frame(height: isDetailView ? 18 : 12)
                    } else {
                        Spacer().frame(height: isDetailView ? 14 : 8)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(width: marginWidth)
        .padding(.vertical, isDetailView ? 8 : 4)
        .background(Color(red: 0.05, green: 0.05, blue: 0.06))
    }

    // MARK: - Right Margin (Sprocket Perforations + DX Barcode + Exposure Mark)

    private var rightMargin: some View {
        VStack(spacing: 0) {
            ForEach(0..<sprocketCount, id: \.self) { idx in
                VStack(spacing: isDetailView ? 4 : 2) {
                    sprocketHole

                    if idx == 2 {
                        // Simulated optical DX barcode lines
                        VStack(spacing: 1.5) {
                            ForEach(0..<4, id: \.self) { bar in
                                Rectangle()
                                    .fill(Color(white: 0.55).opacity(0.75))
                                    .frame(width: bar % 2 == 0 ? (isDetailView ? 12 : 8) : (isDetailView ? 7 : 5), height: 1.2)
                            }
                        }
                        .frame(height: isDetailView ? 18 : 12)
                    } else if idx == (sprocketCount - 2) {
                        Text("▶ \(frameNumber)")
                            .font(.system(size: isDetailView ? 7 : 5, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(red: 0.95, green: 0.65, blue: 0.25).opacity(0.8))
                            .rotationEffect(.degrees(-90))
                            .fixedSize()
                            .frame(height: isDetailView ? 18 : 12)
                    } else {
                        Spacer().frame(height: isDetailView ? 14 : 8)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(width: marginWidth)
        .padding(.vertical, isDetailView ? 8 : 4)
        .background(Color(red: 0.05, green: 0.05, blue: 0.06))
    }

    // MARK: - Sprocket Hole

    private var sprocketHole: some View {
        RoundedRectangle(cornerRadius: isDetailView ? 2.2 : 1.6)
            .fill(Color(white: 0.16))
            .overlay(
                RoundedRectangle(cornerRadius: isDetailView ? 2.2 : 1.6)
                    .strokeBorder(Color.black.opacity(0.85), lineWidth: 0.8)
            )
            .frame(width: sprocketWidth, height: sprocketHeight)
    }
}
