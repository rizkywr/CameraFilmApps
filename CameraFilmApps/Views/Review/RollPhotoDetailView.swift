//
//  RollPhotoDetailView.swift
//  CameraFilmApps
//

import SwiftUI
import Photos

struct RollPhotoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FilmRollStore.self) private var rollStore

    let photo: RollPhoto
    let skin: CameraSkin
    var onDelete: () -> Void

    @State private var image: UIImage?
    @State private var isSaving = false
    @State private var isSaved: Bool
    @State private var showDeleteAlert = false
    @State private var toastMessage: String?

    init(photo: RollPhoto, skin: CameraSkin, onDelete: @escaping () -> Void) {
        self.photo = photo
        self.skin = skin
        self.onDelete = onDelete
        _isSaved = State(initialValue: photo.isSavedToPhotos)
    }

    var body: some View {
        ZStack {
            // Adaptive vintage camera leather background
            LeatherBackground(skin: skin)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Vintage Navigation Bar
                topBar

                // Center: High-Resolution Clean Photo Display (No frame, clean full preview)
                ZStack {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.7), radius: 12, x: 0, y: 6)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    } else {
                        ProgressView()
                            .tint(Color.filmPrimary)
                            .scaleEffect(1.3)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom Action Bar
                bottomBar
            }

            // Toast overlay
            if let toastMessage {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.filmPrimary)
                        Text(toastMessage)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.85))
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(Color.filmPrimary.opacity(0.6), lineWidth: 1))
                    .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
                    .padding(.bottom, 100)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .task {
            image = rollStore.fullImage(for: photo)
        }
        .alert("Delete Photo?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
                dismiss()
            }
        } message: {
            Text("This photo will be removed from your film roll.")
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Invisible balance spacer so title remains centered
            Color.clear
                .frame(width: 36, height: 36)

            Spacer()

            VStack(spacing: 2) {
                Text(photo.filmName.capitalized)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.filmPrimary)

                Text("\(photo.formattedDate) • \(photo.formattedTime)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(white: 0.7))
            }

            Spacer()

            // Close (X) Button
            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 16) {
            // Delete Button
            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                showDeleteAlert = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("Delete")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color(red: 0.95, green: 0.35, blue: 0.35))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(red: 0.25, green: 0.08, blue: 0.08).opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(red: 0.8, green: 0.2, blue: 0.2).opacity(0.5), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            // Save to Photos Button
            Button {
                guard !isSaving else { return }
                Task {
                    isSaving = true
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    do {
                        _ = try await rollStore.saveToSystemPhotos(photos: [photo])
                        withAnimation {
                            isSaved = true
                            toastMessage = "Saved To Gallery"
                        }
                        let successGen = UINotificationFeedbackGenerator()
                        successGen.notificationOccurred(.success)
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation { toastMessage = nil }
                    } catch {
                        withAnimation { toastMessage = "Save Failed" }
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation { toastMessage = nil }
                    }
                    isSaving = false
                }
            } label: {
                HStack(spacing: 6) {
                    if isSaving {
                        ProgressView()
                            .tint(.black)
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text(isSaved ? "Saved" : "Save to Photos")
                            .font(.system(size: 13, weight: .bold))
                    }
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.filmPrimary.opacity(0.9), Color.filmPrimary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: Color.filmPrimary.opacity(0.4), radius: 6, y: 2)
            }
            .buttonStyle(.plain)
            .disabled(isSaving)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(Color.black.opacity(0.35))
    }
}
