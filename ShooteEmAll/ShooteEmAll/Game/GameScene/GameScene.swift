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
    
    private var gameTimer: AnyCancellable?
    private var fireTimer: AnyCancellable?
    
    private let fireInterval: TimeInterval = 0.5
    private var fireSoundPlayer: AVAudioPlayer?
    private var killSoundPlayer: AVAudioPlayer?
    
        // MARK: - Scene Creation and Setup
    
    @MainActor
    func createScene() async -> AnchorEntity {
            // Initialize game elements
        await SpaceshipController.shared.setupSpaceship(sceneAnchor: sceneAnchor)
        setupTerrain()
        
            // Start controllers
        EnemyController.shared.startSpawning()
        PowerUpController.shared.startSpawning()
        startGameLoop()
        startFiring()
        
            // Load sounds
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
                SpaceshipController.shared.fire()
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
    
        // MARK: - Scene Updates
    
    private func updateScene() {
            // Update controllers
        EnemyController.shared.updateEnemies()
        ProjectileController.shared.updateProjectiles()
        PowerUpController.shared.updatePowerUps()
        
            // Check collisions and game state
        checkCollisions()
    }
    
    private func checkCollisions() {
            // Check projectile collisions with enemies
        ProjectileController.shared.checkCollisions(with: EnemyController.shared.enemies) { [weak self] destroyedEnemy in
            self?.incrementScore(for: destroyedEnemy)
        }
        
            // Check power-up collisions with the spaceship
        PowerUpController.shared.checkCollisions(with: SpaceshipController.shared.spaceship) { powerUp in
            powerUp.applyEffect(to: SpaceshipController.shared)
        }
    }
    
    private func incrementScore(for enemy: Enemy) {
        score += enemy.pointValue
        if score % 100 == 0 { // Increase difficulty every 100 points
            EnemyController.shared.increaseDifficulty(by: 0.1)
        }
    }
    
        // MARK: - Setup Functions
    
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
    
        // MARK: - Sound Management
    
    private func loadSounds() {
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
