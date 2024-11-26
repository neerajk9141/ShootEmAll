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
    
    func startSpawning() {
        spawnTimer = Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.spawnPowerUp()
            }
    }
    
    private func spawnPowerUp() {
        guard let powerUp = PowerUpFactory.createPowerUp(type: .shield) else { return }
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
