//
//  DroneEntity.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 11/28/17.
//  Copyright © 2017 Prospertin. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public class DroneEntity: BindingSource {
    public typealias Value = PositionChange?
    public typealias Error = NoError  // No other choice?
    
    fileprivate let (positionSignal, positionSink) = Signal<PositionChange?, Error>.pipe()
    public var producer: SignalProducer<PositionChange?, Error> {
        return SignalProducer(positionSignal)
    }
    
    var name: String?
    var sourceUri: String?
    var xPos: Float = 0
    var yPos: Float = 0
    var zPos: Float = 0
    var rotation: Float = 0
    
    init(name: String, sourceUri: String, x: Float, y: Float, z: Float) {
        self.name = name
        self.sourceUri = sourceUri
        self.xPos = x
        self.yPos = y
        self.zPos = z
    }
    
    public func startPositionChange(positionChange: PositionChange?) {
        positionSink.send(value: positionChange)
    }
    
    public func stopPositionChange() {
        // Set everything to 0 to stop
        let deltaStop = PositionChange(dX: 0, dY: 0, dZ: 0, rotation: 0, axe: CoordinateAxe.none)
        positionSink.send(value: deltaStop)
    }
    
    public func updatePosition(x: Float, y: Float, z: Float, r: Float) {
        self.xPos = x
        self.yPos = y
        self.zPos = z
        self.rotation = (self.rotation + r)
        if self.rotation > (2 * Float.pi) {
            self.rotation = 0
        }
    }
}

public struct PositionChange {
    var dX: Float = 0
    var dY: Float = 0
    var dZ: Float = 0
    var rotation: Float = 0
    var axe: CoordinateAxe = CoordinateAxe.none
}

