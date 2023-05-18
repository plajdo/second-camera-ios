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

protocol WithPhotoManager {

    var photoManager: PhotoManager { get }

}

protocol WithFileManager {

    var fileManager: FileManager { get }

}

final class DependencyContainer: ObservableObject,
                                 WithCacheManager,
                                 WithPhotoManager,
                                 WithFileManager {

    var cacheManager: CacheManager = .init()
    var photoManager: PhotoManager = .init()
    var fileManager: FileManager = .init()

}
