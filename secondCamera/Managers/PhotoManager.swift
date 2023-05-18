//
//  PhotoManager.swift
//  secondCamera
//
//  Created by Filip Šašala on 18/05/2023.
//

import Photos

actor PhotoManager {

    func checkAuthorization() async -> Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            let requestResult = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            switch requestResult {
            case .authorized, .limited:
                return true

            default:
                return false
            }

        case .authorized, .limited:
            return true

        case .denied, .restricted:
            return false

        @unknown default:
            return false
        }
    }

    func addPhoto(_ photo: AVCapturePhoto, location: Location) async throws {
        guard location.type == .album else { throw LocationError.invalidType }

        let album = try await album(for: location)
        try await addPhoto(album: album, photo: photo)
    }

    func getAllPhotos(at location: Location) {
        let albumFetchOptions = PHFetchOptions()
        albumFetchOptions.predicate = NSPredicate(format: "title = %@", location.name)

        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: albumFetchOptions)
        albums.enumerateObjects { object, index, stop in
            let photos = PHAsset.fetchAssets(in: object, options: nil)

            photos.enumerateObjects { object, index, stop in
                
            }
        }
    }

}

private extension PhotoManager {

    func album(for location: Location) async throws -> PHAssetCollection {
        guard location.type == .album else { throw LocationError.invalidType }

        var album = fetchAlbum(for: location)
        if let album { return album }

        album = try await createAlbum(for: location)
        if let album { return album }

        throw LocationError.missingAlbum
    }

    func fetchAlbum(for location: Location) -> PHAssetCollection? {
        let albumFetchOptions = PHFetchOptions()
        albumFetchOptions.predicate = NSPredicate(format: "title = %@", location.name)
        albumFetchOptions.fetchLimit = 1

        let results = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: albumFetchOptions)
        if let album = results.firstObject {
            return album
        }

        return nil
    }

    func createAlbum(for location: Location) async throws -> PHAssetCollection? {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: location.name)
        }

        return fetchAlbum(for: location)
    }

}


private extension PhotoManager {

    func addPhoto(album: PHAssetCollection, photo: AVCapturePhoto) async throws {
        guard let photoData = photo.fileDataRepresentation() else { throw PHPhotosError(.invalidResource) }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                let saveOptions = PHAssetResourceCreationOptions()
                saveOptions.shouldMoveFile = true

                let saveRequest = PHAssetCreationRequest.forAsset()
                saveRequest.addResource(with: .photo, data: photoData, options: saveOptions)

                let albumSaveRequest = PHAssetCollectionChangeRequest(for: album)
                albumSaveRequest?.addAssets(NSArray(array: [saveRequest.placeholderForCreatedAsset!]))
            }
        } catch {
            print("Failed to save photo")
        }
    }

}
