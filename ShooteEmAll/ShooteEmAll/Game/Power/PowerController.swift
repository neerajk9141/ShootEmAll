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

class PowerUpController {
    static let shared = PowerUpController()
    private var powerUps: [PowerUp] = []
    private var spawnTimer: AnyCancellable?
    
    private init() {}
    
    func startSpawning(sceneAnchor: AnchorEntity) {
        spawnTimer = Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task {
                    await self.spawnPowerUp(sceneAnchor: sceneAnchor)
                }
            }
    }
    
    private func spawnPowerUp(sceneAnchor: AnchorEntity) async {
        guard let powerUp = await PowerUpFactory.createPowerUp(type: .shield) else { return }
        await sceneAnchor.addChild(powerUp.entity)
        powerUps.append(powerUp)
    }
    
    func updatePowerUps() {
        for powerUp in powerUps {
            powerUp.updatePosition()
        }
    }
    
    func checkCollisions(with spaceship: Entity?, completion: (PowerUp) -> Void) {
        guard let spaceship = spaceship else { return }
        for powerUp in powerUps {
            if simd_distance(spaceship.position, powerUp.entity.position) < 0.5 {
                completion(powerUp)
                powerUp.entity.removeFromParent()
                powerUps.removeAll { $0 == powerUp }
            }
        }
    }
    
    func reset() {
        powerUps.forEach { $0.entity.removeFromParent() }
        powerUps.removeAll()
    }
}


class PowerUpFactory {
    static func createPowerUp(type: PowerUpType) async -> PowerUp? {
        guard let baseEntity = try? await Entity(named: type.assetName, in: realityKitContentBundle) else { return nil }
        return PowerUp(entity: baseEntity, type: type)
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
