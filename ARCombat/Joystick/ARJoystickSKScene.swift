//
//  JoystickSKScene.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 5/23/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//

import SpriteKit
import ReactiveSwift

public class ARJoystickSKScene: SKScene {
    enum NodesZPosition: CGFloat {
        case joystick
    }
    
    lazy var analogJoystick: AnalogJoystick = {
        let js = AnalogJoystick(diameter: 100, colors: nil, images: (substrate: #imageLiteral(resourceName: "joystickbase"), stick: #imageLiteral(resourceName:"joystick")))
        js.position = CGPoint(x: js.radius + 45, y: js.radius - 25)
//        js.zPosition = NodesZPosition.joystick.rawValue
        return js
    }()
    
    var outputData:MutableProperty<JoystickModel?>!
    
    init(size: CGSize, data:MutableProperty<JoystickModel?>) {
        super.init(size: size)
        outputData = data
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func didMove(to view: SKView) {
        self.backgroundColor = .clear
        setupNodes()
        setupJoystick()
    }
    
    func setupNodes() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5) // Origin is center of the container view
    }
    
    func setupJoystick() {
        addChild(analogJoystick)
        
        analogJoystick.trackingHandler = { [unowned self] data in
            self.outputData.value = data
        }
        
        analogJoystick.stopHandler = {
            self.outputData.value = nil
        }
        
    }
}
