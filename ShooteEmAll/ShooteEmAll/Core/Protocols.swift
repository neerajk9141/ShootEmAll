//
//  Protocols.swift
//  ShooteEmAll
//
//  Created by Quidich on 26/11/24.
//

protocol Movable {
    var speed: Float { get set }
    func updatePosition()
}

protocol Shootable {
    func fire()
}
