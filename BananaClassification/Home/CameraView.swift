//
//  CameraView.swift
//  BananaClassification
//
//  Created by Nilusha Niwanthaka Wimalasena on 31/10/24.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var bananaState: String = "Analyzing..."

    var body: some View {
        ZStack {
            CameraPreview(cameraManager: cameraManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Text(bananaState)
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
                case .success(let state):
                    bananaState = state
                case .failure(let error):
                    bananaState = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

// SwiftUI UIViewControllerRepresentable to show the camera
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

// Helper extensions for UIImage processing
extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func rgbData() -> Data? {
        guard let cgImage = self.cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        let byteCount = width * height * 3
        var rgbData = Data(count: byteCount)
        
        rgbData.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) in
            if let context = CGContext(data: pointer.baseAddress,
                                       width: width,
                                       height: height,
                                       bitsPerComponent: 8,
                                       bytesPerRow: width * 3,
                                       space: CGColorSpaceCreateDeviceRGB(),
                                       bitmapInfo: CGImageAlphaInfo.none.rawValue) {
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        }
        return rgbData
    }
}

