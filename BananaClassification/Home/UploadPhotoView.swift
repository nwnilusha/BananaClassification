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
    @State private var showingCredits = false
    let viewModel = DetailsViewModel()
    
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

            Button("Select Image") {
                showImagePicker = true
            }
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Capture Image") {
                showCamera = true
            }
            .font(.headline)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("More Details") {
                showingCredits.toggle()
            }

            Text(predictionResult)
                .font(.headline)
                .bold()
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
        .sheet(isPresented: $showingCredits) {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Text(viewModel.ripenessStageText)
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(viewModel.currentStage)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 5)
                
                HStack {
                    Text(viewModel.appearanceTitle)
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(viewModel.currentAppearance)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 5)
                
                HStack {
                    Text(viewModel.stageDuration)
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(viewModel.currentDuration)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 5)
                
                HStack {
                    Text(viewModel.healthBenefits)
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(viewModel.currentBenefits)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 5)
            }
            .padding()
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
//        .padding()
    }
    
    private func checkBananaQuality(for image: UIImage) {
        modelManager.setupModelsForImage(qualityDetection: true)
        modelManager.performDetection(on: image) { result in
            print("Image result : \(result)")
            DispatchQueue.main.async {
                let qualityResult = result.split(separator: " ")
                self.predictionResult = "Quality : " + String(qualityResult[1])
                viewModel.selectedCategory = String(qualityResult[1])
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

