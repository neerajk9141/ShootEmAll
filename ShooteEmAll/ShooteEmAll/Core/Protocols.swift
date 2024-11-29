//
//  Protocols.swift
//  ShooteEmAll
//
//  Created by Quidich on 26/11/24.
//

import RealityFoundation

protocol Movable {
    var speed: Float { get set }
    func updatePosition()
}

protocol Shootable {
    func fire(sceneAnchor: AnchorEntity)
}
