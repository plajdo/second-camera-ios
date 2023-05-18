//
//  CacheManager.swift
//  secondCamera
//
//  Created by Filip Šašala on 18/05/2023.
//

import GoodPersistence

final class CacheManager {

    @UserDefaultValue("locations", defaultValue: [])
    var savedLocations: [Location]

}

extension CacheManager {

    func saveLocation(_ location: Location) {
        savedLocations.append(location)
    }

    func removeLocation(_ location: Location) {
        savedLocations.removeAll { location == $0 }
    }

}
