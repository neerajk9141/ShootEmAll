//
//  JoyStickView.swift
//  ShooteEmAll
//
//  Created by Quidich on 29/11/24.
//

import SwiftUI

let sensitivity: Float = 0.35


struct JoystickView: View {
    @Binding var targetPosition: SIMD3<Float> // Binding to target position
    @State private var joystickOffset: CGSize = .zero // Current joystick offset
    @State private var previousOffset: CGSize = .zero // For smooth transition
    
        // Define the visual boundaries for the target
    let boundaryX: ClosedRange<Float> = -5...5 // Horizontal boundary (left and right)
    let boundaryY: ClosedRange<Float> = -3...3 // Vertical boundary (up and down)
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                    // Outer circle representing joystick range
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 250, height: 250)
                
                    // Inner circle representing joystick's current position
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
                                
                                    // Proportional scaling for movement
                                let scaledX = Float(offsetX / radius) * sensitivity
                                let scaledY = -Float(offsetY / radius) * sensitivity // Negative to match screen coordinates
                                
                                    // Update target position with boundary constraints
                                targetPosition.x = max(boundaryX.lowerBound, min(boundaryX.upperBound, targetPosition.x + scaledX))
                                targetPosition.y = max(boundaryY.lowerBound, min(boundaryY.upperBound, targetPosition.y + scaledY))
                                
                                    // Store the previous offset for smooth release
                                previousOffset = joystickOffset
                            }
                            .onEnded { _ in
                                    // Gradually reset joystick to center on release
                                withAnimation(.easeOut(duration: 0.3)) {
                                    joystickOffset = .zero
                                }
                            }
                    )
            }
            .frame(width: 300, height: 300)
        }
    }
}
