//
//  HumanEntity.swift
//  ShooteEmAll
//
//  Created by Quidich on 25/11/24.
//
import RealityKit
import SwiftUI

class EnemyEntity: Entity, HasPhysics, HasModel {
    var speed: Float = 0.05
    
    required init() {
        super.init()
        self.model = ModelComponent(mesh: .generateSphere(radius: 0.3), materials: [SimpleMaterial(color: .white, isMetallic: false)])
        self.physicsBody = PhysicsBodyComponent(massProperties: .default,
                                                material: .default,
                                                mode: .dynamic)
    }
    
    func update() {
            // Move toward the player or along a path
        self.position.z += speed
    }
}

class HumanEntity: Entity, HasPhysics, HasModel {
    required init() {
        super.init()
        
        self.model = ModelComponent(mesh: .generateBox(size: [0.3, 0.5, 0.3]), materials: [SimpleMaterial(color: .white, isMetallic: false)])
        self.physicsBody = PhysicsBodyComponent(massProperties: .default,
                                                material: .default,
                                                mode: .kinematic)
    }
}
