//
//  Constants.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 5/19/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class Constants {
    static let kIncrementalRotationAction: String = "incrementalRotate"
    static let kForwardAction: String = "forward"
    static let kRotateToAction: String = "rotateTo"
    
    static let kRotationRadianPerLoop: CGFloat = 0.1
    static let kRollRadians: CGFloat = 0.6
    static let kSpeed: CGFloat = 3.00
    static let kMovingLengthPerLoop: Float = 0.7
    static let kAnimationDurationMoving: TimeInterval = 0.2
    static let kAnimationDurationYawn: TimeInterval = 2.0
    static let kYawFactor: Float = 0.0003
    static let kRotationFactor: Float = 0.0005
    static let aircraftStartPosition = SCNVector3(x: 0, y: 0, z: -5)
    static let joystickVelocityMultiplier: CGFloat = 0.00005
}

enum CoordinateAxe {
    case none
    case xAxe
    case yAxe
    case zAxe
}
