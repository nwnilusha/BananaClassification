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
    
    private var modelManager = ModelManager()
    @State private var detectionResult: String = "Detecting..."
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var predictionResult: String = "Select an image to analyze"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Upload Photo for Banana Quality Check")
                .font(.title2)
                .padding()
            
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
            
            // Button to capture image from camera
            Button("Capture Image") {
                showCamera = true
            }
            .font(.headline)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            // Display prediction result
            Text(predictionResult)
                .font(.headline)
                .padding()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                checkBananaQuality(for: image)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
        .padding()
    }
    
    private func checkBananaQuality(for image: UIImage) {
        modelManager.setupModelsForImage(qualityDetection: true)
        modelManager.performDetection(on: image) { result in
            DispatchQueue.main.async {
                self.predictionResult = result
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
        }
    }
}

