//
//  JoyStickView.swift
//  ShooteEmAll
//
//  Created by Quidich on 29/11/24.
//

import SwiftUI


struct JoystickView: View {
    @Binding var targetPosition: SIMD3<Float>
    @State private var joystickOffset: CGSize = .zero
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 250, height: 250)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(joystickOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let radius = geo.size.width / 2
                                let translation = value.translation
                                
                                    // Clamp joystick movement within the radius
                                let offsetX = max(-radius, min(radius, translation.width))
                                let offsetY = max(-radius, min(radius, translation.height))
                                joystickOffset = CGSize(width: offsetX, height: offsetY)
                                
                                    // Convert offset to target position change
                                targetPosition.x += Float(offsetX) * sensitivity
                                targetPosition.y -= Float(offsetY) * sensitivity
                            }
                            .onEnded { _ in
                                joystickOffset = .zero // Reset joystick position
                            }
                    )
            }
            .frame(width: 300, height: 300)
        }
    }
}
