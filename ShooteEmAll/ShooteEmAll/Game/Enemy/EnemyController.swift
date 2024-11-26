//
//  EnemyController.swift
//  ShooteEmAll
//
//  Created by Quidich on 26/11/24.
//
import Combine
import SwiftUI
import RealityKit
import RealityKitContent

class EnemyController {
    static let shared = EnemyController()
    private(set) var enemies: [Enemy] = []
    private var spawnTimer: AnyCancellable?
    private var difficultyMultiplier: Float = 1.0
    
    private init() {}
    
        /// Start spawning enemies at intervals based on difficulty
    func startSpawning() {
        spawnTimer?.cancel() // Ensure no duplicate timers
        spawnTimer = Timer.publish(every: 2.0 / Double(difficultyMultiplier), on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task {
                    await self.spawnEnemy(type: .standard) // Spawn a standard enemy by default
                }
            }
    }
    
        /// Spawn a new enemy of the given type
    func spawnEnemy(type: EnemyType) async {
        guard let enemy = await EnemyFactory.createEnemy(type: type) else { return }
        enemies.append(enemy)
    }
    
        /// Update all enemies' positions
    func updateEnemies() {
        for enemy in enemies {
            enemy.updatePosition()
            if enemy.isOffscreen {
                removeEnemy(enemy)
            }
        }
    }
    
        /// Increase the difficulty by speeding up spawn intervals
    func increaseDifficulty(by multiplier: Float) {
        difficultyMultiplier += multiplier
        startSpawning()
    }
    
        /// Remove all enemies and clean up
    func reset() {
        enemies.forEach { $0.entity.removeFromParent() }
        enemies.removeAll()
        spawnTimer?.cancel()
    }
    
        /// Remove a specific enemy
    private func removeEnemy(_ enemy: Enemy) {
        enemy.entity.removeFromParent()
        enemies.removeAll { $0 === enemy }
    }
}


class EnemyFactory {
    static func createEnemy(type: EnemyType) async -> Enemy? {
        guard let baseEntity = try? await Entity(named: type.assetName, in: realityKitContentBundle) else { return nil }
        
        let pointValue: Int
        let speed: Float
        
        switch type {
        case .standard:
            pointValue = 10
            speed = 0.1
        case .fast:
            pointValue = 20
            speed = 0.2
        case .strong:
            pointValue = 30
            speed = 0.05
            baseEntity.scale *= 1.5 // Make it visually larger
        }
        
        return Enemy(entity: baseEntity, pointValue: pointValue, speed: speed)
    }
}

enum EnemyType {
    case standard
    case fast
    case strong
    
    var assetName: String {
        switch self {
        case .standard: return "standardEnemy"
        case .fast: return "fastEnemy"
        case .strong: return "strongEnemy"
        }
    }
}
