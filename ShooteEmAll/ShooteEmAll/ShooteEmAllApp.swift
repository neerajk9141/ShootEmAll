//
//  ShooteEmAllApp.swift
//  ShooteEmAll
//
//  Created by Quidich on 25/11/24.
//

import SwiftUI

@main
struct ShooteEmAllApp: App {

    @State private var appModel = AppModel()
    @StateObject var gameScene = GameScene()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .environmentObject(gameScene)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .environmentObject(gameScene)
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
