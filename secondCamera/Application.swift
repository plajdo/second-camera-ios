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
                    .navigationDestination(for: String.self, destination: { location in
                        CameraScreen()
                    })
            }
        }
    }

}
