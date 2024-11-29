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
    
    func addProjectile(_ entity: Entity, direction: SIMD3<Float>, sceneAnchor: AnchorEntity) {
        let projectile = MovableProjectile(entity: entity, speed: 0.5, direction: direction)
        sceneAnchor.addChild(projectile.entity)
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
    
    func checkCollisions(with enemies: [Enemy], onCollision: (Enemy) -> Void) {
        var enemiess = enemies
        for projectile in projectiles {
            for enemy in enemies {
                let distance = simd_distance(projectile.entity.position, enemy.entity.position)
                if distance < 0.5 { // Adjust based on model sizes
                        // Collision detected
                    projectile.entity.removeFromParent()
                    projectiles.removeAll { $0 === projectile }
                    
                    enemy.entity.removeFromParent()
                    enemiess.removeAll { $0 === enemy }
                    
                        // Callback to notify about the destroyed enemy
                    onCollision(enemy)
                    return
                }
            }
        }
    }
    
    func moveProjectile(_ projectile: Entity, direction: SIMD3<Float>, sceneAnchor: AnchorEntity) {
        let speed: Float = 0.1 // Adjust speed as necessary
        
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            let currentPosition = projectile.position
            let newPosition = currentPosition + direction * speed
            
            projectile.position = newPosition
            projectile.transform.rotation = simd_quatf(angle: .pi*0.5, axis: SIMD3<Float>(1,0,0))
                // Remove the projectile if it's too far
            if newPosition.z < -50 {
                timer.invalidate()
                projectile.removeFromParent()
                sceneAnchor.removeChild(projectile)
            }
        }
    }
}

class MovableProjectile: Movable {
    let entity: Entity
    var speed: Float
    var direction: SIMD3<Float>
    
    init(entity: Entity, speed: Float, direction: SIMD3<Float>) {
        self.entity = entity
        self.speed = speed
        self.direction = normalize(direction) // Normalize the direction
    }
    
    func updatePosition() {
            // Move the projectile in the specified direction
        entity.position += direction * speed
    }
    
    var isOffscreen: Bool {
        return entity.position.z < -50 || abs(entity.position.x) > 50 || abs(entity.position.y) > 50
    }
}
