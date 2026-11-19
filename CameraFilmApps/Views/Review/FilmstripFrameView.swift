//
//  FilmstripFrameView.swift
//  CameraFilmApps
//

import SwiftUI

/// Authentic 35mm film negative strip layout replicating true camera negatives:
/// Top & Bottom film margin rails with horizontal sprocket perforations and edge DX markings,
/// wrapping the photo cleanly without cropping or clipping.
struct FilmstripFrameView<Content: View>: View {
    let filmName: String
    let frameNumber: Int
    var isDetailView: Bool = false
    @ViewBuilder let content: () -> Content

    private var railHeight: CGFloat {
        isDetailView ? 34 : 26
    }

    private var sprocketWidth: CGFloat {
        isDetailView ? 11 : 9
    }

    private var sprocketHeight: CGFloat {
        isDetailView ? 8 : 6.5
    }

    private var sprocketCount: Int {
        isDetailView ? 8 : 6
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Film Margin Rail (Sprockets & Film Brand/Type)
            topMarginRail

            // Central Photo Window (Full photo, uncropped)
            ZStack {
                Color.black
                content()
            }
            .clipped()

            // Bottom Film Margin Rail (Sprockets & Frame Numbering / DX markings)
            bottomMarginRail
        }
        .background(Color(red: 0.05, green: 0.05, blue: 0.06))
        .overlay(
            // Left & Right thin frame borders
            HStack {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 0.8)
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 0.8)
            }
        )
    }

    // MARK: - Top Margin Rail (Sprockets + Film Brand / Type)

    private var topMarginRail: some View {
        HStack(spacing: 0) {
            ForEach(0..<sprocketCount, id: \.self) { idx in
                HStack {
                    Spacer(minLength: 2)
                    sprocketHole
                    Spacer(minLength: 2)
                }
                .overlay(alignment: .center) {
                    if idx == 1 {
                        Text(filmName.uppercased())
                            .font(.system(size: isDetailView ? 8.5 : 7, weight: .black, design: .rounded))
                            .foregroundStyle(Color(red: 0.95, green: 0.68, blue: 0.25))
                            .lineLimit(1)
                            .fixedSize()
                            .offset(y: isDetailView ? 12 : 9.5)
                    } else if idx == (sprocketCount - 2) {
                        // DX optical barcode
                        HStack(spacing: 1.2) {
                            ForEach(0..<4, id: \.self) { bar in
                                Rectangle()
                                    .fill(Color(white: 0.65).opacity(0.85))
                                    .frame(width: 1.2, height: bar % 2 == 0 ? (isDetailView ? 8 : 6) : (isDetailView ? 5 : 4))
                            }
                        }
                        .offset(y: isDetailView ? 12 : 9.5)
                    }
                }
            }
        }
        .frame(height: railHeight)
        .padding(.horizontal, 4)
        .background(Color(red: 0.06, green: 0.06, blue: 0.07))
    }

    // MARK: - Bottom Margin Rail (Sprockets + Frame Number + Advance Arrows)

    private var bottomMarginRail: some View {
        HStack(spacing: 0) {
            ForEach(0..<sprocketCount, id: \.self) { idx in
                HStack {
                    Spacer(minLength: 2)
                    sprocketHole
                    Spacer(minLength: 2)
                }
                .overlay(alignment: .center) {
                    if idx == 1 {
                        Text(String(format: "%02dA", frameNumber))
                            .font(.system(size: isDetailView ? 9 : 7.5, weight: .heavy, design: .monospaced))
                            .foregroundStyle(Color(red: 0.95, green: 0.68, blue: 0.25))
                            .lineLimit(1)
                            .fixedSize()
                            .offset(y: isDetailView ? -12 : -9.5)
                    } else if idx == (sprocketCount - 2) {
                        Text("▶ \(frameNumber)")
                            .font(.system(size: isDetailView ? 9 : 7.5, weight: .heavy, design: .monospaced))
                            .foregroundStyle(Color(red: 0.95, green: 0.68, blue: 0.25))
                            .lineLimit(1)
                            .fixedSize()
                            .offset(y: isDetailView ? -12 : -9.5)
                    }
                }
            }
        }
        .frame(height: railHeight)
        .padding(.horizontal, 4)
        .background(Color(red: 0.06, green: 0.06, blue: 0.07))
    }

    // MARK: - Sprocket Hole Shape

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
