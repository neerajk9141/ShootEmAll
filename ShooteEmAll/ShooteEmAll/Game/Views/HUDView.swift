//
//  HUDView.swift
//  ShooteEmAll
//
//  Created by Quidich on 25/11/24.
//

import SwiftUI

struct HUDView: View {
    @EnvironmentObject var gameScene: GameScene
    @EnvironmentObject var viewModel : GameSceneViewModel
    
    @Binding var entityPosition : SIMD3<Float>

    var body: some View {
        HStack {
           
            JoystickView(targetPosition: $entityPosition)
                .padding()
            
            VStack {
                Text("Score: \(gameScene.score)")
                    .font(.largeTitle)
                    .foregroundStyle(Color.red)
            }
        }
        .font(.largeTitle)
        .foregroundColor(.white)
        .frame(width: 800,height: 400)
        .padding()
        .glassBackgroundEffect()
    }
}
