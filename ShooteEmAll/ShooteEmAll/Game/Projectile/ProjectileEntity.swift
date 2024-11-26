//
//  ProjectileEntity.swift
//  ShooteEmAll
//
//  Created by Quidich on 25/11/24.
//
import RealityKit
import SwiftUI

class ProjectileEntity: Entity, HasPhysics, HasModel {
    var speed: Float = 0.2
    
    required init() {
        super.init()
        self.model = ModelComponent(mesh: .generateBox(size: [0.1, 0.1, 0.5]), materials: [SimpleMaterial(color: .systemTeal, isMetallic: false)])
        self.physicsBody = PhysicsBodyComponent(massProperties: .default,
                                                material: .default,
                                                mode: .kinematic)
    }
    
    func update() {
            // Move forward
        self.position.z -= speed
            // Remove if out of bounds
        if self.position.z < -20 {
            self.removeFromParent()
        }
    }
}
