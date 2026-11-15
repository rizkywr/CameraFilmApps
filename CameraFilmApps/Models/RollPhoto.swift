//
//  RollPhoto.swift
//  CameraFilmApps
//

import Foundation

struct RollPhoto: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let date: Date
    let fileName: String
    let filmName: String
    var isSavedToPhotos: Bool

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        fileName: String,
        filmName: String,
        isSavedToPhotos: Bool = false
    ) {
        self.id = id
        self.date = date
        self.fileName = fileName
        self.filmName = filmName
        self.isSavedToPhotos = isSavedToPhotos
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}
