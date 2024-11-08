//
//  UploadPhotoView.swift
//  BananaClassification
//
//  Created by Nilusha Niwanthaka Wimalasena on 6/11/24.
//

import SwiftUI
import CoreML
import Vision
import PhotosUI

struct UploadPhotoView: View {
    
    @StateObject private var cameraManager = CameraManager()
    @State private var detectionResult: String = "Detecting..."
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var predictionResult: String = "Select an image to analyze"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Upload Photo for Banana Quality Check")
                .font(.title2)
                .padding()
            
            // Display selected image
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 300, height: 300)
                    .cornerRadius(10)
                    .overlay(Text("No image selected").foregroundColor(.gray))
            }
            
            // Button to open image picker
            Button("Select Image") {
                showImagePicker = true
            }
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            // Button to run model on selected image
            Button("Check Banana Quality") {
                if let image = selectedImage {
                    checkBananaQuality(for: image)
                } else {
                    predictionResult = "Please select an image first"
                }
            }
            .font(.headline)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            // Display prediction result
            Text(predictionResult)
                .font(.headline)
                .padding()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .padding()
    }
    
    // Function to check banana quality using CoreML model
    private func checkBananaQuality(for image: UIImage) {
        guard let model = try? VNCoreMLModel(for: BananaClassifierModel().model) else {
            predictionResult = "Failed to load model"
            return
        }
        
        guard let ciImage = CIImage(image: image) else {
            predictionResult = "Invalid image format"
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation],
               let firstResult = results.first {
                DispatchQueue.main.async {
                    predictionResult = "Result: \(firstResult.identifier) with confidence \(firstResult.confidence * 100)%"
                }
            } else {
                predictionResult = "No result from model"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            predictionResult = "Error performing request: \(error.localizedDescription)"
        }
    }
}

// ImagePicker for selecting image from photo library
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
}
