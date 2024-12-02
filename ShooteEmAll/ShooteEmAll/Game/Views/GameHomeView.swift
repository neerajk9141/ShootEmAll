//
//  GameHomeView.swift
//  ShooteEmAll
//
//  Created by Quidich on 29/11/24.
//
import SwiftUI

struct GameStartView: View {
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @EnvironmentObject var gameScene: GameScene
    @StateObject private var viewModel = GameSceneViewModel()
    
    @State private var isGameStarted = false
    @State private var selectedLevel: Int = 1 // Default to Level 1
    
    var body: some View {
        VStack {
            Text("ShooteEmAll")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
                // Level Selection
            Text("Select Level")
                .font(.headline)
            Picker("Level", selection: $selectedLevel) {
                ForEach(1...4, id: \.self) { level in
                    Text("Level \(level)").tag(level)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
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
                gameScene.levelController.currentLevel = selectedLevel
                isGameStarted = true
                dismissWindow(id:"MainWindowGroup")
                
            })
            .padding()
        }
        .padding()
        .background(isGameStarted ? Color.black.opacity(0.8) : Color.white)
        .onAppear {
                // Reset game if returning to this view
//            gameScene.resetGame()
        }
//        .opacity(isGameStarted ? 0 : 1) // Hide when game starts
//        .animation(.easeInOut, value: isGameStarted)
    }
}
