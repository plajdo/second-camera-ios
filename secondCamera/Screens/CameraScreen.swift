//
//  CameraScreen.swift
//  secondCamera
//
//  Created by Filip Šašala on 15/05/2023.
//

import AVFoundation
import SwiftUI
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

struct CameraScreen: View {

    @ObservedObject var viewModel: CameraViewModel
    @StateObject private var cameraSession = CameraSession()

    var body: some View {
        ZStack {
            Camera(session: cameraSession)
                .ignoresSafeArea(.all)

            VStack {
                Spacer()

                bottomBar
            }
        }
    }

    private var bottomBar: some View {
        ZStack {
            Glass()
                .ignoresSafeArea(.all)
                .frame(height: 140)

            HStack {
                NavigationLink(value: Gallery(location: viewModel.location), label: {
                    Icon(.photoStack)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .padding(32)
                        .shadow(radius: 2)
                })

                Button(action: {
                    Task {
                        let photo = try! await cameraSession.takePhoto()
                        viewModel.savePhoto(photo)
                    }
                }, label: {
                    Circle()
                        .strokeBorder(lineWidth: 6, antialiased: true)
                        .foregroundColor(Color.white)
                        .background { Color.gray.opacity(0.4).clipShape(Circle()) }
                        .frame(height: 90)
                })
                .shadow(radius: 4)

                Button(action: {
                    Task { try await cameraSession.rotateCamera() }
                }, label: {
                    Icon(.switchCamera)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .padding(32)
                })
                .shadow(radius: 2)
            }
        }
    }

}

struct LocationPickerScreen_Previews: PreviewProvider {

    static var previews: some View {
        CameraScreen(viewModel: CameraViewModel(location: Location()))
            .previewInterfaceOrientation(.portrait)
            .previewDisplayName("Portrait")

        CameraScreen(viewModel: CameraViewModel(location: Location()))
            .previewInterfaceOrientation(.landscapeRight)
            .previewDisplayName("Landscape")
    }

}
