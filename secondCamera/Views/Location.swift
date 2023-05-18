//
//  Location.swift
//  secondCamera
//
//  Created by Filip Šašala on 18/05/2023.
//

import Foundation

struct Location: Codable, Hashable, Identifiable {

    var id: String

    var type: LocationType
    var name: String

    init() {
        self.id = UUID().uuidString
        self.name = ""
        self.type = .album
    }

}

enum LocationType: String, Codable, Hashable {

    case album
    case folder

}
