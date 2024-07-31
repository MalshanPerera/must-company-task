//
//  CameraHandler.swift
//  Runner
//
//  Created by Malshan Perera on 2024-07-31.
//
import Cocoa
import AVFoundation
import FlutterMacOS

class CameraHandler: NSObject, FlutterPlugin, AVCapturePhotoCaptureDelegate {
    
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var captureDevice: AVCaptureDevice?
    var photoCaptureCompletion: ((String?) -> Void)?
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "camera_macos", binaryMessenger: registrar.messenger)
        let instance = CameraHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkPermission":
            checkPermission(result: result)
        case "initCamera":
            initCamera(result: result)
        case "takePicture":
            takePicture(result: result)
        case "closeCamera":
            closeCamera(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func checkPermission(result: @escaping FlutterResult) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            result("authorized")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                result(granted ? "authorized" : "denied")
            }
        case .denied, .restricted:
            result("denied")
        @unknown default:
            result("unknown")
        }
    }
    
    private func initCamera(result: @escaping FlutterResult) {
        guard #available(macOS 10.15, *) else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "macOS version is lower than 10.15", details: nil))
            return
        }
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            result(FlutterError(code: "CAMERA_ERROR", message: "No video device found", details: nil))
            return
        }
        
        captureDevice = device
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            } else {
                result(FlutterError(code: "CAMERA_ERROR", message: "Cannot add camera input", details: nil))
                return
            }
            
            photoOutput = AVCapturePhotoOutput()
            if captureSession?.canAddOutput(photoOutput!) == true {
                captureSession?.addOutput(photoOutput!)
            } else {
                result(FlutterError(code: "CAMERA_ERROR", message: "Cannot add photo output", details: nil))
                return
            }
            
            captureSession?.startRunning()
            result("Camera initialized successfully")
        } catch {
            result(FlutterError(code: "CAMERA_ERROR", message: "Error initializing camera: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func takePicture(result: @escaping FlutterResult) {
        guard #available(macOS 10.15, *), let photoOutput = photoOutput else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "macOS version is lower than 10.15 or photo output not initialized", details: nil))
            return
        }
        
        // Create AVCapturePhotoSettings with the desired format
        let settings: AVCapturePhotoSettings
        if photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        } else if let firstAvailableCodecType = photoOutput.availablePhotoCodecTypes.first {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: firstAvailableCodecType])
        } else {
            settings = AVCapturePhotoSettings()
        }
        
        photoCaptureCompletion = { filePath in
            if let path = filePath {
                result(path)
            } else {
                result(FlutterError(code: "CAMERA_ERROR", message: "Failed to capture photo", details: nil))
            }
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @available(macOS 10.15, *)
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            photoCaptureCompletion?(nil)
            return
        }
        
        guard let photoData = photo.fileDataRepresentation() else {
            print("No photo data resource")
            photoCaptureCompletion?(nil)
            return
        }
        
        do {
            let downloadsDirectory = try FileManager.default.temporaryDirectory
            let photoURL = downloadsDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            
            try photoData.write(to: photoURL)
            photoCaptureCompletion?(photoURL.path)
        } catch {
            print("Error saving photo: \(error)")
            photoCaptureCompletion?(nil)
        }
    }
    
    private func closeCamera(result: @escaping FlutterResult) {
        guard let captureSession = captureSession else {
            result(FlutterError(code: "CAMERA_ERROR", message: "No active capture session found", details: nil))
            return
        }
        
        captureSession.stopRunning()
        
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        
        for output in captureSession.outputs {
            captureSession.removeOutput(output)
        }
        
        self.captureSession = nil
        self.photoOutput = nil
        self.captureDevice = nil
        
        result("Camera session closed")
    }
}
