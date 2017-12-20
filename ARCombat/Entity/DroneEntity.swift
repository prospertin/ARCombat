//
//  DroneEntity.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 11/28/17.
//  Copyright © 2017 Prospertin. All rights reserved.
//

import Foundation
import ReactiveSwift

public class DroneEntity: BindingSource {
    fileprivate let (positionSignal, positionSink) = Signal<PositionChange?, NSError>.pipe()
    public var producer: SignalProducer<PositionChange?, NSError> {
        return SignalProducer(positionSignal)
    }
    public typealias Value = PositionChange?
    public typealias Error = NSError
    
    var name: String?
    var sourceUri: String?
    var xPos: Float = 0
    var yPos: Float = 0
    var zPos: Float = 0
    
    init(name: String, sourceUri: String, x: Float, y: Float, z: Float) {
        self.name = name
        self.sourceUri = sourceUri
        self.xPos = x
        self.yPos = y
        self.zPos = x
    }
    
    public func updatePosition(positionChange: PositionChange) {
        positionSink.send(value: positionChange)
        self.xPos += positionChange.dX
        self.yPos += positionChange.dY
        self.zPos += positionChange.dZ
    }
}

public struct PositionChange {
    var dX: Float = 0
    var dY: Float = 0
    var dZ: Float = 0
}
