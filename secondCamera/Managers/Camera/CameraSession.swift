//
//  CameraSession.swift
//  secondCamera
//
//  Created by Filip Šašala on 15/05/2023.
//

import AVFoundation
import SwiftUI

enum CameraError: Error {

    case notInitialized
    case notSupported

    case noSuchDevice
    case invalidDevice

}

enum CameraSessionType {

    case photo
    case video

}

actor CameraSession: ObservableObject {

    private var captureSession: AVCaptureSession?

    private weak var videoInput: AVCaptureDeviceInput? // {
//        willSet {
//            guard let videoInput else { return }
//            captureSession?.removeInput(videoInput)
//
//            guard let newValue else { return }
//            captureSession?.addInput(newValue)
//        }
//    }

    var autoresume: Bool = true
    var type: CameraSessionType = .photo

    init() {
        Task { await signUpForNotificationCentre() }
    }

    // MARK: - Initialization

    func initialize() throws {
        captureSession = AVCaptureSession()

        guard let captureDevice = AVCaptureDevice.default(for: .video) else { throw CameraError.noSuchDevice }
        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else { throw CameraError.invalidDevice }
        guard let captureSession else { throw CameraError.notInitialized }

        guard captureSession.canAddInput(captureInput) else { throw CameraError.invalidDevice }
        captureSession.addInput(captureInput)
        self.videoInput = captureInput

        switch self.type {
        case .photo:
            let photoOutput = AVCapturePhotoOutput()
            guard captureSession.canAddOutput(photoOutput) else { throw CameraError.notSupported }
            captureSession.addOutput(photoOutput)

        case .video:
            break
        }

//        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
//              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
//              let captureSession,
//              captureSession.canAddInput(videoInput),
//              captureSession.canAddOutput(photoOutput)
//        else {
//            print("camera not supported")
//            return
//        }

//        captureSession.addInput(videoInput)
//        captureSession.addOutput(photoOutput)

        // photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings()])
        // metadataOutput.metadataObjectTypes = [.upce, .ean8, .ean13, .dataMatrix, .pdf417, .qr]
        captureSession.startRunning()
    }

    // MARK: - Permissions

    func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true

        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)

        case .denied, .restricted:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Helper functions

    func currentSession() throws -> AVCaptureSession {
        guard let captureSession else { throw CameraError.notInitialized }
        return captureSession
    }

}

// MARK: - Device selection

extension CameraSession {

    func rotateCamera() throws {
        guard let videoInput else { throw CameraError.notInitialized }

        let cameraPosition = videoInput.device.position
        switch cameraPosition {
        case .unspecified, .back:
            try setActiveCamera(.builtInWideAngleCamera, position: .front)

        case .front:
            try setActiveCamera(.builtInWideAngleCamera, position: .back)

        @unknown default:
            break
        }
    }

    func setActiveCamera(_ camera: AVCaptureDevice.DeviceType, position: AVCaptureDevice.Position) throws {
        guard let captureSession else { throw CameraError.notInitialized }
        guard let videoInput else { throw CameraError.notInitialized }

        guard let newDevice = AVCaptureDevice.default(camera, for: .video, position: position) else { throw CameraError.noSuchDevice }
        guard let newInput = try? AVCaptureDeviceInput(device: newDevice) else { throw CameraError.invalidDevice }

        captureSession.removeInput(videoInput)

        guard captureSession.canAddInput(newInput) else { throw CameraError.invalidDevice }
        captureSession.addInput(newInput)

        self.videoInput = newInput
    }

}

// MARK: - Zoom

extension CameraSession {

    func zoom(to scale: CGFloat) throws {
        guard let videoInput else { throw CameraError.notInitialized }

        try videoInput.device.lockForConfiguration()

        let minZoom = videoInput.device.minAvailableVideoZoomFactor
        let maxZoom = videoInput.device.maxAvailableVideoZoomFactor

        let zoom = min(max(scale, minZoom), maxZoom)
        videoInput.device.ramp(toVideoZoomFactor: zoom, withRate: 2.718)
        videoInput.device.unlockForConfiguration()
    }

}

// MARK: - Photo capture

extension CameraSession {

    func takePhoto(codec: AVVideoCodecType? = nil) async throws -> AVCapturePhoto {
        let photoOutput = captureSession!.outputs[0] as! AVCapturePhotoOutput

        guard let codecType = codec ?? photoOutput.availablePhotoCodecTypes.first else {
            throw CameraError.notSupported
        }
        guard photoOutput.availablePhotoCodecTypes.contains(codecType) else { throw CameraError.notSupported }

        let captureDelegate = PhotoCaptureDelegate()
        let captureSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: codecType])

        photoOutput.capturePhoto(with: captureSettings, delegate: captureDelegate)
        return try await captureDelegate.result()
    }

}

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {

    private var continuation: CheckedContinuation<AVCapturePhoto, Error>?

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("Photo captured: \(photo.description)")

        if let error { continuation?.resume(throwing: error) }
        else { continuation?.resume(returning: photo) }
    }

    func result() async throws -> AVCapturePhoto {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

}

// MARK: - Interruption notifications

extension CameraSession {

    func signUpForNotificationCentre() {
        Task {
            let notificationCentre = await NotificationCenter.default.notifications(
                named: UIApplication.didEnterBackgroundNotification
            )

            for await _ in notificationCentre {
                print("App entered background")
                if let captureSession, captureSession.isRunning {
                    captureSession.stopRunning()
                }
            }
        }

        Task {
            let notificationCentre = NotificationCenter.default.notifications(
                named: .AVCaptureSessionWasInterrupted
            )

            for await _ in notificationCentre {
                print("Capture session interrupted")
                if let captureSession, captureSession.isRunning {
                    captureSession.stopRunning()
                }
            }
        }

        guard autoresume else { return }
        Task {
            let notificationCentre = await NotificationCenter.default.notifications(
                named: UIApplication.willEnterForegroundNotification
            )

            for await _ in notificationCentre {
                print("App will enter foreground")
                if let captureSession, !captureSession.isRunning {
                    captureSession.startRunning()
                }
            }
        }

        Task {
            let notificationCentre = NotificationCenter.default.notifications(
                named: .AVCaptureSessionInterruptionEnded
            )

            for await _ in notificationCentre {
                print("Capture session resumed")
                if let captureSession, captureSession.isRunning {
                    captureSession.stopRunning()
                }
            }
        }
    }

}
