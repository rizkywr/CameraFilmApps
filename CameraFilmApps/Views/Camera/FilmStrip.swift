//
//  FilmStrip.swift
//  Film Camera
//

import SwiftUI

struct FilmStrip: View {
    @Environment(FilmLibrary.self) private var library
    @Environment(CameraModel.self) private var camera
    var onBrowse: () -> Void

    /// The film that was long-pressed/held to initiate delete mode, where the delete trash button sits.
    @State private var primaryDeleteFilmID: String? = nil

    /// The set of all film IDs selected to be deleted (marked in red).
    @State private var selectedDeleteFilmIDs: Set<String> = []

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 14) {
                    // Original non-film item (never deletable)
                    item(id: "none", title: "Original", isSelected: camera.selectedFilmID == nil) {
                        NoFilmThumbnail()
                    } action: {
                        if primaryDeleteFilmID != nil {
                            withAnimation(.spring(duration: 0.25)) {
                                primaryDeleteFilmID = nil
                                selectedDeleteFilmIDs.removeAll()
                            }
                        }
                        Task { @MainActor in await camera.selectFilm(nil, lutURL: nil) }
                    }

                    // User's custom film rolls
                    ForEach(library.myFilms) { film in
                        filmItem(film: film, isSelected: camera.selectedFilmID == film.id)
                    }

                    // Add more films button
                    Button {
                        if primaryDeleteFilmID != nil {
                            withAnimation(.spring(duration: 0.25)) {
                                primaryDeleteFilmID = nil
                                selectedDeleteFilmIDs.removeAll()
                            }
                        } else {
                            onBrowse()
                        }
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(white: 0.18))
                                    .frame(width: 54, height: 72)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                                    )

                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color.filmPrimary)
                            }
                            .frame(width: 60, height: 78)

                            Text("More")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Color(white: 0.6))
                        }
                        .frame(width: 64)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Browse Films")
                }
                .padding(.vertical, 6)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, 18, for: .scrollContent)
            .frame(height: 124)
            .onAppear {
                proxy.scrollTo(camera.selectedFilmID ?? "none", anchor: .center)
            }
            .onChange(of: camera.selectedFilmID) { _, id in
                withAnimation { proxy.scrollTo(id ?? "none", anchor: .center) }
            }
        }
        .sensoryFeedback(.selection, trigger: camera.selectedFilmID)
    }

    private func filmItem(film: Film, isSelected: Bool) -> some View {
        let isDeleteModeActive = primaryDeleteFilmID != nil
        let isMarkedForDelete = selectedDeleteFilmIDs.contains(film.id)
        let isHoldingHost = (primaryDeleteFilmID == film.id)

        return ZStack(alignment: .topTrailing) {
            VStack(spacing: 6) {
                ZStack {
                    FilmThumbnail(url: library.thumbnailURL(for: film))
                        .frame(width: 54, height: 72)
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay {
                            if isMarkedForDelete {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.18))
                            }
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    isMarkedForDelete ? Color(red: 0.9, green: 0.22, blue: 0.22) : (isSelected ? Color.filmPrimary : Color.white.opacity(0.15)),
                                    lineWidth: (isMarkedForDelete || isSelected) ? 2.5 : 1
                                )
                        }
                }
                .frame(width: 60, height: 78)
                .scaleEffect(isMarkedForDelete ? 1.03 : (isSelected ? 1.05 : 1.0))
                .shadow(color: isSelected ? Color.black.opacity(0.6) : .clear, radius: 4, x: 0, y: 2)

                Text(film.displayName)
                    .font(.system(size: 10, weight: (isSelected || isMarkedForDelete) ? .bold : .medium))
                    .foregroundStyle(isMarkedForDelete ? Color(red: 0.95, green: 0.35, blue: 0.35) : (isSelected ? Color.filmPrimary : Color(white: 0.7)))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 64)
            .contentShape(.rect)
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                if isDeleteModeActive {
                    withAnimation(.spring(duration: 0.25)) {
                        if selectedDeleteFilmIDs.contains(film.id) {
                            selectedDeleteFilmIDs.remove(film.id)
                            // If user unselects all films including the held one, exit delete mode
                            if selectedDeleteFilmIDs.isEmpty {
                                primaryDeleteFilmID = nil
                            } else if isHoldingHost {
                                // If the held film itself was unselected, shift trash icon host to another selected film
                                primaryDeleteFilmID = selectedDeleteFilmIDs.first
                            }
                        } else {
                            // Single tap selects other films into the red delete group
                            selectedDeleteFilmIDs.insert(film.id)
                        }
                    }
                } else {
                    Task { @MainActor in
                        // Ensure LUT is downloaded/available before selecting
                        if library.lutURL(for: film) == nil {
                            _ = await library.download(film, reportsErrors: false)
                        }
                        await camera.selectFilm(film, lutURL: library.lutURL(for: film))
                    }
                }
            }
            .onLongPressGesture(minimumDuration: 0.35) {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                withAnimation(.spring(duration: 0.25)) {
                    if isDeleteModeActive {
                        if isHoldingHost {
                            // Holding the host again exits delete mode
                            primaryDeleteFilmID = nil
                            selectedDeleteFilmIDs.removeAll()
                        } else {
                            // Holding another film makes it the host and adds it to selection
                            primaryDeleteFilmID = film.id
                            selectedDeleteFilmIDs.insert(film.id)
                        }
                    } else {
                        // Holding one film activates delete mode with trash button on this film
                        primaryDeleteFilmID = film.id
                        selectedDeleteFilmIDs = [film.id]
                    }
                }
            }
            .id(film.id)
            .accessibilityAddTraits(isSelected ? .isSelected : [])

            // Direct Trash / Delete icon badge ONLY on the held film
            if isHoldingHost {
                Button {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    withAnimation(.spring(duration: 0.25)) {
                        let toDelete = selectedDeleteFilmIDs
                        for id in toDelete {
                            if camera.selectedFilmID == id {
                                Task { @MainActor in await camera.selectFilm(nil, lutURL: nil) }
                            }
                            if let f = library.film(id: id) {
                                library.remove(f)
                            }
                        }
                        primaryDeleteFilmID = nil
                        selectedDeleteFilmIDs.removeAll()
                    }
                } label: {
                    if selectedDeleteFilmIDs.count > 1 {
                        Capsule()
                            .fill(Color(red: 0.85, green: 0.2, blue: 0.2))
                            .frame(height: 24)
                            .overlay(
                                HStack(spacing: 3) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 9, weight: .bold))
                                    Text("\(selectedDeleteFilmIDs.count)")
                                        .font(.system(size: 10, weight: .heavy))
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                            )
                            .overlay(Capsule().strokeBorder(Color.white, lineWidth: 1.5))
                            .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.85, green: 0.2, blue: 0.2))
                                .frame(width: 24, height: 24)
                                .overlay(Circle().strokeBorder(Color.white, lineWidth: 1.5))
                                .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)

                            Image(systemName: "trash.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
                .offset(x: selectedDeleteFilmIDs.count > 1 ? 8 : 4, y: -4)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private func item(id: String, title: String, isSelected: Bool,
                      @ViewBuilder thumbnail: () -> some View,
                      action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    thumbnail()
                        .frame(width: 54, height: 72)
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    isSelected ? Color.filmPrimary : Color.white.opacity(0.15),
                                    lineWidth: isSelected ? 2.5 : 1
                                )
                        }
                }
                .frame(width: 60, height: 78)
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .shadow(color: isSelected ? Color.black.opacity(0.6) : .clear, radius: 4, x: 0, y: 2)

                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? Color.filmPrimary : Color(white: 0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 64)
            .animation(.spring(duration: 0.25), value: isSelected)
        }
        .buttonStyle(.plain)
        .id(id)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
