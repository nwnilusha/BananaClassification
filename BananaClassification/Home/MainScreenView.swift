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
                                .foregroundColor(.black)
                            Text("Capture Video")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 150)
                        .background(Color.white)
                        .cornerRadius(20)
                    }

                    NavigationLink(destination: UploadPhotoView()) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                                .foregroundColor(.black)
                            Text("Upload Photo")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 150)
                        .background(Color.white)
                        .cornerRadius(20)
                    }
                    
                    NavigationLink(destination: SendImageView()) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                                .foregroundColor(.black)
                            Text("Send Image")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 150)
                        .background(Color.white)
                        .cornerRadius(20)
                    }

                }
                .navigationTitle("Banana Quality Detector")
            }
        }
    }
}
