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
    
    @Published var boundingBoxes: [CGRect] = []
    
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
    
    private var detectionRequest: VNCoreMLRequest?
        
        private func setupVisionModel() {
            guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else { return }
            
            detectionRequest = VNCoreMLRequest(model: model) { [weak self] request, error in
                self?.processDetections(request: request, error: error)
            }
            
            detectionRequest?.imageCropAndScaleOption = .scaleFill
        }
        
        private func processDetections(request: VNRequest, error: Error?) {
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                DispatchQueue.main.async {
                    self.boundingBoxes = []
                    self.completion?("No objects detected")
                }
                return
            }
            
            DispatchQueue.main.async {
                // Update bounding boxes for each detected object
                self.boundingBoxes = results.map { $0.boundingBox }
                self.completion?("\(results.count) objects detected")
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
