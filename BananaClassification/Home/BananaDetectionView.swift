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
    @State private var showingCredits = false
    let viewModel = DetailsViewModel()
    
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
                Button("More Details") {
                    showingCredits.toggle()
                }
            }
        }
        .onAppear {
            cameraManager.setupCamera { result in
                detectionResult = result
                viewModel.selectedCategory = result
            }
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
