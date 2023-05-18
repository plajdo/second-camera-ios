//
//  Location.swift
//  secondCamera
//
//  Created by Filip Šašala on 18/05/2023.
//

import Foundation

enum LocationError: Error {

    case invalidType
    case invalidFolder
    case missingAlbum

}

struct Location: Codable, Hashable, Identifiable {

    var id: String

    var type: LocationType
    var name: String

    init() {
        self.id = UUID().uuidString
        self.name = ""
        self.type = .folder
    }

}

extension Location {

    func path() {
        
    }

}

enum LocationType: String, Codable, Hashable {

    case album
    case folder

    var localizedName: String {
        switch self {
        case .album:
            return "Album"

        case .folder:
            return "Priečinok"
        }
    }

    var icon: Icon {
        switch self {
        case .album:
            return Icon(.album)

        case .folder:
            return Icon(.folder)
        }
    }

}
