////
////  Gesture_OpenPalm.swift
////  ShooteEmAll
////
////  Created by Quidich on 29/11/24.
////
//
//import Foundation
//import SwiftUI
//
//
//class Gesture_OpenPalm: GestureBase {
//    
//    override init() {
//        super.init()
//    }
//    
//        // Convenience init with delegate
//    convenience init(delegate: Any) {
//        self.init()
//        self.delegate = delegate as? any GestureDelegate
//    }
//    
//        // Gesture judging loop
//    override func checkGesture(handJoints: [[[SIMD3<Scalar>?]]]) {
//        self.handJoints = handJoints
//        switch state {
//        case .unknown:  // Initial state
//            if isPalmOpen() {
//                delegate?.gesture(gesture: self, event: GestureDelegateEvent(type: .Began, location: [CGPointZero]))
//                state = State.waitForRelease
//            }
//        case .waitForRelease:
//            if !isPalmOpen() {
//                delegate?.gesture(gesture: self, event: GestureDelegateEvent(type: .Ended, location: [CGPointZero]))
//                state = State.unknown
//            } else {
//                    // Update the bat's position if the palm is open
//                if let handPosition = jointPosition(hand: .right, finger: .wrist, joint: .tip) {
//                    delegate?.gesture(gesture: self, event: GestureDelegateEvent(type: .Moved3D, location: [handPosition as Any]))
//                }
//            }
//        default:
//            break
//        }
//    }
//    
//        // Check if all fingers are straight (indicating an open palm)
//    func isPalmOpen() -> Bool {
//        if handJoints.count > 0 {
//                // Check each finger to see if it's straight
//            var straightCount = 0
//            if isStraight(hand: .right, finger: .thumb) { straightCount += 1 }
//            if isStraight(hand: .right, finger: .index) { straightCount += 1 }
//            if isStraight(hand: .right, finger: .middle) { straightCount += 1 }
//            if isStraight(hand: .right, finger: .ring) { straightCount += 1 }
//            if isStraight(hand: .right, finger: .little) { straightCount += 1 }
//            
//                // If all 5 fingers are straight, it's an open palm
//            if straightCount == 5 { return true }
//        }
//        return false
//    }
//}
