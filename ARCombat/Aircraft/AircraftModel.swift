//
//  AircraftModel.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 5/18/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//
import ARKit

class AircraftModel {
    
    var name: String?
    var sourceUri: String?
    
    var xPos: Float = 0
    var yPos: Float = 0
    var zPos: Float = 0
    var rotation: Float = 0
    var eulers:SCNVector3 = SCNVector3Zero
    
    init(name: String, sourceUri: String, x: Float, y: Float, z: Float) {
        self.name = name
        self.sourceUri = sourceUri
        self.xPos = x
        self.yPos = y
        self.zPos = z
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
    
    public func updateOrientation(eulers: SCNVector3) {
        self.eulers.x += eulers.x
        self.eulers.y += eulers.y
        self.eulers.z += eulers.z
    }
}
