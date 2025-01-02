//
//  SplashScreenView.swift
//  BananaClassification
//
//  Created by Nilusha Niwanthaka Wimalasena on 6/11/24.
//

import Foundation
import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            Color.yellow
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Banana Quality Detector")
                    .font(.headline)
                    .foregroundColor(.black)
                Image("BananaImage")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isActive = true
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            MainScreenView()
        }
    }
}
