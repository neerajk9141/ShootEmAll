//
//  LevelController.swift
//  ShooteEmAll
//
//  Created by Quidich on 02/12/24.
//

import RealityKit
import SwiftUI

class LevelController {
    var currentLevel: Int = 1
    private var enemies: [Enemy] = []
    private var enemyTypes: [EnemyType] = [.standard, .fast, .strong] // Types for regular enemies
    
    func setupLevel(sceneAnchor: AnchorEntity) {
        switch currentLevel {
        case 1:
            spawnEnemies(sceneAnchor: sceneAnchor, type: .standard, count: 10)
        case 2:
            spawnEnemies(sceneAnchor: sceneAnchor, type: .fast, count: 15)
        case 3:
            spawnEnemies(sceneAnchor: sceneAnchor, type: .strong, count: 20)
        case 4:
            Task { await spawnBoss(sceneAnchor: sceneAnchor) } // Spawn boss
        default:
            break
        }
    }
    
    func increaseDifficulty(sceneAnchor: AnchorEntity) {
        currentLevel += 1
        EnemyController.shared.increaseDifficulty(by: 0.5, sceneAnchor: sceneAnchor)
    }
    
    func spawnEnemies(sceneAnchor: AnchorEntity, type: EnemyType, count: Int) {
        for _ in 0..<count {
            Task {
//                await EnemyController.shared.spawnEnemy(type: type, sceneAnchor: sceneAnchor)
                EnemyController.shared.startSpawning(sceneAnchor: sceneAnchor, type: .standard)
            }
        }
    }
    

    
    func spawnBoss(sceneAnchor: AnchorEntity) async {
        guard let boss = await EnemyFactory.createEnemy(type: .boss) else { return }
        boss.entity.position = SIMD3<Float>(0, 0, -20)
        sceneAnchor.addChild(boss.entity)
        enemies.append(boss)
    }
    
    func getSkybox(for level: Int) -> Entity {
        let entity = ModelEntity(mesh: MeshResource.generateSphere(radius: 100))
        let textureName = level == 1 ? "spaceScene" : level == 2 ? "nebulaScene" : "asteroidBelt"
        if let texture = try? TextureResource.load(named: textureName) {
            entity.model?.materials = [UnlitMaterial(texture: texture)]
        }
        return entity
    }
    
    func reset() {
        currentLevel = 1
        enemies.forEach { $0.entity.removeFromParent() }
        enemies.removeAll()
    }
    
    func updateEnemies() {
        for enemy in enemies {
            enemy.updatePosition()
        }
    }
    
    func getEnemies() -> [Enemy] {
        return enemies
    }
    
    func removeEnemy(_ enemy: Enemy) {
        enemies.removeAll { $0 === enemy }
    }
}
