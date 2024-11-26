//
//  HUDView.swift
//  ShooteEmAll
//
//  Created by Quidich on 25/11/24.
//

import SwiftUI

struct HUDView: View {
//    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack {
            Text("Score: 0")
            Text("Lives: 0")
        }
        .font(.largeTitle)
        .foregroundColor(.white)
        .padding()
    }
}
