//
//  AircraftView.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 5/18/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//

import UIKit
import ARKit
import ReactiveSwift

class AircraftView: SCNNode {
    var wrapperNode:SCNNode!
    
    init(positionChange: MutableProperty<SCNVector3?>, rotation: MutableProperty<SCNVector3?>) {
        super.init()
        wrapperNode = SCNNode()
        addChildNode(wrapperNode)
        
        positionChange.signal.observeValues { (pos:SCNVector3?) in
            if let pos = pos {
                if pos.x == 0 && pos.y == 0 && pos.z == 0 {
                    // Plane stop completely. Only happens if parked on the ground
                    self.removeAction(forKey: Constants.kForwardAction)
                } else {
                    let action = SCNAction.moveBy(x: CGFloat(pos.x), y: CGFloat(pos.y), z: CGFloat(pos.z), duration: Constants.kAnimationDurationMoving)
                    let loopAction = SCNAction.repeatForever(action)
                    self.runAction(loopAction, forKey: Constants.kForwardAction)
                }
            } else {
                let moveAction = SCNAction.move(to: Constants.aircraftStartPosition, duration: Constants.kAnimationDurationMoving)
                self.runAction(moveAction, forKey: Constants.kForwardAction)
                return
            }
        }
        
        rotation.signal.observeValues { (deltaRotation:SCNVector3?)in
            if let rot = deltaRotation {
                if rot.x == 0 && rot.y == 0 && rot.z == 0 {
                    // Stop current rotation
                } else {
                    debugPrint("Rotating: \(self.eulerAngles) in main thread \(Thread.isMainThread)")
                    self.eulerAngles.x += rot.x
                    self.eulerAngles.y += rot.y
                    //self.eulerAngles.z += rot.z
                    self.wrapperNode.eulerAngles.z += rot.z // Rotate the wrapper and not the aircraft view, so the yaw is parallel and the pitch perpendicular to the horizon. This is to simplify the calculationa and easier for the user too.
                }
            } else {
                // Reset to the original orientation if rotation is nil
                self.eulerAngles.x = 0
                self.eulerAngles.y = 0
                //self.eulerAngles.z = 0
                self.wrapperNode.eulerAngles.z = 0  // Rotate the wrapper so the yaw is parallel to the earth
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
