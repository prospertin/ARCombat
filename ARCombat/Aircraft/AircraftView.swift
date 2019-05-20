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
    
    init(positionChange: MutableProperty<SCNVector3?>, rotation: MutableProperty<SCNVector4?>) {
        super.init()
        wrapperNode = SCNNode()
        addChildNode(wrapperNode)
        
        positionChange.signal.observeValues { (pos:SCNVector3?) in
            if let pos = pos {
                if pos.x == 0 && pos.y == 0 && pos.z == 0 {
                    // Plane stop completely
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
        
        rotation.signal.observeValues { (viewRotation:SCNVector4?)in
            if let rot = viewRotation {
                if rot.x == 0 && rot.y == 0 && rot.z == 0 {
                    // Stop current rotation
                    self.removeAction(forKey: Constants.kIncrementalRotationAction)
                    //Hack for now: create auto roll if yaw. Remove when implement separate yaw and roll
                    let roll = SCNAction.rotateTo(x: 0, y: 0, z: CGFloat(0),
                                                  duration: Constants.kAnimationDurationYawn)
                    // NOTE Make the wrapper node roll NOT 'self' node
                    self.wrapperNode.runAction(roll, forKey: Constants.kRotateToAction)
                    
                } else {
                    let action = SCNAction.rotateBy(x: CGFloat(rot.x),
                                                    y: CGFloat(rot.y),
                                                    z: CGFloat(rot.z),
                                                    duration: TimeInterval(rot.w))
                    let loopAction = SCNAction.repeatForever(action)
                    self.runAction(loopAction, forKey: Constants.kIncrementalRotationAction)
                    //Hack for now: create auto roll if yaw. Remove when implement separate yaw and roll
                    if rot.y != 0 {
                        let roll = SCNAction.rotateTo(x: 0, y: 0, z: CGFloat(rot.y) * Constants.kYawnRollFactor,
                                                      duration: Constants.kAnimationDurationYawn)
                        // NOTE Make the wrapper node roll NOT 'self' node
                        self.wrapperNode.runAction(roll, forKey: Constants.kRotateToAction)
                    }
                }
            } else {
                // Reset to the original orientation if nil
                let action = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: Constants.kAnimationDurationMoving)
                self.runAction(action, forKey: Constants.kRotateToAction)
                self.wrapperNode.runAction(action, forKey: Constants.kRotateToAction)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
