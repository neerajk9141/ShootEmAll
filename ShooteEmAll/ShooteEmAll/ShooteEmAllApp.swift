//
//  ShooteEmAllApp.swift
//  ShooteEmAll
//
//  Created by Quidich on 25/11/24.
//

import SwiftUI
import RealityKitContent

@main
struct ShooteEmAllApp: App {

    @State private var appModel = AppModel()
    @StateObject var gameScene = GameScene()
    @StateObject var gameSceneviewModel = GameSceneViewModel()
    @State var handViewModel = HandViewModel()
    
    init() {
        RealityKitContent.GestureComponent.registerComponent()
    }
    
    var body: some Scene {
        WindowGroup(id:"MainWindowGroup") {
            GameStartView()
                .environment(appModel)
                .environment(handViewModel)
                .environmentObject(gameScene)
                .environmentObject(gameSceneviewModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .environment(handViewModel)
                .environmentObject(gameScene)
                .environmentObject(gameSceneviewModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
