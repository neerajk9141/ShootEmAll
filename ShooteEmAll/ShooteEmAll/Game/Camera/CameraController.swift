//
//  CameraController.swift
//  ShooteEmAll
//
//  Created by Quidich on 02/12/24.
//
import SwiftUI
import RealityKit

class CameraController {
    private var cameraEntity: PerspectiveCamera?
    
    func setupCamera(sceneAnchor: AnchorEntity, spaceship: Entity) {
        cameraEntity = PerspectiveCamera()
        cameraEntity?.transform.translation = SIMD3<Float>(0, 2, 10)
        sceneAnchor.addChild(cameraEntity!)
    }
    
    func switchToThirdPerson() {
        guard let camera = cameraEntity else { return }
        camera.transform.translation = SIMD3<Float>(0, 2, 10)
    }
    
    func switchToTopDown() {
        guard let camera = cameraEntity else { return }
        camera.transform.translation = SIMD3<Float>(0, 10, 0)
        camera.look(at: SIMD3<Float>(0, 0, -10), from: camera.position, relativeTo: nil)
    }
}
