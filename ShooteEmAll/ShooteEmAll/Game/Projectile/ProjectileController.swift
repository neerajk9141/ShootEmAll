//
//  ProjectileController.swift
//  ShooteEmAll
//
//  Created by Quidich on 26/11/24.
//

import SwiftUI
import Combine
import RealityKit
import RealityKitContent


class ProjectileController {
    static let shared = ProjectileController()
    private var projectiles: [MovableProjectile] = []
    private let maxProjectiles = 15
    private var fireRate: Float = 1.0
    
    var canFire: Bool {
        projectiles.count < maxProjectiles
    }
    
    private init() {}
    
    func addProjectile(_ entity: Entity) {
        let projectile = MovableProjectile(entity: entity, speed: -0.5)
        projectiles.append(projectile)
    }
    
    func updateProjectiles() {
        for projectile in projectiles {
            projectile.updatePosition()
            if projectile.isOffscreen {
                projectiles.removeAll { $0 === projectile }
            }
        }
    }
    
    func adjustFireRate(by multiplier: Float) {
        fireRate *= multiplier
        print("Fire rate adjusted to: \(fireRate)x")
    }
    
    func reset() {
        projectiles.forEach { $0.entity.removeFromParent() }
        projectiles.removeAll()
        fireRate = 1.0
    }
}

class MovableProjectile: Movable {
    let entity: Entity
    var speed: Float
    
    init(entity: Entity, speed: Float) {
        self.entity = entity
        self.speed = speed
    }
    
    func updatePosition() {
        entity.position.z += speed
    }
    
    var isOffscreen: Bool {
        return entity.position.z < -50
    }
}
