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
    
    var body: some View {
        RealityView { content in
                // Add the initial RealityKit content
            let scene = await gameScene.createScene()
            content.add(scene)
            gameScene.addLight()
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                        // Adjust spaceship position based on drag
                    let targetPosition = SIMD3<Float>(
                        x: Float(value.translation.width) * sensitivity, // Adjust sensitivity for x-axis
                        y: Float(value.translation.height) * -sensitivity, // Adjust sensitivity for y-axis
                        z: 0 // Keep z-axis fixed
                    )
                    gameScene.moveSpaceship(to: targetPosition)
                }
        )
        .onDisappear {
            gameScene.resetGame()
        }
        
    }
}
