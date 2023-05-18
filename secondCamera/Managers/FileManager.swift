//
//  FileManager.swift
//  secondCamera
//
//  Created by Filip Šašala on 18/05/2023.
//

import Foundation

final class FileManager {

    func saveData(_ data: Data, to location: Location) throws {
        guard location.type == .folder else { throw LocationError.invalidType }

        let manager = Foundation.FileManager.default
        let documents = manager.urls(for: .documentDirectory, in: .userDomainMask)

        guard let documentFolder = documents.first else { throw LocationError.invalidFolder }
        let albumFolder = documentFolder.appendingPathComponent(location.name, conformingTo: .directory)

        try manager.createDirectory(at: albumFolder, withIntermediateDirectories: true)

        let formatter = DateFormatter()
        formatter.dateFormat = "dd_MM_yyyy_HH_mm_SSSZ"

        let timestamp = formatter.string(from: Date())
        let photoUrl = albumFolder.appendingPathComponent(timestamp, conformingTo: .fileURL)
            .appendingPathExtension(for: .png)

        try data.write(to: photoUrl)
    }

    func getAllFiles(at location: Location) throws -> [URL] {
        guard location.type == .folder else { throw LocationError.invalidType }

        let manager = Foundation.FileManager.default
        let documents = manager.urls(for: .documentDirectory, in: .userDomainMask)

        guard let documentFolder = documents.first else { throw LocationError.invalidFolder }
        let albumFolder = documentFolder.appendingPathComponent(location.name, conformingTo: .directory)

        return try manager.contentsOfDirectory(at: albumFolder, includingPropertiesForKeys: [.pathKey])
    }

}
