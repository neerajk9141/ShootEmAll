//
//  ImmersiveView.swift
//  ShooteEmAll
//
//  Created by Quidich on 25/11/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    
    @EnvironmentObject var gameScene : GameScene
    @Environment(AppModel.self) private var appModel
    @EnvironmentObject var gameSceneViewModel : GameSceneViewModel
    @Environment(HandViewModel.self) private var model

    @State private var lastTranslation = CGSize.zero
    @State private var entityPosition = SIMD3<Float>(0, 0, -5.0) // Initial position
//    TextProgressView(text: "🫱🏿‍🫲🏻", value: model.leftScores["🫱🏿‍🫲🏻"] ?? 0)

    
    var body: some View {
        @Bindable var model = model

        ZStack {
            RealityView { content,attachments in
                    // Add the initial RealityKit content
                let scene = await gameScene.createScene()
                AppModel.anchor = scene
                content.add(scene)
                gameScene.addLight()
                if let attachment = attachments.entity(for: "HUDView") {
                    attachment.position = SIMD3<Float>(0.4, 0.0, -1.0)
                    attachment.transform.rotation = simd_quatf(angle: -.pi/4, axis: SIMD3<Float>(1,0,0))
                    content.add(attachment)
                }
                
            } update: { content,attachments in
                
            } attachments: {
                Attachment(id:"HUDView") {
                    HStack {
                        Spacer()
                        HUDView(entityPosition: $entityPosition)
                            .environmentObject(gameScene)
                            .environmentObject(gameSceneViewModel)
                            .padding()
                            .background(Color.clear)
                    }
                        
                }
            }
        }
        .onChange(of: entityPosition) { oldValue,newValue in
            gameSceneViewModel.updateTargetPosition(x: entityPosition.x, y: entityPosition.y)
            gameScene.updateTargetPos(pos: newValue)
        }
        .onChange(of: model.leftScores["🫱🏿‍🫲🏻"], { oldValue, newValue in
            if (model.leftScores["🫱🏿‍🫲🏻"] ?? 0) > 91 {
                
            }
        })
        .onChange(of: model.rightScores["🫱🏿‍🫲🏻"], { oldValue, newValue in
            if (model.rightScores["🫱🏿‍🫲🏻"] ?? 0) > 91 {
                
            }
        })
        .onDisappear {
            gameScene.resetGame()
        }
        .upperLimbVisibility(model.latestHandTracking.isSkeletonVisible ? .hidden : .automatic)
        
        .task {
            await model.startHandTracking()
        }
        .task {
            await model.publishHandTrackingUpdates()
        }
        .task {
            await model.monitorSessionEvents()
        }
#if targetEnvironment(simulator)
        .task {
            await model.publishSimHandTrackingUpdates()
        }
#endif
    }
    
    func checkGestureScore() {
        
        if (model.rightScores["🫱🏿‍🫲🏻"] ?? 0) > 91 && (model.leftScores["🫱🏿‍🫲🏻"] ?? 0) > 91 {
            
        }
        
    }
}


//Keep this
    //            .gesture(
    //                DragGesture()
    //                    .onChanged { value in
    //                        let translation = value.translation
    //                        let deltaX = Float(translation.width - lastTranslation.width) / 100
    //                        let deltaY = Float(translation.height - lastTranslation.height) / 100
    //
    //                        entityPosition.x += deltaX
    //                        entityPosition.y -= deltaY // Inverted to match screen coordinate system
    //                        entityPosition.z = -5
    //                        lastTranslation = translation
    //                        gameSceneViewModel.updateTargetPosition(x: entityPosition.x, y: entityPosition.y)
    //                    }
    //            )
