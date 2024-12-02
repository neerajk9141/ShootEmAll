//
//  Enemy.swift
//  ShooteEmAll
//
//  Created by Quidich on 26/11/24.
//

import RealityKit
import SwiftUI

class Enemy: Movable {
    let entity: Entity
    var speed: Float
    var pointValue: Int
    var health: Int // Add health property

    var isOffscreen: Bool {
        return entity.position.z >= 0
    }
    
    init(entity: Entity, pointValue: Int, speed: Float, health: Int = 1) {
        self.entity = entity
        self.pointValue = pointValue
        self.speed = speed
        self.health = health
    }
    
    func updatePosition() {
        entity.position.z += speed
        if entity.position.z >= 0 { // Offscreen or reaches the spaceship
            entity.removeFromParent()
        }
    }
}
