//
//  AircraftControllerSKScene
//  ARCombat
//
//  Created by Thinh Nguyen on 5/23/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//

import SpriteKit
import ReactiveSwift

public class AircraftControllerSKScene: SKScene {
    enum NodesZPosition: CGFloat {
        case joystick
    }
    
    lazy var aircraftController: AircraftController = {
        let js = AircraftController(width: 300, colors: nil, images: (stickBase: #imageLiteral(resourceName: "joystickbase"), stick: #imageLiteral(resourceName:"joystick"), yawSlider: #imageLiteral(resourceName:"pedal")), positions: nil)
     //   js.position = CGPoint(x: js.radius + 45, y: js.radius - 25)
        js.position = CGPoint.zero
//        js.zPosition = NodesZPosition.joystick.rawValue
        return js
    }()
    
    var outputData:MutableProperty<ControlModel?>!
    
    init(size: CGSize, data:MutableProperty<ControlModel?>) {
        super.init(size: size)
        outputData = data
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func didMove(to view: SKView) {
        self.backgroundColor = .clear
        setupNodes()
        setupController()
    }
    
    func setupNodes() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5) // Origin is center of the container view
    }
    
    func setupController() {
        addChild(aircraftController)
        
        aircraftController.trackingHandler = { [unowned self] data in
            if var model = self.outputData.value {
                model.pitch = data.pitch
                model.roll = data.roll
                model.yaw = data.yaw
                self.outputData.value = model
            } else {
                self.outputData.value = ControlModel(roll: data.roll, pitch: data.pitch, yaw: data.yaw)
            }
        }
        
        aircraftController.stopRoratingHandler = {
            self.outputData.value = nil
        }
        
    }
}
