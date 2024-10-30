//
//  HomeView.swift
//  BananaClassification
//
//  Created by Nilusha Niwanthaka Wimalasena on 15/10/24.
//

import SwiftUI
import AVFoundation
import Vision
import CoreML

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var recognizedObject: String = "Recognizing..."

    var body: some View {
        ZStack {
            CameraPreview(cameraManager: cameraManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Text(cameraManager.recognisedObject)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .font(.title2)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .onAppear {
            cameraManager.setupCamera { result in
                switch result {
                case .success(let name):
                    recognizedObject = name
                case .failure(let error):
                    recognizedObject = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
