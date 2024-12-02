//
//  Enums.swift
//  ShooteEmAll
//
//  Created by Quidich on 26/11/24.
//

import Foundation

enum DifficultyLevel: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var enemySpawnRate: TimeInterval {
        switch self {
        case .easy: return 5.0
        case .medium: return 3.0
        case .hard: return 1.5
        }
    }
}

enum ProjectileType {
    case laser
    case missile
    case plasma
}

enum PowerUpType: CaseIterable {
    case shield
    case doubleFireRate
    case extraPoints
    case healing
    case multiProjectile
    case damageBoost
}

