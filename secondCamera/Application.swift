//
//  secondCameraApp.swift
//  secondCamera
//
//  Created by Filip Šašala on 15/05/2023.
//

import SwiftUI
import SharedObject

@main
struct Application: App {

    @SharedObject(C.dependencyContainer) var di = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LocationsScreen()
                    .navigationDestination(for: Location.self, destination: { location in
                        CameraScreen(viewModel: CameraViewModel(location: location))
                    })
                    .navigationDestination(for: Gallery.self, destination: { gallery in
                        GalleryScreen(viewModel: GalleryViewModel(gallery: gallery))
                    })
            }
        }
    }

}
