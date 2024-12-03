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
    
    func updatePosition() {
        
    }
    
    static let shared = SpaceshipController()
    private(set) var spaceship: Entity?
    private var shieldActive: Bool = false
    var fireRateMultiplier: Float = 1.0
        // Rotation and control parameters
    private let maxRotationDegrees: Float = 60.0
    private let rotationSpeed: Float = 0.05
    private let smoothingFactor: Float = 0.1
    
    var currentYaw: Float = 0.0
    var currentPitch: Float = 0.0
    
    var speed: Float = 5.0
    let maxSpeed: Float = 10.0
    let minSpeed: Float = 1.0
    
    private(set) var health: Int = 100
    var damageMultiplier: Float = 1.0 // Default damage multiplier
    var isMultiShotEnabled: Bool = false // Determines if multi-shot mode is active

    private init() {}
    
    @MainActor
    func setupSpaceship(sceneAnchor: AnchorEntity) async -> Entity? {
        if let spaceship = try? await Entity(named: "lumanarianShip", in: realityKitContentBundle) {
            if let animation = spaceship.availableAnimations.first {
                spaceship.playAnimation(animation)
            }
            spaceship.components.set(InputTargetComponent())
            spaceship.generateCollisionShapes(recursive: true)
            spaceship.position = SIMD3<Float>(0, 0, -0.1)
            spaceship.scale*=0.4
            spaceship.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0,1,0))
            sceneAnchor.addChild(spaceship)
            self.spaceship = spaceship
            return spaceship
        }
        return nil
    }
    
    func updateSteering(joystickInput: SIMD2<Float>) {
        guard let spaceship = spaceship else { return }
        
            // Calculate pitch and yaw based on joystick input
        let pitchInput = -joystickInput.y * rotationSpeed
        let yawInput = joystickInput.x * rotationSpeed
        
            // Smoothly apply joystick inputs
        currentPitch = lerp(currentPitch, currentPitch + pitchInput, smoothingFactor)
        currentYaw = lerp(currentYaw, currentYaw + yawInput, smoothingFactor)
        
            // Clamp pitch and yaw
        currentPitch = clampScalar(currentPitch, min: -maxRotationDegrees.radians, max: maxRotationDegrees.radians)
        currentYaw = clampScalar(currentYaw, min: -maxRotationDegrees.radians, max: maxRotationDegrees.radians)
        
            // Compute new orientation
        let pitchRotation = simd_quaternion(currentPitch, SIMD3<Float>(1, 0, 0)) // Around x-axis
        let yawRotation = simd_quaternion(currentYaw, SIMD3<Float>(0, 1, 0))     // Around y-axis
        let targetRotation = yawRotation * pitchRotation
        
            // Apply smooth orientation transition
        spaceship.orientation = simd_slerp(spaceship.orientation, targetRotation, 0.2)
    }
    
    func rotate(to: simd_quatf) {
        spaceship?.transform.rotation = to
    }
    
    func fire(sceneAnchor: AnchorEntity, projectileType: ProjectileType){
        Task {
            guard let spaceship = spaceship else { return }
            
                // Forward vector for the spaceship
            let forwardVector = await spaceship.transform.matrix.columns.2
            let normalizedForward = normalize(SIMD3<Float>(forwardVector.x, forwardVector.y, forwardVector.z))
            let startPosition = await spaceship.position + normalizedForward * 0.5
            
                // Fire main projectile
            let mainProjectile = await createProjectile(type: projectileType, position: startPosition, direction: normalizedForward)
            ProjectileController.shared.addProjectile(mainProjectile, direction: normalizedForward, sceneAnchor: sceneAnchor)
            
            if isMultiShotEnabled {
                    // Fire additional projectiles at slight angles
                let offsetAngle: Float = 0.2 // Adjust the angle offset for multi-shot
                let leftDirection = rotateVector(normalizedForward, by: offsetAngle)
                let rightDirection = rotateVector(normalizedForward, by: -offsetAngle)
                
                let leftProjectile = await createProjectile(type: projectileType, position: startPosition, direction: leftDirection)
                let rightProjectile = await createProjectile(type: projectileType, position: startPosition, direction: rightDirection)
                
                ProjectileController.shared.addProjectile(leftProjectile, direction: leftDirection, sceneAnchor: sceneAnchor)
                ProjectileController.shared.addProjectile(rightProjectile, direction: rightDirection, sceneAnchor: sceneAnchor)
            }
        }
    }
    
        /// Create projectiles with different styles
    @MainActor
    private func createProjectile(type: ProjectileType, position: SIMD3<Float>, direction: SIMD3<Float>) async -> ModelEntity {
        let projectile: ModelEntity
        switch type {
        case .laser:
            projectile = ModelEntity(mesh: MeshResource.generateCylinder(height: 0.5, radius: 0.05))
            projectile.model?.materials = [SimpleMaterial(color: .systemTeal, isMetallic: true)]
        case .missile:
            projectile = ModelEntity(mesh: MeshResource.generateBox(size: [0.1, 0.1, 1.0]))
            projectile.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
        case .plasma:
            projectile = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.3))
            var material = PhysicallyBasedMaterial()
            material.emissiveColor = .init(color: .purple)//.init(tint: .purple, intensity: 5.0)
            projectile.model?.materials = [material]
        }
        projectile.position = position
        return projectile
    }
    
    private func resetFireRate() {
        fireRateMultiplier = 1.0
//        ProjectileController.shared.adjustFireRate(by: fireRateMultiplier)
    }
    
    func reset() {
        spaceship?.removeFromParent()
        spaceship = nil
        shieldActive = false
        fireRateMultiplier = 1.0
    }
    
    private func rotateVector(_ vector: SIMD3<Float>, by angle: Float) -> SIMD3<Float> {
        let rotationMatrix = float3x3(simd_quaternion(angle, SIMD3<Float>(0, 1, 0)))
        return simd_mul(rotationMatrix, vector)
    }
}

extension SpaceshipController {
        // Apply power-up effects dynamically
    func applyPowerUpEffect(type: PowerUpType) {
        switch type {
        case .shield:
            activateShield()
        case .doubleFireRate:
            applyFireRateBoost(multiplier: 5.0, duration: 5)
        case .extraPoints:
            GameManager.shared.addScore(points: 50)
        case .healing:
            GameManager.shared.heal(amount: 30)
        case .multiProjectile:
            enableMultiShot(duration: 5)
        case .damageBoost:
            applyDamageBoost(multiplier: 2.0, duration: 5)
        }
    }
    
    func enableMultiShot(duration: TimeInterval) {
        guard !isMultiShotEnabled else { return }
        isMultiShotEnabled = true
        print("Multi-shot enabled!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.isMultiShotEnabled = false
            print("Multi-shot disabled!")
        }
    }
    
    func activateShield() {
        guard !shieldActive else { return }
        shieldActive = true
        print("Shield activated!")
        
            // Add visual feedback for the shield
        let shieldEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.5))
        shieldEntity.model?.materials = [SimpleMaterial(color: .cyan.withAlphaComponent(0.4), isMetallic: true)]
        shieldEntity.position = spaceship?.position ?? .zero
        shieldEntity.name = "Shield"
        spaceship?.addChild(shieldEntity)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            shieldEntity.removeFromParent()
            self?.shieldActive = false
            print("Shield deactivated!")
        }
    }
    
   
    
    func applyFireRateBoost(multiplier: Float, duration: TimeInterval) {
        fireRateMultiplier *= multiplier
        print("Fire rate boosted to \(fireRateMultiplier)x!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.fireRateMultiplier = 1.0
            print("Fire rate reset to normal.")
        }
    }
    
    func applyDamageBoost(multiplier: Float, duration: TimeInterval) {
        damageMultiplier *= multiplier
        print("Damage boosted to \(damageMultiplier)x!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.damageMultiplier = 1.0
            print("Damage reset to normal.")
        }
    }
    
    func deactivateShield() {
        shieldActive = false
            // Remove shield effect
        print("Shield deactivated!")
    }
    
}
