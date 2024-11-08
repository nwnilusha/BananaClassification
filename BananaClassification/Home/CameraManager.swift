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
    
    private var latestBuffer: CMSampleBuffer?
    private var modelManager = ModelManager()
    private var completion: ((String) -> Void)?
    
    override init() {
        super.init()
        modelManager.setupModels()
    }
    
    func setupCamera(completion: @escaping (String) -> Void) {
        self.completion = completion
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            completion("Error: Camera not available")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)

            videoOutput.setSampleBufferDelegate(self, queue: objectRecognitionQueue)
            captureSession.addOutput(videoOutput)
            captureSession.startRunning()
        } catch {
            completion("Error: \(error.localizedDescription)")
        }
    }
    
    private func updateUI(with message: String) {
        DispatchQueue.main.async {
            self.completion?(message)
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.latestBuffer = sampleBuffer
        guard let latestBuffer = latestBuffer else { return }
        
        modelManager.performDetection(on: latestBuffer) { [weak self] result in
            self?.updateUI(with: result)
        }
    }
}
