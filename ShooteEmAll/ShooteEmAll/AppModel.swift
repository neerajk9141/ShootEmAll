//
//  AppModel.swift
//  ShooteEmAll
//
//  Created by Quidich on 25/11/24.
//

import SwiftUI
import RealityKit
/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    static var anchor: AnchorEntity?
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
}
