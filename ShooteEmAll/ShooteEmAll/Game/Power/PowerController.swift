//
//  PowerController.swift
//  ShooteEmAll
//
//  Created by Quidich on 26/11/24.
//

import SwiftUI
import Combine
import RealityKit
import RealityKitContent
import RealityGeometries
import AVFoundation

class PowerUpController {
    static let shared = PowerUpController()
    private var powerUps: [PowerUp] = []
    private var spawnTimer: AnyCancellable?
    private let spawnInterval: TimeInterval = 10.0 // Spawn a power-up every 10 seconds

    private init() {}
    
    @MainActor
    func startSpawning(sceneAnchor: AnchorEntity) {
        spawnTimer?.cancel()
        spawnTimer = Timer.publish(every: 10.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let randomType = PowerUpType.allCases.randomElement()!
                let powerUp = PowerUpFactory.createPowerUp(type: randomType)
                let randomX = Float.random(in: -5...5)
                let randomY = Float.random(in: -3...3)
                powerUp.entity.position = SIMD3<Float>(randomX, randomY, -25)
                sceneAnchor.addChild(powerUp.entity)
                self.powerUps.append(powerUp)
            }
    }
    
    func updatePowerUps() {
        for powerUp in powerUps {
            powerUp.updatePosition()
        }
    }
    
        /// Check for collisions between the spaceship and power-ups
    func checkCollisions(with projectiles: [MovableProjectile], applyEffect: (PowerUp, MovableProjectile) -> Void) {
        for powerUp in powerUps {
            for projectile in projectiles {
                if simd_distance(powerUp.entity.position, projectile.entity.position) < 0.3 {
                    applyEffect(powerUp, projectile)
                    powerUp.entity.removeFromParent()
                    powerUps.removeAll { $0 === powerUp }
                }
            }
        }
    }
    
        /// Reset power-ups
    func reset() {
        powerUps.forEach { $0.entity.removeFromParent() }
        powerUps.removeAll()
        spawnTimer?.cancel()
    }
}


class PowerUpFactory {
    static func createPowerUp(type: PowerUpType) -> PowerUp {
        let powerUpEntity: ModelEntity
        
        switch type {
        case .shield:
            powerUpEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.3))
            powerUpEntity.model?.materials = [SimpleMaterial(color: .blue, isMetallic: true)]
        case .doubleFireRate:
            powerUpEntity = ModelEntity(mesh: MeshResource.generateBox(size: [0.3, 0.3, 0.3]))
            powerUpEntity.model?.materials = [SimpleMaterial(color: .red, isMetallic: true)]
        case .extraPoints:
            powerUpEntity = ModelEntity(mesh: try! RealityGeometry.generateCylinder(radius: 0.2, height: 0.6))
            powerUpEntity.model?.materials = [SimpleMaterial(color: .green, isMetallic: true)]
        case .healing:
            powerUpEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.2))
            powerUpEntity.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: true)]
        case .multiProjectile:
            powerUpEntity = ModelEntity(mesh: MeshResource.generateBox(size: [0.2, 0.2, 0.2]))
            powerUpEntity.model?.materials = [SimpleMaterial(color: .purple, isMetallic: true)]
        case .damageBoost:
            powerUpEntity = ModelEntity(mesh: try! RealityGeometry.generateTorus(sides: 3, csSides: 2, radius: 0.2, csRadius: 0.2))
            powerUpEntity.model?.materials = [SimpleMaterial(color: .orange, isMetallic: true)]
        }
        
        addParticleEffect(to: powerUpEntity) // Add particle effects
        Task {
            await addSpatialSound(to: powerUpEntity, type: type) // Add spatial sound
        }
        
        return PowerUp(entity: powerUpEntity, type: type)
    }
    
    private static func addParticleEffect(to entity: ModelEntity) {
        var particleEmitter = ParticleEmitterComponent()
        particleEmitter.emitterShape = .sphere
        particleEmitter.mainEmitter.birthRate = 50
        particleEmitter.mainEmitter.lifeSpan = 1.5
        particleEmitter.speed = .init(0.2)
        particleEmitter.mainEmitter.color = .constant(.random(a: .white, b: .orange))
        entity.components.set(particleEmitter)
    }
    
    private static func addSpatialSound(to entity: ModelEntity, type: PowerUpType) async {
//        guard let url = Bundle.main.url(forResource: "powerupSound", withExtension: "mp3") else { return }
        let audioName: String = "powerupSound.mp3"
            /// The configuration to loop the audio file continously.
        let configuration = AudioFileResource.Configuration(shouldLoop: true)
            // Load the audio source and set its configuration.
        guard let audio = try? AudioFileResource.load(
            named: audioName,
            configuration: configuration
        ) else {
            print("Failed to load audio file.")
            return
        }
            /// The focus for the directivity of the spatial audio.
        let focus: Double = 0.5
            // Add a spatial component to the entity that emits in the forward direction.
        entity.spatialAudio = SpatialAudioComponent(directivity: .beam(focus: focus))
            // Set the entity to play audio.
        entity.playAudio(audio)
        
    }
}

extension PowerUpType {
    var assetName: String {
        switch self {
        case .shield:
            return "shieldPowerUp"
        case .doubleFireRate:
            return "doubleFireRatePowerUp"
        case .extraPoints:
            return "extraPointsPowerUp"
        case .healing:
            return "healingPowerUp"
        case .multiProjectile:
            return "multiProjectilePowerUp"
        case .damageBoost:
            return "damageBoostPowerUp"
        }
    }
}
