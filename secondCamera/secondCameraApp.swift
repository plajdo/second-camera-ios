//
//  secondCameraApp.swift
//  secondCamera
//
//  Created by Filip Šašala on 15/05/2023.
//

import SwiftUI

@main
struct secondCameraApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: secondCameraDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
