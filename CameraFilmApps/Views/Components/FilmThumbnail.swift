//
//  FilmThumbnail.swift
//  Film Camera
//

import SwiftUI

/// A film's sample image — local when downloaded or bundled, remote otherwise.
struct FilmThumbnail: View {
    let url: URL?

    var body: some View {
        Group {
            if let url, url.isFileURL, let image = UIImage(contentsOfFile: url.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.2))) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        fallbackImage
                    default:
                        placeholder(systemImage: nil)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var fallbackImage: some View {
        if let modelURL = Bundle.main.url(forResource: "ModelPortrait", withExtension: "jpg"),
           let image = UIImage(contentsOfFile: modelURL.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            placeholder(systemImage: "film")
        }
    }

    private func placeholder(systemImage: String?) -> some View {
        Rectangle()
            .fill(.filmSurfaceContainerHigh)
            .overlay {
                if let systemImage {
                    Image(systemName: systemImage).foregroundStyle(.filmOnSurfaceVariant)
                }
            }
    }
}

/// Shown for the "no film" option.
struct NoFilmThumbnail: View {
    var body: some View {
        if let modelURL = Bundle.main.url(forResource: "ModelPortrait", withExtension: "jpg"),
           let image = UIImage(contentsOfFile: modelURL.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .overlay {
                    Color.black.opacity(0.15)
                }
        } else {
            Rectangle()
                .fill(.filmSurfaceContainerHighest)
                .overlay {
                    Image(systemName: "circle.slash")
                        .font(.title3)
                        .foregroundStyle(.filmOnSurfaceVariant)
                }
        }
    }
}
