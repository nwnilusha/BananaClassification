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
                guard let sampleBuffer = self?.latestSampleBuffer else { return }
                self?.handleObjectDetection(request: request, error: error, sampleBuffer: sampleBuffer, completion: self?.completion)
            }
        }
        
        // Load the custom banana quality model
        if let qualityModel = try? VNCoreMLModel(for: BananaClassifierModel().model) {
            self.qualityModel = qualityModel
        }
    }
    
    func performDetection(on sampleBuffer: CMSampleBuffer, completion: @escaping (String) -> Void) {
        guard let detectionRequest = detectionRequest else {
            completion("Detection model not loaded")
            return
        }
        
        // Store the completion handler and sample buffer for later use in the detection
        self.completion = completion
        self.latestSampleBuffer = sampleBuffer
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        do {
            try handler.perform([detectionRequest])
        } catch {
            completion("Error processing frame")
        }
    }
    
    private func handleObjectDetection(request: VNRequest, error: Error?, sampleBuffer: CMSampleBuffer, completion: ((String) -> Void)?) {
        guard let results = request.results as? [VNClassificationObservation],
              let topResult = results.first else {
            completion?("No banana found")
            return
        }
        
        if topResult.identifier.contains("banana") {
            analyzeBananaQuality(on: sampleBuffer, completion: completion)
        } else {
            completion?("No banana found")
        }
    }
    
    private func analyzeBananaQuality(on sampleBuffer: CMSampleBuffer, completion: ((String) -> Void)?) {
        guard let qualityModel = qualityModel else {
            completion?("Quality model not loaded")
            return
        }
        
        // Create and perform request using quality model
        let request = VNCoreMLRequest(model: qualityModel) { request, _ in
            if let results = request.results as? [VNClassificationObservation],
               let bestResult = results.first {
                completion?("Quality: \(bestResult.identifier)")
            } else {
                completion?("Quality analysis failed")
            }
        }
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        try? handler.perform([request])
    }
    
    // Temporary storage for completion handler and latest sample buffer
    private var completion: ((String) -> Void)?
    private var latestSampleBuffer: CMSampleBuffer?
}

