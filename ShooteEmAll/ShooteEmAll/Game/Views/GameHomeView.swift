//
//  GameHomeView.swift
//  ShooteEmAll
//
//  Created by Quidich on 29/11/24.
//
import SwiftUI

struct GameStartView: View {
    @EnvironmentObject var gameScene: GameScene
    @StateObject private var viewModel = GameSceneViewModel()
    
    @State private var isGameStarted = false
    
    var body: some View {
        VStack {
            Text("ShooteEmAll")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
                // Difficulty Selection
            Text("Select Difficulty")
                .font(.headline)
            Picker("Difficulty", selection: $viewModel.difficultyLevel) {
                ForEach(DifficultyLevel.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Spacer()
            
                // Start Button
            ToggleImmersiveSpaceButton(action: {
                gameScene.difficultyLevel = viewModel.difficultyLevel
                isGameStarted = true
            })
            .padding()
        }
        .padding()
    }
}
