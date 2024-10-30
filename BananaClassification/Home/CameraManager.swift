//
//  CameraManager.swift
//  BananaClassification
//
//  Created by Nilusha Niwanthaka Wimalasena on 22/10/24.
//

import SwiftUI
import AVFoundation
import Vision
import CoreML

class CameraManager: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    let objectRecognitionQueue = DispatchQueue(label: "ObjectRecognitionQueue")
    
    private var request: VNCoreMLRequest?
    
    @Published var recognisedObject: String = "Recognising"
    
    override init() {
        super.init()
        setupModel()
    }
    
    // Set up the Vision Model for object recognition
    private func setupModel() {
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            request = VNCoreMLRequest(model: model, completionHandler: handleRecognition)
        } else {
            print("Failed to load the model.")
        }
    }
    
    func setupCamera(completion: @escaping (Result<String, Error>) -> Void) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            completion(.failure(CameraError.cameraNotAvailable))
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)

            videoOutput.setSampleBufferDelegate(self, queue: objectRecognitionQueue)
            captureSession.addOutput(videoOutput)
            captureSession.startRunning()
        } catch {
            completion(.failure(error))
        }
    }
    
    private func handleRecognition(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation], let firstResult = results.first else {
            print("No results")
            return
        }
        
        DispatchQueue.main.async {
            self.recognisedObject = firstResult.identifier
            print("Recognized: \(firstResult.identifier)")
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request!])
        } catch {
            print("Failed to perform object recognition: \(error.localizedDescription)")
        }
    }
}
