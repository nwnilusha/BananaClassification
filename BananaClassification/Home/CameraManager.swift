//
//  CameraManager.swift
//  BananaClassification
//
//  Created by Nilusha Niwanthaka Wimalasena on 22/10/24.
//

import Foundation
import AVFoundation
import TensorFlowLite
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let inferenceQueue = DispatchQueue(label: "InferenceQueue")
    private var completion: ((Result<String, Error>) -> Void)?
    private var interpreter: Interpreter?
    
    override init() {
        super.init()
        setupModel()
    }
    
    // Load the TFLite model
    private func setupModel() {
        guard let modelPath = Bundle.main.path(forResource: "banana_classifier_model", ofType: "tflite") else {
            print("Failed to load the TFLite model.")
            return
        }
        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter?.allocateTensors()
        } catch {
            print("Error loading model: \(error)")
        }
    }
    
    func setupCamera(completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            completion(.failure(CameraError.cameraNotAvailable))
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)

            videoOutput.setSampleBufferDelegate(self, queue: inferenceQueue)
            captureSession.addOutput(videoOutput)
            captureSession.startRunning()
            
            // Notify setup success
            completion(.success("Camera setup successful"))
        } catch {
            completion(.failure(error))
        }
    }
    
    private func classifyImage(pixelBuffer: CVPixelBuffer) {
        guard let interpreter = interpreter else { return }
        
        // Preprocess image to 150x150, matching input size
        let image = UIImage(pixelBuffer: pixelBuffer)
        let resizedImage = image?.resize(to: CGSize(width: 150, height: 150))
        guard let inputTensor = try? interpreter.input(at: 0) else { return }
        
        // Convert image to RGB data and copy it into input tensor
        guard let rgbData = resizedImage?.rgbData() else { return }
        try? interpreter.copy(rgbData, toInputAt: 0)
        
        // Run inference
        do {
            try interpreter.invoke()
            let outputTensor = try interpreter.output(at: 0)
            let results = [Float](unsafeData: outputTensor.data) // Assuming output shape is [4]
            
            // Find the banana state with the highest probability
            let states = ["Overripe", "Ripe", "Rotten", "Unripe"]
            if let maxIndex = results.enumerated().max(by: { $0.element < $1.element })?.offset {
                DispatchQueue.main.async {
                    self.completion?(.success(states[maxIndex]))
                }
            }
        } catch {
            print("Failed to classify image: \(error)")
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        classifyImage(pixelBuffer: pixelBuffer)
        usleep(1_000_000) // Delay by 1 second
    }
}
