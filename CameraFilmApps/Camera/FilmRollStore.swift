//
//  FilmRollStore.swift
//  CameraFilmApps
//

import SwiftUI
import Observation
import Photos

@Observable
final class FilmRollStore: @unchecked Sendable {
    static let shared = FilmRollStore()

    private(set) var photos: [RollPhoto] = []
    private(set) var latestThumbnail: UIImage?

    private let fileManager = FileManager.default
    private let storeDirectory: URL
    private let thumbsDirectory: URL
    private let indexFileURL: URL
    private let memoryCache = NSCache<NSString, UIImage>()

    private init() {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        self.storeDirectory = appSupport.appending(path: "FilmRoll", directoryHint: .isDirectory)
        self.thumbsDirectory = storeDirectory.appending(path: "Thumbs", directoryHint: .isDirectory)
        self.indexFileURL = storeDirectory.appending(path: "roll_index.json")

        try? fileManager.createDirectory(at: storeDirectory, withIntermediateDirectories: true)

        // Clear legacy squished thumbnail cache so existing photos re-generate with precise 3:4 aspect ratio
        let v2ThumbMarker = storeDirectory.appending(path: ".thumbs_v2")
        if !fileManager.fileExists(atPath: v2ThumbMarker.path) {
            try? fileManager.removeItem(at: thumbsDirectory)
            try? fileManager.createDirectory(at: thumbsDirectory, withIntermediateDirectories: true)
            fileManager.createFile(atPath: v2ThumbMarker.path, contents: nil)
        } else {
            try? fileManager.createDirectory(at: thumbsDirectory, withIntermediateDirectories: true)
        }

        loadIndex()
        updateLatestThumbnail()
    }

    // MARK: - File URLs

    func photoURL(for photo: RollPhoto) -> URL {
        storeDirectory.appending(path: photo.fileName)
    }

    func thumbnailURL(for photo: RollPhoto) -> URL {
        thumbsDirectory.appending(path: photo.fileName)
    }

    // MARK: - Image Retrieval

    func thumbnail(for photo: RollPhoto) -> UIImage? {
        let key = photo.fileName as NSString
        if let cached = memoryCache.object(forKey: key) {
            return cached
        }
        let url = thumbnailURL(for: photo)
        if let image = UIImage(contentsOfFile: url.path) {
            memoryCache.setObject(image, forKey: key)
            return image
        }
        // Fallback: load full image and generate thumbnail preserving exact aspect ratio
        if let full = fullImage(for: photo) {
            let thumb = full.makeThumbnail(maxPixelDimension: 600)
            memoryCache.setObject(thumb, forKey: key)
            if let thumbData = thumb.jpegData(compressionQuality: 0.88) {
                try? thumbData.write(to: url, options: .atomic)
            }
            return thumb
        }
        return nil
    }

    func fullImage(for photo: RollPhoto) -> UIImage? {
        let url = photoURL(for: photo)
        if let data = try? Data(contentsOf: url),
           let img = UIImage(data: data) {
            return img
        }
        return UIImage(contentsOfFile: url.path)
    }

    func fileData(for photo: RollPhoto) -> Data? {
        let url = photoURL(for: photo)
        return try? Data(contentsOf: url)
    }

    // MARK: - Add Photo

    @discardableResult
    func addPhoto(data: Data, thumbnail: UIImage, filmName: String) async -> RollPhoto {
        let id = UUID()
        let fileName = "\(id.uuidString).jpg"
        let fullURL = storeDirectory.appending(path: fileName)
        let thumbURL = thumbsDirectory.appending(path: fileName)

        // Save high-resolution photo file
        try? data.write(to: fullURL, options: .atomic)

        // Ensure thumbnail is baked in upright orientation with preserved aspect ratio
        let uprightThumb = thumbnail.makeThumbnail(maxPixelDimension: 600)
        if let thumbData = uprightThumb.jpegData(compressionQuality: 0.88) {
            try? thumbData.write(to: thumbURL, options: .atomic)
        }
        memoryCache.setObject(uprightThumb, forKey: fileName as NSString)

        let newPhoto = RollPhoto(
            id: id,
            date: Date(),
            fileName: fileName,
            filmName: filmName,
            isSavedToPhotos: false
        )

        await MainActor.run {
            self.photos.insert(newPhoto, at: 0)
            self.latestThumbnail = uprightThumb
            self.saveIndex()
        }

        return newPhoto
    }

    // MARK: - Deletion

    func delete(ids: Set<UUID>) {
        let toDelete = photos.filter { ids.contains($0.id) }
        delete(photos: toDelete)
    }

    func delete(photos toDelete: [RollPhoto]) {
        for photo in toDelete {
            let fullURL = photoURL(for: photo)
            let thumbURL = thumbnailURL(for: photo)
            try? fileManager.removeItem(at: fullURL)
            try? fileManager.removeItem(at: thumbURL)
            memoryCache.removeObject(forKey: photo.fileName as NSString)
        }

        let deleteIDs = Set(toDelete.map(\.id))
        photos.removeAll { deleteIDs.contains($0.id) }
        updateLatestThumbnail()
        saveIndex()
    }

    func deleteAll() {
        delete(photos: photos)
    }

    // MARK: - Save to System Photos (PHPhotoLibrary)

    @discardableResult
    func saveToSystemPhotos(photos toSave: [RollPhoto]) async throws -> Int {
        var savedCount = 0
        for photo in toSave {
            if let data = fileData(for: photo) {
                try await PhotoWriter.saveToLibrary(data)
                savedCount += 1
                await MainActor.run {
                    if let index = self.photos.firstIndex(where: { $0.id == photo.id }) {
                        self.photos[index].isSavedToPhotos = true
                    }
                }
            }
        }
        await MainActor.run {
            self.saveIndex()
        }
        return savedCount
    }

    @discardableResult
    func saveAllToSystemPhotos() async throws -> Int {
        try await saveToSystemPhotos(photos: photos)
    }

    // MARK: - Persistence Index

    private func updateLatestThumbnail() {
        if let first = photos.first {
            latestThumbnail = thumbnail(for: first)
        } else {
            latestThumbnail = nil
        }
    }

    private func saveIndex() {
        do {
            let data = try JSONEncoder().encode(photos)
            try data.write(to: indexFileURL, options: .atomic)
        } catch {
            print("Failed to save film roll index:", error)
        }
    }

    private func loadIndex() {
        guard fileManager.fileExists(atPath: indexFileURL.path),
              let data = try? Data(contentsOf: indexFileURL),
              let saved = try? JSONDecoder().decode([RollPhoto].self, from: data)
        else {
            photos = []
            return
        }
        photos = saved
    }
}
