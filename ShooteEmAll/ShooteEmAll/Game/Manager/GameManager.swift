//
//  GameManager.swift
//  ShooteEmAll
//
//  Created by Quidich on 25/11/24.
//

import RealityKit
import Combine
import SwiftUI

class GameManager: ObservableObject {
    static let shared = GameManager()
    
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var isGameOver: Bool = false
    
    private var gameTimer: AnyCancellable?
    private let difficultyMultiplierIncrement: Float = 0.1
    private(set) var health: Int = 100

    private init() {}
    
    @MainActor func startGame() {
        score = 0
        level = 1
        isGameOver = false
        SpaceshipController.shared.reset()
        EnemyController.shared.reset()
        ProjectileController.shared.reset()
        PowerUpController.shared.reset()
        startGameLoop()
    }
    
    private func startGameLoop() {
        gameTimer = Timer.publish(every: 0.016, on: .main, in: .common) // ~60 FPS
            .autoconnect()
            .sink { _ in
                self.updateGameState()
            }
    }
    
    private func updateGameState() {
        EnemyController.shared.updateEnemies()
        ProjectileController.shared.updateProjectiles()
        PowerUpController.shared.updatePowerUps()
        Task {
            await checkCollisions()
        }
    }
    
    @MainActor
    private func checkCollisions() {
        ProjectileController.shared.checkCollisions(with: EnemyController.shared.enemies) { [weak self] destroyedEnemy in
            self?.incrementScore(for: destroyedEnemy)
        }
        
        PowerUpController.shared.checkCollisions(with: ProjectileController.shared.projectiles) { [weak self] (powerUp, projectile) in
            guard let self = self else { return }
            SpaceshipController.shared.applyPowerUpEffect(type: powerUp.type) // Apply effect
            powerUp.entity.removeFromParent() // Remove power-up
            ProjectileController.shared.removeProjectile(projectile) // Remove projectile
        }
    }
    
    private func incrementScore(for enemy: Enemy) {
        score += enemy.pointValue
        if score % 100 == 0 { // Example: Every 100 points increase level
            level += 1
            EnemyController.shared.increaseDifficulty(by: difficultyMultiplierIncrement, sceneAnchor: AnchorEntity())
        }
    }
    
    func heal(amount: Int) {
        health = min(100, health + amount) // Prevent health from exceeding 100
        print("Health restored by \(amount). Current health: \(health)")
    }
    
    func addScore(points: Int) {
        score += points
        print("Score increased by \(points). Current score: \(score)")
    }
}
