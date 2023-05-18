//
//  Gallery.swift
//  secondCamera
//
//  Created by Filip Šašala on 18/05/2023.
//

import Foundation

struct Gallery: Hashable, Identifiable {

    var id: String {
        location.id
    }

    let location: Location

}
