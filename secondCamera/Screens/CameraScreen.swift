//
//  CameraScreen.swift
//  secondCamera
//
//  Created by Filip Šašala on 15/05/2023.
//

import SwiftUI

struct CameraScreen: View {

    @StateObject private var cameraSession = CameraSession()
    @State private var capturedImage: CGImage?

    var body: some View {
        ZStack {
            Camera(session: cameraSession)
                .ignoresSafeArea(.all)

            if let capturedImage {
                Image(uiImage: UIImage(cgImage: capturedImage, scale: 1, orientation: .right))
                    .resizable()
            }

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
                Button(action: {
                    print("open gallery")
                }, label: {
                    Icon(.photoStack)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .padding(32)
                })
                .shadow(radius: 2)

                Button(action: {
                    Task {
                        let photo = try! await cameraSession.takePhoto()
                        self.capturedImage = photo.cgImageRepresentation()
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
        CameraScreen()
            .previewInterfaceOrientation(.portrait)
            .previewDisplayName("Portrait")

        CameraScreen()
            .previewInterfaceOrientation(.landscapeRight)
            .previewDisplayName("Landscape")
    }

}
