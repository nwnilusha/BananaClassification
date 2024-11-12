//
//  BananaDetectionView.swift
//  BananaClassification
//
//  Created by Nilusha Niwanthaka Wimalasena on 5/11/24.
//

import SwiftUI
import AVFoundation
import Vision
import CoreML

struct BananaDetectionView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var detectionResult: String = "Detecting..."
    
    var body: some View {
        ZStack {
            CameraPreview(cameraManager: cameraManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Text(detectionResult)
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
                detectionResult = result
            }
        }
    }
}

// Camera preview setup for SwiftUI
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
