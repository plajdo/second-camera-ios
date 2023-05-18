//
//  LocationsViewModel.swift
//  secondCamera
//
//  Created by Filip Šašala on 19/05/2023.
//

import Foundation
import SharedObject

final class LocationsViewModel: ObservableObject {

    @SharedObject(C.dependencyContainer) var di: DependencyContainer

    @Published var locations: [Location] = [] {
        didSet { di.cacheManager.update(locations: locations) }
    }

    init() {
        self.locations = di.cacheManager.savedLocations
    }

}
