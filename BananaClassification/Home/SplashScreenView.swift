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
            Color.yellow // Background color for splash screen
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Banana Quality Detector")
                    .font(.headline)
                    .foregroundColor(.black)
            }
        }
        .onAppear {
            // Navigate to Main Screen after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isActive = true
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            MainScreenView()
        }
    }
}
