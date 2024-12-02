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


class PowerUp {
    let entity: Entity
    let type: PowerUpType
    
    init(entity: Entity, type: PowerUpType) {
        self.entity = entity
        self.type = type
    }
    
    func updatePosition() {
        entity.position.z += 0.1 // Adjust speed as needed
    }
}

extension PowerUp: Equatable {
    static func == (lhs: PowerUp, rhs: PowerUp) -> Bool {
        return lhs.entity == rhs.entity
    }
}

extension PowerUp {
    func applyEffect(to spaceshipController: SpaceshipController) {
        switch type {
        case .shield:
            spaceshipController.activateShield()
            
        case .doubleFireRate:
            spaceshipController.applyFireRateBoost(multiplier: 2.0, duration: 5)
            
        case .extraPoints:
            GameManager.shared.addScore(points: 50)
            
        case .healing:
            GameManager.shared.heal(amount: 30)
            
        case .multiProjectile:
            spaceshipController.enableMultiShot(duration: 5)
            
        case .damageBoost:
            spaceshipController.applyDamageBoost(multiplier: 2.0, duration: 5)
        }
    }
}
