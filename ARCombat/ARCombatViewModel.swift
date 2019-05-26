//
//  ARCombatViewModel.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 5/25/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//

import Foundation
import ReactiveSwift
import ARKit

class ARCombatViewModel {
    var joystickOutputData = MutableProperty<JoystickModel?>(nil)
    
    let joystickViewModel = JoystickViewModel()
    let aircraftViewModel = AircraftViewModel()
    var timer:Timer?
    
    func getAircraftView(name: String) -> AircraftView? {
        return aircraftViewModel.getAircraftView(name: name)
    }
    
    @objc func aircraftMoveForward() {
        aircraftViewModel.moveForward()
    }
    
    func resetAircraftPosition() {
        aircraftViewModel.resetPosition()
    }
    
    func aircraftBeginRotate(rotation: SCNVector3) {
        aircraftViewModel.beginRotate(rotation: rotation)
    }
    
    func aircraftStopRotate() {
        aircraftViewModel.stopRotate()
    }
    
    func getJoystickView(width: CGFloat, height: CGFloat) -> ARJoystickSKScene {
        joystickOutputData.signal.observeValues { (data:JoystickModel?) in
            if let data = data {
                let rotVector = SCNVector3(Float(-data.pitch) * Constants.kRotationFactor, Float.zero, Float(-data.roll) * Constants.kRotationFactor)
                self.aircraftBeginRotate(rotation: rotVector)
                self.timer = Timer.scheduledTimer(timeInterval: Constants.kAnimationDurationMoving, target: self,
                                                  selector: #selector(self.aircraftMoveForward),
                                                  userInfo: nil, repeats: true)
            } else {
                self.aircraftStopRotate()
            }
        }
        return joystickViewModel.getJoystickView(width: width, height: height, outputData: joystickOutputData)
    }
}
