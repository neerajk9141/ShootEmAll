//
//  ContentView.swift
//  ShooteEmAll
//
//  Created by Quidich on 25/11/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @EnvironmentObject var gameScene : GameScene

    var body: some View {
        VStack {
            
            Text("Score: \(gameScene.score)")
                .font(.extraLargeTitle)

            ToggleImmersiveSpaceButton()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
