//
//  Camera.swift
//  secondCamera
//
//  Created by Filip Šašala on 15/05/2023.
//

import AVFoundation
import SwiftUI

struct Camera: UIViewRepresentable {

    let session: CameraSession

    func makeUIView(context: Context) -> CameraView {
        return CameraView(session: session)
    }

    func updateUIView(_ uiView: CameraView, context: Context) {}

    static func dismantleUIView(_ uiView: CameraView, coordinator: ()) {
        Task { try await uiView.cameraSession.currentSession().stopRunning() }
    }

}

// MARK: - UIKit CameraView

final class CameraView: UIView {

    let cameraSession: CameraSession

    private var zoom: CGFloat = 1

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    private var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    init(session: CameraSession) {
        self.cameraSession = session

        super.init(frame: .zero)
        self.backgroundColor = .black

        setupZoomPinchGesture()

        Task {
            await setupCameraSession()
            await setupPreviewLayer()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not available")
    }

    private func setupCameraSession() async {
        let authorized = await cameraSession.checkAuthorization()
        if authorized {
            try! await cameraSession.initialize()
        }
    }

    private func setupPreviewLayer() async {
        previewLayer.session = try! await cameraSession.currentSession()
        previewLayer.frame = bounds
        previewLayer.videoGravity = .resizeAspectFill
    }

}

// MARK: - Zooming gesture

private extension CameraView {

    func setupZoomPinchGesture() {
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureAction(gesture:)))
        addGestureRecognizer(gesture)
    }

    @objc func pinchGestureAction(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed:
            Task(priority: .userInitiated, operation: {
                try await cameraSession.zoom(to: gesture.scale * zoom)
            })

        case .ended:
            zoom *= gesture.scale

        default:
            break
        }
    }

}
