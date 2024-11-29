//
//  ImmersiveView.swift
//  ShooteEmAll
//
//  Created by Quidich on 25/11/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

let sensitivity: Float = 0.0005

struct ImmersiveView: View {
    
    @EnvironmentObject var gameScene : GameScene
    @Environment(AppModel.self) private var appModel
    
    @State private var lastTranslation = CGSize.zero
    @State private var entityPosition = SIMD3<Float>(0, 0, -5.0) // Initial position

    
    var body: some View {
        RealityView { content in
                // Add the initial RealityKit content
            let scene = await gameScene.createScene()
            content.add(scene)
            gameScene.addLight()
        } update: { content in
            
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let translation = value.translation
                    let deltaX = Float(translation.width - lastTranslation.width) / 100
                    let deltaY = Float(translation.height - lastTranslation.height) / 100
                    
                    entityPosition.x += deltaX
                    entityPosition.y -= deltaY // Inverted to match screen coordinate system
                    entityPosition.z = -5
                    lastTranslation = translation
                    
//                    gameScene.targetEntity.position = entityPosition
                    
                    gameScene.updateTargetPos(pos: entityPosition)
                }
        )
        
    }
}
