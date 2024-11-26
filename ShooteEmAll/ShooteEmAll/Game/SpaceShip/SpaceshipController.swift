//
//  SpaceshipController.swift
//  ShooteEmAll
//
//  Created by Quidich on 26/11/24.
//

import RealityKit
import SwiftUI
import RealityKitContent

class SpaceshipController: Movable, Shootable {
    static let shared = SpaceshipController()
    private(set) var spaceship: Entity?
    var speed: Float = 0.2
    private var shieldActive: Bool = false
    private var fireRateMultiplier: Float = 1.0
    
    private init() {}
    
    func setupSpaceship(sceneAnchor: AnchorEntity) async {
        spaceship = try? await Entity(named: "spaceship", in: realityKitContentBundle)
        guard let spaceship = spaceship else { return }
        
        spaceship.position = SIMD3<Float>(0, 0, 0)
        sceneAnchor.addChild(spaceship)
    }
    
    func move(to targetPosition: SIMD3<Float>) {
        guard let spaceship = spaceship else { return }
        let clampedX = min(max(targetPosition.x, -5), 5)
        let clampedY = min(max(targetPosition.y, -5), 5)
        spaceship.position = SIMD3<Float>(
            x: spaceship.position.x + (clampedX - spaceship.position.x) * speed,
            y: spaceship.position.y + (clampedY - spaceship.position.y) * speed,
            z: spaceship.position.z
        )
    }
    
    func fire() {
        guard let spaceship = spaceship, ProjectileController.shared.canFire else { return }
        let projectile = ModelEntity(mesh: MeshResource.generateCylinder(height: 1, radius: 0.1))
        projectile.position = spaceship.position
        projectile.position.y += 0.3 // Slightly above the spaceship
        projectile.transform.rotation = simd_quatf(angle: .pi * 0.5, axis: SIMD3<Float>(1, 0, 0))
        ProjectileController.shared.addProjectile(projectile)
    }
    
    func activateShield() {
        shieldActive = true
            // Add visual shield effect
        print("Shield activated!")
    }
    
    func deactivateShield() {
        shieldActive = false
            // Remove shield effect
        print("Shield deactivated!")
    }
    
    func applyFireRateBoost(multiplier: Float, duration: TimeInterval) {
        fireRateMultiplier = multiplier
        ProjectileController.shared.adjustFireRate(by: fireRateMultiplier)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.resetFireRate()
        }
    }
    
    private func resetFireRate() {
        fireRateMultiplier = 1.0
        ProjectileController.shared.adjustFireRate(by: fireRateMultiplier)
    }
    
    func reset() {
        spaceship?.removeFromParent()
        spaceship = nil
        shieldActive = false
        fireRateMultiplier = 1.0
    }
}
