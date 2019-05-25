//
//  JoystickSKScene.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 5/23/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//

import SpriteKit

public class ARJoystickSKScene: SKScene {
    enum NodesZPosition {
        case joystick
    }
    
    lazy var analogJoystick: AnalogJoystick = {
        let joystick = AnalogJoystick(diameter: 100, colors: nil, images: (substrate: #imageLiteral(resourceName: "joystickbase"), stick: #imageLiteral(resourceName:"joystick")))
        return joystick
    }()
    
    override public func didMove(to view: SKView) {
        self.backgroundColor = .clear
        setupNodes()
        setupJoystick()
    }
    
    func setupNodes() {
        anchorPoint = CGPoint(x: 0.0, y: 0.0)
    }
    
    func setupJoystick() {
        addChild(analogJoystick)
        
        analogJoystick.trackingHandler = { [unowned self] data in
            //      NotificationCenter.default.post(name: joystickNotificationName, object: nil, userInfo: ["data": data])
        }
        
    }
}
