//
//  FilmRollReviewView.swift
//  CameraFilmApps
//

import SwiftUI
import Photos

struct FilmRollReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FilmRollStore.self) private var rollStore
    let skin: CameraSkin

    @State private var isSelectionMode = false
    @State private var selectedIDs: Set<UUID> = []
    @State private var activeDetailPhoto: RollPhoto?
    @State private var isSavingBatch = false
    @State private var showDeleteConfirmation = false
    @State private var toastMessage: String?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Adaptive camera leather background matching active skin
                LeatherBackground(skin: skin)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top Navigation Bar
                    headerBar

                    // Subheader Bar (Select All option when in Selection Mode)
                    if isSelectionMode && !rollStore.photos.isEmpty {
                        selectionSubHeaderBar
                    }

                    // Main Content: Photo Grid or Empty State
                    if rollStore.photos.isEmpty {
                        emptyRollView
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(rollStore.photos) { photo in
                                    photoCard(photo)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, isSelectionMode ? 120 : 36)
                        }
                    }
                }

                // Bottom Floating Action Bar (Visible only when in Selection Mode)
                if isSelectionMode && !rollStore.photos.isEmpty {
                    VStack {
                        Spacer()
                        bottomActionBar
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Toast notification
                if let toastMessage {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.filmPrimary)
                            Text(toastMessage)
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.88))
                        .clipShape(Capsule())
                        .overlay(Capsule().strokeBorder(Color.filmPrimary.opacity(0.7), lineWidth: 1))
                        .shadow(color: .black.opacity(0.6), radius: 10, y: 5)
                        .padding(.bottom, isSelectionMode ? 100 : 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $activeDetailPhoto) { photo in
                RollPhotoDetailView(photo: photo, skin: skin) {
                    rollStore.delete(photos: [photo])
                    selectedIDs.remove(photo.id)
                }
                .environment(rollStore)
            }
            .confirmationDialog(
                "Delete Photo?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                let count = selectedIDs.count
                let isAll = count == rollStore.photos.count
                Button(isAll ? "Delete All (\(count))" : "Delete \(count) Photo\(count > 1 ? "s" : "")", role: .destructive) {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    withAnimation(.spring(duration: 0.25)) {
                        if isAll {
                            rollStore.deleteAll()
                        } else {
                            rollStore.delete(ids: selectedIDs)
                        }
                        selectedIDs.removeAll()
                        if rollStore.photos.isEmpty {
                            isSelectionMode = false
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(selectedIDs.count == 1
                     ? "This photo will be removed from your film roll."
                     : "These \(selectedIDs.count) photos will be removed permanently from your film roll.")
            }
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(alignment: .center) {
            // Close / Return Button
            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                dismiss()
            } label: {
                Text("Close")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()

            // Center Title
            VStack(spacing: 2) {
                Text("FILM ROLL REVIEW")
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.filmPrimary)

                Text(isSelectionMode ? "\(selectedIDs.count) OF \(rollStore.photos.count) SELECTED" : "ROLL #01 • \(rollStore.photos.count) FRAMES")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(white: 0.65))
            }

            Spacer()

            // Top Right: "Select" / "Done" Button (Daz Cam Style)
            if !rollStore.photos.isEmpty {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    withAnimation(.spring(duration: 0.25)) {
                        isSelectionMode.toggle()
                        if !isSelectionMode {
                            selectedIDs.removeAll()
                        }
                    }
                } label: {
                    Text(isSelectionMode ? "Done" : "Select")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(isSelectionMode ? Color(white: 0.9) : Color.filmPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            isSelectionMode
                            ? Color.black.opacity(0.6)
                            : Color.black.opacity(0.7)
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().strokeBorder(
                                isSelectionMode ? Color.white.opacity(0.3) : Color.filmPrimary.opacity(0.8),
                                lineWidth: 1.2
                            )
                        )
                }
                .buttonStyle(.plain)
            } else {
                Color.clear.frame(width: 58, height: 32)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(Color.black.opacity(0.3))
    }

    // MARK: - Subheader Bar (Visible only when Select is active)

    private var selectionSubHeaderBar: some View {
        HStack {
            let allSelected = selectedIDs.count == rollStore.photos.count && !rollStore.photos.isEmpty
            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                withAnimation(.spring(duration: 0.2)) {
                    if allSelected {
                        selectedIDs.removeAll()
                    } else {
                        selectedIDs = Set(rollStore.photos.map(\.id))
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: allSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.filmPrimary)
                    Text(allSelected ? "Deselect All" : "Select All (\(rollStore.photos.count))")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.6))
                .clipShape(Capsule())
                .overlay(
                    Capsule().strokeBorder(Color.filmPrimary.opacity(0.6), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Spacer()

            Text("\(selectedIDs.count) selected")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.filmPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.25))
    }

    // MARK: - Photo Card

    private func photoCard(_ photo: RollPhoto) -> some View {
        let isSelected = selectedIDs.contains(photo.id)

        return ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                // Photo Thumbnail
                ZStack {
                    if let thumb = rollStore.thumbnail(for: photo) {
                        Image(uiImage: thumb)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                            .clipped()
                    } else {
                        Color(white: 0.15)
                            .frame(height: 140)
                            .overlay {
                                ProgressView()
                                    .tint(Color.filmPrimary)
                            }
                    }

                    // Vintage film stamp badge (top leading)
                    VStack {
                        HStack {
                            Text(photo.filmName.uppercased())
                                .font(.system(size: 8, weight: .black, design: .monospaced))
                                .foregroundStyle(Color.filmPrimary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.black.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .strokeBorder(Color.filmPrimary.opacity(0.5), lineWidth: 0.7)
                                )
                                .padding(6)
                            Spacer()
                        }
                        Spacer()
                    }
                }

                // Info Footer Strip on Card
                HStack {
                    Text(photo.formattedTime)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(white: 0.7))

                    Spacer()

                    if photo.isSavedToPhotos {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                            Text("SAVED")
                                .font(.system(size: 8, weight: .heavy, design: .monospaced))
                        }
                        .foregroundStyle(Color.green)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.6))
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        (isSelectionMode && isSelected) ? Color.filmPrimary : Color.white.opacity(0.18),
                        lineWidth: (isSelectionMode && isSelected) ? 2.5 : 1
                    )
            )
            .shadow(color: (isSelectionMode && isSelected) ? Color.filmPrimary.opacity(0.3) : .black.opacity(0.5), radius: 5, y: 3)
            .contentShape(.rect)
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                if isSelectionMode {
                    // Selection Mode: toggle this photo
                    withAnimation(.spring(duration: 0.2)) {
                        if isSelected {
                            selectedIDs.remove(photo.id)
                        } else {
                            selectedIDs.insert(photo.id)
                        }
                    }
                } else {
                    // Normal Mode (Daz Cam): Tap directly opens FULL VIEW!
                    activeDetailPhoto = photo
                }
            }
            .onLongPressGesture(minimumDuration: 0.3) {
                // Hold enters Selection Mode and selects this photo
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                withAnimation(.spring(duration: 0.25)) {
                    isSelectionMode = true
                    selectedIDs.insert(photo.id)
                }
            }

            // Selection Checkbox Badge (visible when Select mode is active)
            if isSelectionMode {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.filmPrimary : Color.black.opacity(0.6))
                        .frame(width: 26, height: 26)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white, lineWidth: 1.5)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(.black)
                    }
                }
                .padding(8)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Empty State

    private var emptyRollView: some View {
        VStack(spacing: 16) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: 100, height: 100)
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.15), lineWidth: 1.5))

                Image(systemName: "film.stack")
                    .font(.system(size: 42))
                    .foregroundStyle(Color.filmPrimary)
            }

            Text("NO FRAMES CAPTURED")
                .font(.system(size: 15, weight: .black, design: .monospaced))
                .foregroundStyle(.white)

            Text("Photos taken with the camera will appear here on your film roll.")
                .font(.system(size: 13))
                .foregroundStyle(Color(white: 0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            Spacer()
        }
    }

    // MARK: - Bottom Action Bar (Daz Cam Style: Delete & Save for Selected)

    private var bottomActionBar: some View {
        let count = selectedIDs.count
        let hasSelection = count > 0
        let isAll = count == rollStore.photos.count && count > 1
        let targetPhotos = rollStore.photos.filter { selectedIDs.contains($0.id) }

        return HStack(spacing: 14) {
            // 1. DELETE BUTTON (Red Hardware Style)
            Button {
                guard hasSelection else { return }
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                showDeleteConfirmation = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text(isAll ? "Delete All (\(count))" : (hasSelection ? "Delete (\(count))" : "Delete"))
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(hasSelection ? Color(red: 0.95, green: 0.35, blue: 0.35) : Color.white.opacity(0.3))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    hasSelection
                    ? Color(red: 0.28, green: 0.08, blue: 0.08).opacity(0.92)
                    : Color.black.opacity(0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            hasSelection ? Color(red: 0.85, green: 0.25, blue: 0.25).opacity(0.6) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
            }
            .buttonStyle(.plain)
            .disabled(!hasSelection)

            // 2. SAVE BUTTON (Amber Hardware Style)
            Button {
                guard hasSelection, !isSavingBatch else { return }
                Task {
                    isSavingBatch = true
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    do {
                        let saved = try await rollStore.saveToSystemPhotos(photos: targetPhotos)
                        withAnimation {
                            toastMessage = "\(saved) PHOTO\(saved > 1 ? "S" : "") SAVED TO GALLERY"
                        }
                        let successGen = UINotificationFeedbackGenerator()
                        successGen.notificationOccurred(.success)
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation { toastMessage = nil }
                    } catch {
                        withAnimation { toastMessage = "SAVE FAILED" }
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation { toastMessage = nil }
                    }
                    isSavingBatch = false
                }
            } label: {
                HStack(spacing: 6) {
                    if isSavingBatch {
                        ProgressView()
                            .tint(.black)
                            .scaleEffect(0.9)
                        Text("Saving...")
                            .font(.system(size: 13, weight: .bold))
                    } else {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text(isAll ? "Save All (\(count))" : (hasSelection ? "Save (\(count))" : "Save"))
                            .font(.system(size: 13, weight: .bold))
                    }
                }
                .foregroundStyle(hasSelection ? .black : Color.white.opacity(0.4))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    hasSelection
                    ? LinearGradient(
                        colors: [Color.filmPrimary.opacity(0.95), Color.filmPrimary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    : LinearGradient(
                        colors: [Color.white.opacity(0.15), Color.white.opacity(0.08)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            hasSelection ? Color.white.opacity(0.4) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
                .shadow(color: hasSelection ? Color.filmPrimary.opacity(0.4) : .clear, radius: 8, y: 3)
            }
            .buttonStyle(.plain)
            .disabled(!hasSelection || isSavingBatch)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.1), Color.black.opacity(0.88)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
