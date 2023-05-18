//
//  CameraViewModel.swift
//  secondCamera
//
//  Created by Filip Šašala on 19/05/2023.
//

import AVFoundation
import SharedObject

final class CameraViewModel: ObservableObject {

    @SharedObject(C.dependencyContainer) private var di: DependencyContainer

    private var photoManager: PhotoManager { di.photoManager }
    private var fileManager: FileManager { di.fileManager }

    var location: Location

    init(location: Location) {
        self.location = location
    }

    func savePhoto(_ photo: AVCapturePhoto) {
        switch location.type {
        case .album:
            Task { try? await photoManager.addPhoto(photo, location: location) }

        case .folder:
            guard let data = photo.fileDataRepresentation() else { return }
            try? fileManager.saveData(data, to: location)
        }
    }

}
