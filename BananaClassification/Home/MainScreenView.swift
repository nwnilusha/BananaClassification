//
//  MainScreenView.swift
//  BananaClassification
//
//  Created by Nilusha Niwanthaka Wimalasena on 6/11/24.
//

import Foundation
import SwiftUI

struct MainScreenView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: BananaDetectionView()) {
                    Text("Capture Video")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: UploadPhotoView()) {
                    Text("Upload Photo")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                // 3. Send Image Button
                Button(action: {
                    // Implement action for "Send Image"
                    print("Send Image button tapped")
                }) {
                    Text("Send Image")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Banana Detector")
        }
    }
}
