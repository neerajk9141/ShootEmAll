//
//  HandTrackProcess.swift
//  TableTennisGame
//
//  Created by Quidich on 18/09/24.
//

import Foundation
import CoreGraphics
import SwiftUI
import Vision
import ARKit
import Combine

class HandTrackingManager: ObservableObject {
    let session = ARKitSession() // VisionOS ARKit session
    var handTracking = HandTrackingProvider()
    @Published var isPalmOpen: Bool = false
    @Published var handPosition: SIMD3<Float>? = nil
    
    func start() async {
        do {
            if HandTrackingProvider.isSupported {
                print("Starting ARKit session for VisionOS hand tracking.")
                try await session.run([handTracking]) // Initialize the hand tracking session
                await publishHandTrackingUpdates()
            } else {
                print("Hand tracking is not supported on this device.")
            }
        } catch {
            print("Failed to start ARKit session: \(error)")
        }
    }
    
    private func publishHandTrackingUpdates() async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .updated:
                let anchor = update.anchor
                print("Anchor updated: \(anchor.chirality ?? .none)")
                    // Ensure the hand is tracked
                guard anchor.isTracked else {
                    self.isPalmOpen = false
                    return
                }
                
                    // Process the hand skeleton for open palm detection
                if let skeleton = anchor.handSkeleton {
                    print("Got hand skeleton")
                    self.processHandSkeleton(skeleton)
                }
            default:
                break
            }
        }
    }
    
    private func processHandSkeleton(_ skeleton: HandSkeleton) {
            // Access required joints (wrist and finger tips)
        let wrist = skeleton.joint(.wrist)
        let thumbTip = skeleton.joint(.thumbTip)
        let indexTip = skeleton.joint(.indexFingerTip)
        let middleTip = skeleton.joint(.middleFingerTip)
        let ringTip = skeleton.joint(.ringFingerTip)
        let littleTip = skeleton.joint(.littleFingerTip)
        
            // Ensure all joints are tracked
        guard wrist.isTracked,
              thumbTip.isTracked,
              indexTip.isTracked,
              middleTip.isTracked,
              ringTip.isTracked,
              littleTip.isTracked else {
                // If any joint is not tracked, set palmOpen to false and return
            DispatchQueue.main.async {
                self.isPalmOpen = false
                self.handPosition = nil
            }
            return
        }
        
            // Calculate wrist position in world space
        let wristPosition = SIMD3<Float>(
            wrist.anchorFromJointTransform.columns.3.x,
            wrist.anchorFromJointTransform.columns.3.y,
            wrist.anchorFromJointTransform.columns.3.z
        )
        
            // Check if fingers are extended (straight)
        let isThumbExtended = isFingerExtended(wrist, thumbTip)
        let isIndexExtended = isFingerExtended(wrist, indexTip)
        let isMiddleExtended = isFingerExtended(wrist, middleTip)
        let isRingExtended = isFingerExtended(wrist, ringTip)
        let isLittleExtended = isFingerExtended(wrist, littleTip)
        
            // Determine if the palm is open based on all fingers being extended
        let palmOpen = isThumbExtended && isIndexExtended && isMiddleExtended && isRingExtended && isLittleExtended
        
            // Update the state on the main thread
        DispatchQueue.main.async {
            self.isPalmOpen = palmOpen
            self.handPosition = palmOpen ? wristPosition : nil
        }
    }
    
    private func isFingerExtended(_ wrist: HandSkeleton.Joint, _ fingerTip: HandSkeleton.Joint) -> Bool {
            // Calculate wrist and finger tip positions
        let wristPosition = SIMD3<Float>(
            wrist.anchorFromJointTransform.columns.3.x,
            wrist.anchorFromJointTransform.columns.3.y,
            wrist.anchorFromJointTransform.columns.3.z
        )
        let fingerTipPosition = SIMD3<Float>(
            fingerTip.anchorFromJointTransform.columns.3.x,
            fingerTip.anchorFromJointTransform.columns.3.y,
            fingerTip.anchorFromJointTransform.columns.3.z
        )
        
            // Compute the distance between wrist and finger tip
        let distance = simd_distance(wristPosition, fingerTipPosition)
        
            // Consider the finger extended if the distance exceeds a threshold
        return distance > 0.05 // Adjust threshold as needed
    }
}

private extension simd_float4x4 {
    var xyz: SIMD3<Float> {
        return SIMD3(x: columns.3.x, y: columns.3.y, z: columns.3.z)
    }
}
