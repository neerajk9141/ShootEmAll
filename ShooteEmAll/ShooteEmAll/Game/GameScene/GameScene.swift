//
//  GameScene.swift
//  ShooteEmAll
//
//  Created by Quidich on 25/11/24.
//
import RealityKit
import RealityKitContent
import SwiftUI
import AVFoundation
import Combine

class GameScene: ObservableObject {
    private var sceneAnchor = AnchorEntity()
    @Published var score: Int = 0
    private var spaceship: Entity!
    private var spaceshipController = SpaceshipController.shared

    private var gameTimer: AnyCancellable?
    private var fireTimer: AnyCancellable?
    
    private let fireInterval: TimeInterval = 0.5
    private var fireSoundPlayer: AVAudioPlayer?
    private var explosionSoundPlayer: AVAudioPlayer?
    
    private let targetSensitivity: Float = 2.0 // Sensitivity for target movement
    var targetEntity: ModelEntity! // Target that moves based on hand gestures
    private let smoothingFactor: Float = 0.1 // Smoothing for target movement

    var difficultyLevel: DifficultyLevel = .easy
    
    @MainActor
    func createScene() async -> AnchorEntity {
        spaceship = await SpaceshipController.shared.setupSpaceship(sceneAnchor: sceneAnchor)
        setupTerrain()
            // Start controllers
        EnemyController.shared.startSpawning(sceneAnchor: sceneAnchor)
        PowerUpController.shared.startSpawning(sceneAnchor: sceneAnchor)
        startFiring()
        loadSounds()
        setupTarget()
        startGameLoop()
        
        return sceneAnchor
    }
    
    private func setupTarget() {
        targetEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.1))
        targetEntity.name = "Target"
        targetEntity.position = SIMD3<Float>(0, 0, -5) // Start at Z = -5
        targetEntity.model?.materials = [SimpleMaterial(color: .green, isMetallic: true)]
        targetEntity.components.set(InputTargetComponent())
        targetEntity.generateCollisionShapes(recursive: true)
        targetEntity.components.set(CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.2)]))
        var hover = HoverEffectComponent()
        hover.hoverEffect = .highlight(.init(color: .yellow,strength: 0.8))
        targetEntity.components.set(hover)
        sceneAnchor.addChild(targetEntity)
    }
    
    
    private func startGameLoop() {
        gameTimer = Timer.publish(every: 0.016, on: .main, in: .common) // ~60 FPS
            .autoconnect()
            .sink { _ in
                Task {
                    await self.updateScene()
                }
            }
    }
    
    private func startFiring() {
        fireTimer = Timer.publish(every: fireInterval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.fireProjectile()
            }
    }
    
    func resetGame() {
        gameTimer?.cancel()
        fireTimer?.cancel()
        SpaceshipController.shared.reset()
        EnemyController.shared.reset()
        PowerUpController.shared.reset()
        ProjectileController.shared.reset()
        score = 0
    }
    
    private func updateScene() async {
            // Update controllers
        EnemyController.shared.updateEnemies()
        ProjectileController.shared.updateProjectiles()
        PowerUpController.shared.updatePowerUps()

            // Check collisions and game state
        checkCollisions()
    }
    
    @MainActor
    private func moveSpaceship(to position: SIMD3<Float>) {
        guard let spaceship = spaceship else { return }
        spaceship.position = position
    }
    
    private func checkCollisions() {
        ProjectileController.shared.checkCollisions(with: EnemyController.shared.enemies) { [weak self] destroyedEnemy in
            Task {
                await self?.playExplosionAnimation(for: destroyedEnemy)
                self?.incrementScore(for: destroyedEnemy)
            }
        }
        
        PowerUpController.shared.checkCollisions(with: SpaceshipController.shared.spaceship) { powerUp in
            powerUp.applyEffect(to: SpaceshipController.shared)
        }
    }
    
    private func incrementScore(for enemy: Enemy) {
        score += enemy.pointValue
        if score % 100 == 0 {
            EnemyController.shared.increaseDifficulty(by: 0.1, sceneAnchor: sceneAnchor)
        }
    }
    
    private func fireProjectile() {
        guard let spaceship = spaceship else { return }
        playFireSound()
            // Fire the projectile
        SpaceshipController.shared.fire(sceneAnchor: sceneAnchor)
    }
    
//    @MainActor
//    private func playExplosionAnimation(for enemy: Enemy) async {
//            // Add explosion animation and sound
//        if let explosionEntity = try? await Entity(named: "explosion", in: realityKitContentBundle) {
//            explosionEntity.position = enemy.entity.position
//            sceneAnchor.addChild(explosionEntity)
//            explosionSoundPlayer?.play()
//            
//                // Remove explosion after 2 seconds
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                explosionEntity.removeFromParent()
//            }
//        }
//    }
    
    
}


extension GameScene {
    func addLight() {
        addSun(position: SIMD3<Float>(0, 40, 0), color: .white, intensity: 20000000)
    }
    
    private func addSun(position: SIMD3<Float>, color: UIColor, intensity: Float) {
        let lightSource = ModelEntity()
        lightSource.position = position
        
        let pointLight = PointLight()
        var comp = PointLightComponent(color: color, intensity: intensity)
        comp.attenuationRadius = 10000
        pointLight.light = comp
        
        lightSource.addChild(pointLight)
        self.sceneAnchor.addChild(lightSource)
    }
}


extension GameScene {

    func updateTargetPos(pos: SIMD3<Float>) {
        targetEntity.move(to: Transform(translation: SIMD3<Float>(pos.x, pos.y, -5)), relativeTo: nil)
        updateSpaceshipRotation()
    }
    
    private func updateSpaceshipRotation() {
        print("Updating spaceship rotation")
            // Compute direction to the target
        let targetPosition = SIMD3<Float>(-targetEntity.position.x,-targetEntity.position.y,5)
        self.spaceship.look(at: targetPosition, from: self.spaceship.position, relativeTo: nil)
    }
}


extension GameScene {
    
    private func setupTerrain() {
        getPNGSkybox()
    }
    
    private func getPNGSkybox() {
        let sphereVideoEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 530))
        sphereVideoEntity.name = "Skybox"
        guard let resource = try? TextureResource.load(named: "gameScene") else { return }
        
        sphereVideoEntity.scale *= .init(x: -1.01, y: 1.01, z: 1.01)
        sphereVideoEntity.transform.translation += SIMD3<Float>(0.0, 0.029, 0.0)
        
        var skyboxMaterial = PhysicallyBasedMaterial()
        skyboxMaterial.baseColor = .init(texture: .init(resource))
        skyboxMaterial.roughness = .init(floatLiteral: 1)
        skyboxMaterial.emissiveColor = .init(texture: .init(resource))
        
        sphereVideoEntity.model?.materials = [skyboxMaterial]
        sphereVideoEntity.scale *= 0.2
        self.sceneAnchor.addChild(sphereVideoEntity)
    }
    
    private func loadSounds() {
        fireSoundPlayer = loadSound(named: "fireSound")
        explosionSoundPlayer = loadSound(named: "explosionSound")
    }
    
    private func loadSound(named name: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return nil }
        return try? AVAudioPlayer(contentsOf: url)
    }
    
    private func playFireSound() {
        fireSoundPlayer?.stop()
        fireSoundPlayer?.currentTime = 0
        fireSoundPlayer?.play()
    }
    
}

//MARK: Particle Explosion
extension GameScene {
    
    private func createBlastEffect(at position: SIMD3<Float>) -> Entity {
            // Create an entity to attach the particle emitter
        let particleEntity = Entity()
        
            // Create the particle emitter
        var particleEmitter = ParticleEmitterComponent()
        
            // Configure the particle emitter
        particleEmitter.emitterShape = .sphere
        particleEmitter.mainEmitter.birthRate = 500             // Number of particles per second
        particleEmitter.mainEmitter.lifeSpan = 1.0             // Lifetime of each particle in seconds
        particleEmitter.speed = .init(0.9)      // Particle speed
        particleEmitter.mainEmitter.noiseScale = .init(0.1)         // Particle size
        particleEmitter.mainEmitter.color = .constant(.random(a: .yellow, b: .orange)) // Particle color
            // Add the emitter to the entity
        particleEntity.components.set(particleEmitter)
        particleEntity.position = position
        
        return particleEntity
    }
    
    @MainActor
    private func playExplosionAnimation(for enemy: Enemy) async {
            // Add explosion particle effect
        let explosionEffect = createBlastEffect(at: enemy.entity.position)
        sceneAnchor.addChild(explosionEffect)
        
            // Play explosion sound
        explosionSoundPlayer?.play()
        
            // Remove explosion effect after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            explosionEffect.removeFromParent()
        }
    }
    
}
