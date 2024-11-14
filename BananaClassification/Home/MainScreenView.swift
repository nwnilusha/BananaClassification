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
            ZStack {
                Color.yellow
                    .edgesIgnoringSafeArea(.all)
                    .opacity(2.0)
                
                VStack(spacing: 20) {
                    NavigationLink(destination: BananaDetectionView()) {
                        HStack {
                            Image(systemName: "video.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                                .foregroundColor(.white)
                            Text("Capture Video")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 180)
                        .background(Color.blue)
                        .cornerRadius(20)
                    }

                    NavigationLink(destination: UploadPhotoView()) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                                .foregroundColor(.white)
                            Text("Upload Photo")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 180)
                        .background(Color.green)
                        .cornerRadius(20)
                    }

                    Button(action: {
                        print("Send Image button tapped")
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                                .foregroundColor(.white)
                            Text("Send Image")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 180)
                        .background(Color.orange)
                        .cornerRadius(20)
                    }
                }
                .navigationTitle("Banana Quality Detector")
            }
        }
    }
}
