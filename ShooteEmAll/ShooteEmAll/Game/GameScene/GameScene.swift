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
    var spaceship: Entity!
    private var enemies: [Entity] = []
    private var projectiles: [Entity] = []
    private var sceneAnchor = AnchorEntity()
    @Published var score: Int = 0
    
    private var gameTimer: AnyCancellable?
    private var fireTimer: AnyCancellable?
    private var spawnTimer: AnyCancellable?
    
    private let enemySpawnInterval: TimeInterval = 2.0
    private let fireInterval: TimeInterval = 0.5
    private let projectileDespawnZ: Float = -50 // Z-position for projectile removal
    
    private var fireSoundPlayer: AVAudioPlayer?
    private var killSoundPlayer: AVAudioPlayer?
    
        // Load assets and initialize the scene
    @MainActor
    func createScene() async -> AnchorEntity {
        setupSpaceship()
        setupTerrain()
        await setupInitialEnemies()
        startGameLoop()
        startFiring() // Start firing projectiles automatically
        loadSounds()
        return sceneAnchor
    }
    
    private func startGameLoop() {
        gameTimer = Timer.publish(every: 0.016, on: .main, in: .common) // ~60 FPS
            .autoconnect()
            .sink { _ in
                self.updateScene()
            }
    }
    
    private func startFiring() {
        fireTimer = Timer.publish(every: fireInterval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task {
                    await self.fireProjectile()
                }
            }
    }
    
    public func resetGame() {
        gameTimer?.cancel()
        fireTimer?.cancel()
        spawnTimer?.cancel()
        enemies = []
        projectiles = []
        spaceship = nil
    }
    
    func updateScene() {
            // Update projectiles
        updateProjectiles()
            // Update enemies
        updateEnemies()
            // Check collisions and game state
        checkGameState()
    }
    
    @MainActor
    private func setupSpaceship() {
        Task {
            spaceship = try? await Entity(named: "spaceship", in: realityKitContentBundle)
            spaceship.position = SIMD3(x: 0, y: 0, z: 0) // Default position at the origin
            spaceship.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0)) // Forward facing -z axis
            addComponents(entity: spaceship)
            
            if let animation = spaceship.availableAnimations.first {
                spaceship.playAnimation(animation.repeat(count: 0))
            }
            
            sceneAnchor.addChild(spaceship)
            createTargetPointer()
        }
    }
    
    func moveSpaceship(to targetPosition: SIMD3<Float>) {
            // Smooth movement using interpolation
        guard let spaceship = spaceship else { return }
        
            // Clamp target position within bounds
        let clampedX = min(max(targetPosition.x, -5), 5) // Restrict x-axis movement (-5 to 5)
        let clampedY = min(max(targetPosition.y, -5), 5) // Restrict y-axis movement (-5 to 5)
        
            // Gradual movement for both x and y axes
        let currentPosition = spaceship.position
        spaceship.position = SIMD3<Float>(
            x: currentPosition.x + (clampedX - currentPosition.x) * 0.2,
            y: currentPosition.y + (clampedY - currentPosition.y) * 0.2,
            z: currentPosition.z // z-axis remains fixed
        )
    }
    
    private func createTargetPointer() {
        
        let cylinder = ModelEntity(mesh: MeshResource.generateCylinder(height: 30, radius: 0.1))
        cylinder.model?.materials = [SimpleMaterial(color: .orange.withAlphaComponent(0.9), isMetallic: false)]
        
            // Position projectile at spaceship's position
        cylinder.position = spaceship.position
        cylinder.position.y += 0.3 // Slightly above the spaceship
        cylinder.transform.rotation = simd_quatf(angle: .pi*0.5, axis: SIMD3<Float>(1, 0, 0)) // Forward facing -z axis
        
            // Add to projectiles list and scene
        spaceship.addChild(cylinder)
        
    }
    
    private func setupTerrain() {
        getPNGSkybox()
    }
    
    private func setupInitialEnemies() async {
        spawnTimer = Timer.publish(every: enemySpawnInterval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task {
                    if self.enemies.count < 10 { // Limit the number of enemies
                        await self.spawnEnemy()
                    }
                }
            }
    }
    
    @MainActor
    private func spawnEnemy() async {
        let randomX = Float.random(in: -5...5) // Random x-axis position
        let randomY = Float.random(in: -3...3) // Random y-axis position
        let enemyPosition = SIMD3(x: randomX, y: randomY, z: -50) // Spawn enemies in -z axis
        
        if let enemy = try? await Entity(named: "enemy", in: realityKitContentBundle) {
            enemy.position = enemyPosition
            addComponents(entity: enemy)
            
            if let animation = enemy.availableAnimations.first {
                enemy.playAnimation(animation.repeat(count: 0))
            }
            enemy.scale *= 2.5
            enemies.append(enemy)
            sceneAnchor.addChild(enemy)
        }
    }
    
    private func updateEnemies() {
        for enemy in enemies {
            enemy.position.z += 0.1 // Move toward the spaceship in +z direction
            if enemy.position.z >= 0 { // Off-screen or reaches the spaceship
                enemy.removeFromParent()
                enemies.removeAll(where: { $0 == enemy })
                Task {
                    await self.spawnEnemy() // Respawn new enemy
                }
            }
        }
    }
    
    private func updateProjectiles() {
        for projectile in projectiles {
                // Move forward in -z axis
            projectile.position.z -= 0.5
            
            if projectile.position.z < projectileDespawnZ { // Despawn projectiles off-screen
                projectile.removeFromParent()
                projectiles.removeAll(where: { $0 == projectile })
            }
        }
    }
    
    private func checkGameState() {
            // Detect collisions between projectiles and enemies
        for projectile in projectiles {
            for enemy in enemies {
                let distance = simd_distance(projectile.position, enemy.position)
                if distance < 0.5 { // Adjust based on model size
                        // Play enemy kill sound
                    playKillSound()
                    
                        // Remove both the projectile and the enemy
                    projectile.removeFromParent()
                    projectiles.removeAll(where: { $0 == projectile })
                    
                    enemy.removeFromParent()
                    enemies.removeAll(where: { $0 == enemy })
                    
                        // Update score
                    score += 10
                    print("Score: \(score)")
                    
                        // Respawn a new enemy
                    Task {
                        await self.spawnEnemy()
                    }
                }
            }
        }
    }
    
    @MainActor
    func fireProjectile() async {
        if projectiles.count < 15 { // Limit the number of active projectiles
            guard let spaceship = spaceship else { return }
            
                // Play fire sound
            playFireSound()
            
                // Create a laser-like cylinder projectile
            let cylinder = ModelEntity(mesh: MeshResource.generateCylinder(height: 1, radius: 0.1))
            cylinder.model?.materials = [SimpleMaterial(color: .systemTeal, isMetallic: false)]
            
                // Position projectile at spaceship's position
            cylinder.position = spaceship.position
            cylinder.position.y += 0.3 // Slightly above the spaceship
            cylinder.transform.rotation = simd_quatf(angle: .pi*0.5, axis: SIMD3<Float>(1, 0, 0)) // Forward facing -z axis
            
                // Add to projectiles list and scene
            projectiles.append(cylinder)
            sceneAnchor.addChild(cylinder)
        }
    }
    
    private func loadSounds() {
            // Load fire and kill sounds
        fireSoundPlayer = loadSound(named: "fireSound")
        killSoundPlayer = loadSound(named: "killSound")
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
    
    private func playKillSound() {
        killSoundPlayer?.stop()
        killSoundPlayer?.currentTime = 0
        killSoundPlayer?.play()
    }
}

extension GameScene {
    private func addComponents(entity: Entity) {
        entity.components.set(InputTargetComponent())
        entity.generateCollisionShapes(recursive: true)
    }
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
}
