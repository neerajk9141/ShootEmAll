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
    private var fireRateMultiplier: Float = 1.0
        // Rotation and control parameters
    private let maxRotationDegrees: Float = 60.0
    private let rotationSpeed: Float = 0.05
    private let smoothingFactor: Float = 0.1
    
    var currentYaw: Float = 0.0
    var currentPitch: Float = 0.0
    
    var speed: Float = 5.0
    let maxSpeed: Float = 10.0
    let minSpeed: Float = 1.0
    private init() {}
    
    @MainActor
    func setupSpaceship(sceneAnchor: AnchorEntity) async -> Entity? {
        if let spaceship = try? await Entity(named: "spaceship", in: realityKitContentBundle) {
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
    
    func handleGestureInput(joystickInput: SIMD2<Float>, isFiring: Bool, sceneAnchor: AnchorEntity) {
        updateSteering(joystickInput: joystickInput)
        if isFiring {
//            fire(sceneAnchor: sceneAnchor)
        }
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
    
    func fire(sceneAnchor: AnchorEntity) {
        guard let spaceship = spaceship, ProjectileController.shared.canFire else { return }
        
            // Calculate the forward vector based on spaceship's current orientation
        let forwardVector = spaceship.transform.matrix.columns.2
        let normalizedForward = normalize(SIMD3<Float>(forwardVector.x, forwardVector.y, forwardVector.z))
        
            // Set the starting position of the projectile
        let projectileStart = spaceship.position + normalizedForward * 0.5
        
            // Create a projectile entity
        let projectile = ModelEntity(
            mesh: MeshResource.generateCylinder(height: 0.5, radius: 0.05),
            materials: [SimpleMaterial(color: .red, isMetallic: false)]
        )
        projectile.position = projectileStart
        
            // Set the orientation to match the spaceship
        projectile.orientation = spaceship.orientation
        
            // Add projectile and move it
        ProjectileController.shared.addProjectile(projectile, direction: normalizedForward, sceneAnchor: sceneAnchor)
        ProjectileController.shared.moveProjectile(projectile, direction: normalizedForward, sceneAnchor: sceneAnchor)
    }
    
//    func fire(sceneAnchor: AnchorEntity) {
//        guard let spaceship = spaceship, ProjectileController.shared.canFire else { return }
//        
//            // Calculate the forward vector
//        let forwardVector = normalize(SIMD3<Float>(
//            spaceship.transform.matrix.columns.2.x,
//            spaceship.transform.matrix.columns.2.y,
//            spaceship.transform.matrix.columns.2.z
//        ))
//        
//            // Spawn the projectile at the spaceship's position, facing forward
//        let projectileStart = spaceship.position + forwardVector * 0.5
//        let projectile = ModelEntity(
//            mesh: MeshResource.generateCylinder(height: 0.5, radius: 0.05),
//            materials: [SimpleMaterial(color: .red, isMetallic: false)]
//        )
//        projectile.position = projectileStart
//        projectile.orientation = spaceship.orientation
//        
//            // Add projectile and move it
//        ProjectileController.shared.addProjectile(projectile, direction: forwardVector, sceneAnchor: sceneAnchor)
//        ProjectileController.shared.moveProjectile(projectile, direction: forwardVector, sceneAnchor: sceneAnchor)
//    }
    
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
//        ProjectileController.shared.adjustFireRate(by: fireRateMultiplier)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.resetFireRate()
        }
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
}
