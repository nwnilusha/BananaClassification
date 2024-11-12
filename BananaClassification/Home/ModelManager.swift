//
//  ModelManager.swift
//  BananaClassification
//
//  Created by Nilusha Niwanthaka Wimalasena on 8/11/24.
//

import Foundation
import SwiftUI
import CoreML
import AVFoundation
import Vision

class ModelManager {
    
    private var detectionRequest: VNCoreMLRequest?
    private var qualityModel: VNCoreMLModel?
    
    func setupModels() {
        // Load pre-trained object detection model (e.g., MobileNetV2)
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            detectionRequest = VNCoreMLRequest(model: model) { [weak self] request, error in
                self?.handleObjectDetection(request: request, error: error, completion: self?.completion)
            }
        }
        
        // Load the custom banana quality model
        if let qualityModel = try? VNCoreMLModel(for: BananaClassifierModel().model) {
            self.qualityModel = qualityModel
        }
        
//        guard let qualityModel = try? VNCoreMLModel(for: BananaClassifierModel().model) else {
//            predictionResult = "Failed to load model"
//            return
//        }
    }
    
    // For handling CMSampleBuffer (video frames)
    func performDetection(on sampleBuffer: CMSampleBuffer, completion: @escaping (String) -> Void) {
        guard let detectionRequest = detectionRequest else {
            completion("Detection model not loaded")
            return
        }
        
        self.completion = completion
        self.latestSampleBuffer = sampleBuffer
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        do {
            try handler.perform([detectionRequest])
        } catch {
            completion("Error processing frame")
        }
    }
    
    // For handling UIImage (e.g., .jpg and .png images)
    func performDetection(on image: UIImage, completion: @escaping (String) -> Void) {
        guard let detectionRequest = detectionRequest else {
            completion("Detection model not loaded")
            return
        }
        
        self.completion = completion
        
        guard let ciImage = CIImage(image: image) else {
            completion("Error: Unable to create CIImage")
            return
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([detectionRequest])
        } catch {
            completion("Error processing image")
        }
    }
    
    private func handleObjectDetection(request: VNRequest, error: Error?, completion: ((String) -> Void)?) {
        guard let results = request.results as? [VNClassificationObservation],
              let topResult = results.first else {
            completion?("No banana found")
            return
        }
        
        if topResult.identifier.contains("banana") {
            analyzeBananaQuality(completion: completion)
        } else {
            completion?("No banana found")
        }
    }
    
    private func analyzeBananaQuality(completion: ((String) -> Void)?) {
        guard let qualityModel = qualityModel else {
            completion?("Quality model not loaded")
            return
        }
        
        guard let latestSampleBuffer = latestSampleBuffer else {
            completion?("No frame available")
            return
        }
        
        let request = VNCoreMLRequest(model: qualityModel) { request, _ in
            if let results = request.results as? [VNClassificationObservation],
               let bestResult = results.first {
                completion?("Quality: \(bestResult.identifier)")
            } else {
                completion?("Quality analysis failed")
            }
        }
        
        let handler = VNImageRequestHandler(cmSampleBuffer: latestSampleBuffer, options: [:])
        try? handler.perform([request])
    }
    
    private var completion: ((String) -> Void)?
    private var latestSampleBuffer: CMSampleBuffer?
}

