//
//  SendImageView.swift
//  BananaClassification
//
//  Created by Nilusha Niwanthaka Wimalasena on 16/11/24.
//

import SwiftUI
import Vision
import MessageUI

struct SendImageView: View {
    
    private var modelManager = ModelManager()
    @State private var capturedImage: UIImage?
    @State private var isCameraPresented = false
    @State private var isBananaDetected = false
    @State private var selectedStage: String?
    @State private var isSendEnabled = false
    @State private var isMailPresented = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil

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
                isSendEnabled = false
                selectedStage = nil
            }
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            if isBananaDetected {
                VStack(spacing: 10) {
                    HStack {
                        ForEach(["Under Ripe", "Barely Ripe", "Ripe"], id: \.self) { stage in
                            Button(stage) {
                                selectedStage = stage
                                isSendEnabled = true
                            }
                            .font(.headline)
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .background(selectedStage == stage ? Color.green : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .disabled(selectedStage == stage)
                        }
                    }
                    HStack {
                        ForEach(["Over Ripe", "Rotten"], id: \.self) { stage in
                            Button(stage) {
                                selectedStage = stage
                                isSendEnabled = true
                            }
                            .font(.headline)
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .background(selectedStage == stage ? Color.green : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .disabled(selectedStage == stage)
                        }
                    }
                }
            }

            if isSendEnabled {
                Button("Send Image") {
                    sendEmailWithImage()
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
        .sheet(isPresented: $isMailPresented) {
            MailView(isPresented: $isMailPresented, result: $mailResult, capturedImage: capturedImage, selectedStage: self.selectedStage ?? "No Stage Selected")
        }
        .padding()
    }
    
    private func checkBananaQuality(for image: UIImage) {
        modelManager.setupModelsForImage(qualityDetection: false)
        modelManager.performDetection(on: image) { result in
            DispatchQueue.main.async {
                print("Banana Detected : \(result)")
                isBananaDetected = (result == "Banana Detected") ? true : false
            }
        }
    }

    private func sendEmailWithImage() {
        guard MFMailComposeViewController.canSendMail() else {
            print("Mail services are not available")
            return
        }
        isMailPresented = true
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
}

struct MailView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    var capturedImage: UIImage?
    var selectedStage: String

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = context.coordinator
        mail.setToRecipients(["nnw.nilusha@gmail.com"])
        mail.setSubject("Banana Quality Detection Result - \(selectedStage)")
        mail.setMessageBody("Find the attached image.", isHTML: false)

        if let imageData = capturedImage?.jpegData(compressionQuality: 0.8) {
            mail.addAttachmentData(imageData, mimeType: "image/jpeg", fileName: "banana.jpg")
        }

        return mail
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                parent.result = .failure(error)
            } else {
                parent.result = .success(result)
            }
            parent.isPresented = false
            controller.dismiss(animated: true)
        }
    }
}

