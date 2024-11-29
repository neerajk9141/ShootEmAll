//
//  HandTrackingManager.swift
//  ShooteEmAll
//
//  Created by Quidich on 27/11/24.
//
import Foundation
import ARKit
import SwiftUI
import RealityKit

    /// A model that contains up-to-date hand coordinate information for spaceship control.

class SpaceshipGestureController: ObservableObject {
//    private var openPalmGesture: Gesture_OpenPalm!
//    @Published var isPalmOpen: Bool = false
//    @Published var handPosition: SIMD3<Float>? = nil
//    
//    init() {
//        super.init()
//        self.openPalmGesture = Gesture_OpenPalm(delegate: self) // Initialize gesture with delegate
//    }
//    
//    func updateHandJoints(_ handJoints: [[[SIMD3<Float>?]]]) {
//            // Feed joint data into the gesture detection system
//        openPalmGesture.checkGesture(handJoints: handJoints)
//    }
//    
//    func gesture(gesture: GestureBase, event: GestureDelegateEvent) {
//        switch event.type {
//        case .Began:
//            isPalmOpen = true
//            print("Open palm detected.")
//        case .Moved3D:
//            if let position = event.location.first as? SIMD3<Float> {
//                handPosition = position
//            }
//        case .Ended:
//            isPalmOpen = false
//            print("Open palm gesture ended.")
//        default:
//            break
//        }
//    }
}

