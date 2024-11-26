//
//  PowerUp.swift
//  ShooteEmAll
//
//  Created by Quidich on 26/11/24.
//

import SwiftUI
import Combine
import RealityKit
import RealityKitContent


enum PowerUpType {
    case shield
    case doubleFireRate
    case extraPoints
}


class PowerUp {
    let entity: Entity
    let type: PowerUpType
    
    init(entity: Entity, type: PowerUpType) {
        self.entity = entity
        self.type = type
    }
    
    func applyEffect(to spaceshipController: SpaceshipController) {
        switch type {
        case .shield:
            spaceshipController.activateShield()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak spaceshipController] in
                spaceshipController?.deactivateShield()
            }
        case .doubleFireRate:
            spaceshipController.applyFireRateBoost(multiplier: 2.0, duration: 5)
        case .extraPoints:
            GameManager.shared.score += 50
        }
    }
}
