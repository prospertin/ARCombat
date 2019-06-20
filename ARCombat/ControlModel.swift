//
//  JoystickModel.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 5/25/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//

import Foundation
import UIKit

public struct ControlModel: CustomStringConvertible {
    var roll = CGFloat.zero
    var pitch = CGFloat.zero
    var yaw = CGFloat.zero
    
    mutating func reset() {
        roll = CGFloat.zero
        pitch = CGFloat.zero
        yaw = CGFloat.zero
    }
    
    mutating func resetYaw() {
        yaw = CGFloat.zero
    }
    
    mutating func resetStick() {
        roll = CGFloat.zero
        pitch = CGFloat.zero
    }
    
    public var description: String {
        return "JoystickData(roll: \(roll) pitch: \(pitch) yaw:\(yaw))"
    }
}
