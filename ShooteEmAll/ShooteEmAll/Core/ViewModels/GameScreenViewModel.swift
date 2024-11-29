//
//  GameScreenViewModel.swift
//  ShooteEmAll
//
//  Created by Quidich on 29/11/24.
//

import Combine
import SwiftUI

class GameSceneViewModel: ObservableObject {
    @Published var targetPosition: SIMD3<Float> = SIMD3<Float>(0, 0, -5.0)
    @Published var difficultyLevel: DifficultyLevel = .easy
    
    func updateTargetPosition(x: Float, y: Float) {
        targetPosition.x += x
        targetPosition.y += y
    }
}
