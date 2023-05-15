//
//  secondCameraApp.swift
//  secondCamera
//
//  Created by Filip Šašala on 15/05/2023.
//

import SwiftUI

@main
struct Application: App {

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
