//
//  DetailsViewModel.swift
//  BananaClassification
//
//  Created by Nilusha Niwanthaka Wimalasena on 14/12/24.
//

import Foundation

class DetailsViewModel: ObservableObject {
    @Published var selectedCategory: String = "unripe"

    private let bananaData: [String: (stage: String, appearance: String, duration: String, benefits: String)] = [
        "underripe": (
            stage: "Underripe",
            appearance: "Very firm; dark green to medium-green",
            duration: "1-4 days",
            benefits: "Improves blood sugar control, promotes gut health, helps with weight loss"
        ),
        "barelyripe": (
            stage: "Barely Ripe",
            appearance: "Firm; Pale yellow with light green at the top",
            duration: "1-3 days",
            benefits: "High in fiber, low in carbs, promotes blood suger control"
        ),
        "ripe": (
            stage: "Ripe",
            appearance: "Firm with vibrant yellow color and brown spots",
            duration: "2-5 days",
            benefits: "Rich in antioxidants, promotes digestion, boosts energy"
        ),
        "overripe": (
            stage: "Overripe",
            appearance: "Soft with significant brown spots or fully brown",
            duration: "1-2 days",
            benefits: "Great for baking, high sugar content, easy to digest"
        ),
        "rotten": (
            stage: "Rotten",
            appearance: "Dark brown or black spts",
            duration: "-",
            benefits: "Can use as animal food"
        )
    ]

    var ripenessStageText: String { "Ripeness Stage" }
    var appearanceTitle: String { "Appearance" }
    var stageDuration: String { "Stage Duration" }
    var healthBenefits: String { "Health Benefits" }

    var currentStage: String { bananaData[selectedCategory]?.stage ?? "No Results" }
    var currentAppearance: String { bananaData[selectedCategory]?.appearance ?? "No Results" }
    var currentDuration: String { bananaData[selectedCategory]?.duration ?? "No Results" }
    var currentBenefits: String { bananaData[selectedCategory]?.benefits ?? "No Results" }
}

