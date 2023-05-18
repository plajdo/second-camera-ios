//
//  DependencyContainer.swift
//  secondCamera
//
//  Created by Filip Šašala on 18/05/2023.
//

import Foundation

protocol WithCacheManager {

    var cacheManager: CacheManager { get }

}

final class DependencyContainer: ObservableObject, WithCacheManager {

    var cacheManager: CacheManager = .init()

}
