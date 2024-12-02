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
    func startSpawning(sceneAnchor: AnchorEntity, type: EnemyType) {
        spawnTimer?.cancel() // Ensure no duplicate timers
        spawnTimer = Timer.publish(every: 2.0 / Double(difficultyMultiplier), on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task {
                    await self.spawnEnemy(type: type, sceneAnchor: sceneAnchor)
                }
            }
    }
    
        /// Spawn a new enemy of the given type
    @MainActor
    func spawnEnemy(type: EnemyType, sceneAnchor: AnchorEntity) async {
        guard let enemy = await EnemyFactory.createEnemy(type: type) else { return }
        let randomX = Float.random(in: -5...5)
        let randomY = Float.random(in: -3...3)
        enemy.entity.position = SIMD3<Float>(randomX, randomY, -30)
        sceneAnchor.addChild(enemy.entity)
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
    func increaseDifficulty(by multiplier: Float, sceneAnchor: AnchorEntity) {
        difficultyMultiplier += multiplier
            // Restart spawning enemies with increased difficulty
        startSpawning(sceneAnchor: sceneAnchor, type: .standard)
    }

        /// Remove all enemies and clean up
        ///
    @MainActor
    func reset() {
        enemies.forEach {
            $0.entity.removeFromParent()
            AppModel.anchor?.removeChild($0.entity)

        }
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
        
        let enemy = Enemy(entity: baseEntity, pointValue: type.pointValue, speed: type.speed)
        enemy.health = type.health // Assign enemy-specific health
        return enemy
    }
}

enum EnemyType {
    case standard
    case fast
    case strong
    case boss
    
    var assetName: String {
        switch self {
        case .standard: return "enemy"
        case .fast: return "fastEnemy"
        case .strong: return "strongEnemy"
        case .boss: return "boss"
        }
    }
    
    var speed: Float {
        switch self {
        case .standard: return 0.1
        case .fast: return 0.2
        case .strong: return 0.05
        case .boss: return 0.02
        }
    }
    
    var health: Int {
        switch self {
        case .standard: return 1
        case .fast: return 2
        case .strong: return 5
        case .boss: return 20 // Bosses have higher health
        }
    }
    
    var pointValue: Int {
        switch self {
        case .standard: return 10
        case .fast: return 20
        case .strong: return 50
        case .boss: return 200
        }
    }
}
