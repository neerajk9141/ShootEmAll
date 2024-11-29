//
//  TargetController.swift
//  ShooteEmAll
//
//  Created by Quidich on 28/11/24.
//
import SwiftUI
import RealityKit
import RealityKitContent

class TargetPointerController {
    private var targetPointer: ModelEntity?
    
    func setupPointer(sceneAnchor: AnchorEntity) -> ModelEntity {
        
       
            // Create a plane to simulate the circular pointer
        let pointerMesh = MeshResource.generatePlane(width: 0.4, depth: 0.4)
        
            // Transparent circular material to give it a targeting appearance
        var pointerMaterial = UnlitMaterial()
//        pointerMaterial.baseColor = .color(.green)//.init(tint: .green, texture: nil) // Green circular pointer
        if let circleTexture = try? TextureResource.load(named: "targetPointer") {
            pointerMaterial.color.texture?.resource = circleTexture
        }
        let pointerEntity = ModelEntity(mesh: pointerMesh, materials: [pointerMaterial])
        
            // Position the pointer far in front of the spaceship
        pointerEntity.position = SIMD3<Float>(0, 0, -2)
        sceneAnchor.addChild(pointerEntity)
        targetPointer = pointerEntity
        
        return pointerEntity
    }
    
    func updatePointerPosition(spaceship: Entity) {
        guard let targetPointer = targetPointer else { return }
        
            // Align pointer with spaceship's forward direction
        targetPointer.position = spaceship.position + normalize(SIMD3<Float>(
            spaceship.transform.matrix.columns.2.x,
            spaceship.transform.matrix.columns.2.y,
            spaceship.transform.matrix.columns.2.z
        ))
    }
}
