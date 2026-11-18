//
//  FilmLibraryView.swift
//  Film Camera
//

import SwiftUI

/// Authentic analog film catalog, canister cards, and roll management.
struct FilmLibraryView: View {
    enum Scope: String, CaseIterable, Identifiable {
        case explore = "ROLLS FILM"
        case myFilms = "MY FILM"
        var id: String { rawValue }

        var iconName: String {
            switch self {
            case .explore: return "film.stack"
            case .myFilms: return "camera.aperture"
            }
        }
    }

    @Environment(FilmLibrary.self) private var library
    @Environment(CameraModel.self) private var camera
    @Environment(\.dismiss) private var dismiss

    @State private var scope: Scope = .explore
    @State private var category: String?
    @State private var searchText = ""
    @State private var isSearchPresented = false
    @FocusState private var isSearchFocused: Bool
    @State private var confirmsDownloadAll = false
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            ZStack {
                // Authentic vintage camera leather texture body
                LeatherBackground(skin: camera.cameraSkin)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.35), value: camera.cameraSkin)

                Group {
                    switch scope {
                    case .explore: explore
                    case .myFilms: myFilms
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("FILM VAULT")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, isPresented: $isSearchPresented, prompt: "Search Kodak, Fuji, Ilford…")
            .searchFocused($isSearchFocused)
            .searchPresentationToolbarBehavior(.avoidHidingContent)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 4) {
                        // Rolls Film (Kodak 35mm Canister Icon)
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                scope = .explore
                            }
                        } label: {
                            HStack(spacing: 6) {
                                FilmCanisterIconView(isSelected: scope == .explore)
                                Text("ROLLS")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundStyle(scope == .explore ? Color.white : Color.white.opacity(0.45))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(scope == .explore ? Color.white.opacity(0.16) : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)

                        // My Film (Fujifilm X100 Rangefinder Camera Icon)
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                scope = .myFilms
                            }
                        } label: {
                            HStack(spacing: 6) {
                                RangefinderCameraIconView(isSelected: scope == .myFilms)
                                Text("MY FILM")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundStyle(scope == .myFilms ? Color.white : Color.white.opacity(0.45))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(scope == .myFilms ? Color.white.opacity(0.16) : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(3)
                    .background(
                        RoundedRectangle(cornerRadius: 11)
                            .fill(Color.black.opacity(0.55))
                            .overlay(
                                RoundedRectangle(cornerRadius: 11)
                                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.8)
                            )
                    )
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("DONE")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundStyle(Color.filmPrimary)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    switch scope {
                    case .myFilms:
                        EmptyView()
                    case .explore:
                        Button {
                            confirmsDownloadAll = true
                        } label: {
                            Text("IMPORT ALL")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundStyle(Color.filmPrimary)
                        }
                        .disabled(library.notYetDownloaded(filteredFilms).isEmpty)
                    }
                }
            }
            .confirmationDialog(
                downloadAllTitle,
                isPresented: $confirmsDownloadAll,
                titleVisibility: .visible
            ) {
                Button("Import All") {
                    Task { await library.downloadAll(filteredFilms) }
                }
                Button("Cancel", role: .destructive) {
                    confirmsDownloadAll = false
                }
            }
            .alert("Import Failed", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(library.errorMessage ?? "")
            }
            .safeAreaInset(edge: .bottom) {
                if let progress = library.bulkDownload {
                    BulkDownloadBar(progress: progress) { library.cancelBulkDownload() }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
        }
        .environment(\.editMode, $editMode)
        .onChange(of: scope) { _, newScope in
            if newScope != .myFilms {
                editMode = .inactive
            }
        }
    }

    // MARK: - Explore

    private var explore: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14, pinnedViews: [.sectionHeaders]) {
                Section {
                    let columns = [GridItem(.adaptive(minimum: 105), spacing: 12)]
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(filteredFilms) { film in
                            AnalogFilmCanisterCard(film: film) { select(film) }
                        }
                    }
                    .padding(.horizontal, 14)
                } header: {
                    categoryChips
                        .padding(.vertical, 8)
                        .background(Color(red: 0.11, green: 0.11, blue: 0.12).opacity(0.85).background(.ultraThinMaterial))
                }
            }
            .padding(.bottom, 24)
        }
    }

    private var filteredFilms: [Film] {
        library.films.filter { film in
            (category == nil || film.category == category) &&
            (searchText.isEmpty ||
             film.displayName.localizedStandardContains(searchText) ||
             film.displayCategory.localizedStandardContains(searchText))
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                analogCategoryChip(title: "ALL", value: nil)
                ForEach(library.categories, id: \.self) { cat in
                    analogCategoryChip(title: Film.prettyCategory(cat).uppercased(), value: cat)
                }
            }
            .padding(.horizontal, 14)
        }
    }

    private func analogCategoryChip(title: String, value: String?) -> some View {
        let isSelected = category == value
        return Button {
            withAnimation(.spring(duration: 0.2)) { category = value }
        } label: {
            Text(title)
                .font(.system(size: 11, weight: .heavy))
                .tracking(0.5)
                .foregroundStyle(isSelected ? .black : Color(white: 0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.filmPrimary : Color(white: 0.18))
                .clipShape(.capsule)
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : Color.white.opacity(0.15), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - My Films

    private var myFilms: some View {
        let films = library.myFilms.filter {
            searchText.isEmpty || $0.displayName.localizedStandardContains(searchText)
        }
        return List {
            Section {
                ForEach(films) { film in
                    Button {
                        select(film)
                    } label: {
                        AnalogMyFilmRow(film: film, isSelected: camera.selectedFilmID == film.id)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color(red: 0.15, green: 0.15, blue: 0.16))
                    .swipeActions {
                        Button("Remove", systemImage: "trash", role: .destructive) { remove(film) }
                    }
                }
                .onDelete { offsets in offsets.map { films[$0] }.forEach(remove) }
                .onMove { library.moveMyFilms(from: $0, to: $1) }
            } footer: {
                Text("FILMS IN THIS VAULT APPEAR IN THE CAMERA ROLL STRIP AND WORK OFFLINE.")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(white: 0.5))
            }
        }
        .environment(\.editMode, $editMode)
        .scrollContentBackground(.hidden)
        .overlay {
            if library.myFilms.isEmpty {
                ContentUnavailableView {
                    Label("No Films In Vault", systemImage: "film.stack")
                } description: {
                    Text("Import films from Rolls Film to load them into your analog camera.")
                } actions: {
                    Button("BROWSE ROLLS FILM") { scope = .explore }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.filmPrimary)
                        .clipShape(.capsule)
                }
            }
        }
    }

    // MARK: - Actions

    private var downloadAllTitle: String {
        let films = library.notYetDownloaded(filteredFilms)
        let size = ByteCountFormatter.string(fromByteCount: Int64(films.count) * FilmLibrary.approximateBytesPerFilm, countStyle: .file)
        let scopeName = category.map { " \(Film.prettyCategory($0))" } ?? ""
        return films.count == 1
            ? "Import 1\(scopeName) film (\(size))?"
            : "Import \(films.count)\(scopeName) films (\(size))?"
    }

    private var errorBinding: Binding<Bool> {
        Binding {
            library.errorMessage != nil
        } set: { isPresented in
            if !isPresented { library.errorMessage = nil }
        }
    }

    private func select(_ film: Film) {
        Task {
            guard await library.download(film) else { return }
            await camera.selectFilm(film, lutURL: library.lutURL(for: film))
            if isSearchFocused || isSearchPresented {
                isSearchFocused = false
                isSearchPresented = false
                try? await Task.sleep(for: .milliseconds(400))
            }
            dismiss()
        }
    }

    private func remove(_ film: Film) {
        if camera.selectedFilmID == film.id {
            Task { await camera.selectFilm(nil, lutURL: nil) }
        }
        library.remove(film)
    }
}

// MARK: - Classic Analog Canister Card

private struct AnalogFilmCanisterCard: View {
    @Environment(FilmLibrary.self) private var library
    @Environment(CameraModel.self) private var camera
    let film: Film
    var onSelect: () -> Void

    var body: some View {
        let isDownloading = library.downloading.contains(film.id)
        let isOwned = library.isInMyFilms(film)
        let isSelected = camera.selectedFilmID == film.id

        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 6) {
                // Film negative frame with sprocket notches
                ZStack {
                    // Vintage film frame border
                    Color(red: 0.08, green: 0.08, blue: 0.09)
                        .aspectRatio(3 / 4, contentMode: .fit)

                    FilmThumbnail(url: library.thumbnailURL(for: film))
                        .aspectRatio(3 / 4, contentMode: .fill)

                    // Film type label at top edge
                    VStack {
                        HStack {
                            Text(film.displayCategory.uppercased())
                                .font(.system(size: 7, weight: .heavy))
                                .tracking(0.5)
                                .foregroundStyle(Color.black)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1.5)
                                .background(Color.filmPrimary.opacity(0.95))
                                .clipShape(.rect(cornerRadius: 2))
                            Spacer()
                        }
                        .padding(5)
                        Spacer()
                    }

                    // Download / Active Badge
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            badge(isDownloading: isDownloading, isOwned: isOwned, isSelected: isSelected)
                                .padding(5)
                        }
                    }
                }
                .clipShape(.rect(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            isSelected ? Color.filmPrimary : Color.white.opacity(0.18),
                            lineWidth: isSelected ? 2.5 : 1
                        )
                )
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)

                // Classic film label typography
                VStack(alignment: .leading, spacing: 1) {
                    Text(film.displayName.uppercased())
                        .font(.system(size: 10, weight: .heavy))
                        .lineLimit(1)
                        .foregroundStyle(isSelected ? Color.filmPrimary : Color(white: 0.95))

                    Text(film.displayCategory)
                        .font(.system(size: 8, weight: .medium))
                        .lineLimit(1)
                        .foregroundStyle(Color(white: 0.5))
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(isDownloading)
        .contextMenu {
            Button(isOwned ? "Use Film" : "Import & Use", systemImage: isOwned ? "camera" : "arrow.down.circle", action: onSelect)
            if !isOwned {
                Button("Import", systemImage: "arrow.down.to.line") {
                    Task { await library.download(film) }
                }
            } else {
                Button("Remove from My Films", systemImage: "minus.circle", role: .destructive) {
                    if camera.selectedFilmID == film.id {
                        Task { await camera.selectFilm(nil, lutURL: nil) }
                    }
                    library.remove(film)
                }
            }
        }
    }

    @ViewBuilder
    private func badge(isDownloading: Bool, isOwned: Bool, isSelected: Bool) -> some View {
        Group {
            if isDownloading {
                ProgressView().tint(.white).controlSize(.mini)
            } else if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.filmPrimary)
            } else if isOwned {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(Color.white)
            } else {
                Image(systemName: "arrow.down")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(Color.white)
            }
        }
        .frame(width: 20, height: 20)
        .background(Color.black.opacity(0.75))
        .clipShape(.circle)
        .overlay(Circle().strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5))
    }
}

private struct AnalogMyFilmRow: View {
    @Environment(FilmLibrary.self) private var library
    let film: Film
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            FilmThumbnail(url: library.thumbnailURL(for: film))
                .aspectRatio(3 / 4, contentMode: .fill)
                .frame(width: 44, height: 58)
                .clipShape(.rect(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(isSelected ? Color.filmPrimary : Color.white.opacity(0.2), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(film.displayName.uppercased())
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(isSelected ? Color.filmPrimary : Color(white: 0.95))
                Text(film.displayCategory.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(Color(white: 0.5))
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.filmPrimary)
                    .font(.system(size: 18))
            }
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
    }
}

private struct BulkDownloadBar: View {
    let progress: BulkDownloadProgress
    var onCancel: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ProgressView(value: progress.fraction) {
                Text("IMPORTING FILMS")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(Color.filmPrimary)
            } currentValueLabel: {
                Text("\(progress.completed) / \(progress.total)")
                    .font(.system(size: 10, weight: .bold).monospacedDigit())
                    .foregroundStyle(.white)
            }
            .tint(Color.filmPrimary)

            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Color(white: 0.25))
                    .clipShape(.circle)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(red: 0.16, green: 0.16, blue: 0.18))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 3)
    }
}
