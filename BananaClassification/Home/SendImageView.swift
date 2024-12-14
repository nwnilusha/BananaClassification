//
//  SendImageView.swift
//  BananaClassification
//
//  Created by Nilusha Niwanthaka Wimalasena on 16/11/24.
//

import SwiftUI
import Vision

struct SendImageView: View {
    
    private var modelManager = ModelManager()
    @State private var capturedImage: UIImage?
    @State private var isCameraPresented = false
    @State private var isBananaDetected = false
    @State private var selectedStage: String?
    @State private var isSendEnabled = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Banana Quality Detector")
                .font(.title)
                .padding()

            if let image = capturedImage {
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
                    .overlay(Text("No image captured").foregroundColor(.gray))
            }

            Button("Capture Image") {
                isCameraPresented = true
            }
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            if isBananaDetected {
                VStack(spacing: 10) {
                    ForEach(["Barely Ripe", "Ripe", "Over Ripe", "Rotten"], id: \.self) { stage in
                        Button(stage) {
                            selectedStage = stage
                            isSendEnabled = true
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedStage == stage ? Color.green : Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .disabled(selectedStage == stage)
                    }
                }
            }

            if isSendEnabled {
                Button("Send Image") {
                    uploadImageToGitHub()
                }
                .font(.headline)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .onChange(of: capturedImage) { newImage in
            if let image = newImage {
                checkBananaQuality(for: image)
            }
        }
        .sheet(isPresented: $isCameraPresented) {
            ImagePicker(capturedImage: $capturedImage, sourceType: .camera)
        }
        .padding()
    }
    
    private func checkBananaQuality(for image: UIImage) {
        modelManager.setupModelsForImage(qualityDetection: false)
        modelManager.performDetection(on: image) { result in
            DispatchQueue.main.async {
                isBananaDetected = (result == "Found Banana") ? true : false
            }
        }
    }

    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var capturedImage: UIImage?
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
                    parent.capturedImage = image
                }
            }
        }
    }

    private func uploadImageToGitHub() {

    }
}
