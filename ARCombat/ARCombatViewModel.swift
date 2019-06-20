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
    var joystickOutputData = MutableProperty<ControlModel?>(nil)
    
    let aircraftViewModel = AircraftViewModel()
    var timer:Timer?
    
    func getAircraftView(name: String) -> AircraftView? {
        return aircraftViewModel.getAircraftView(name: name)
    }
    
    @objc func aircraftMoveForward() {
        aircraftViewModel.moveForward()
    }
    
    func resetAircraftPosition() {
        timer?.invalidate()
        timer = nil
        aircraftViewModel.resetPosition()
    }
    
    func aircraftRotate(rotation: SCNVector3) {
        aircraftViewModel.rotate(rotation: rotation)
    }
    
    func getJoystickView(width: CGFloat, height: CGFloat) -> AircraftControllerSKScene {
        joystickOutputData.signal.observeValues { (data:ControlModel?) in
            if let data = data {
                //debugPrint("Model pitch: \(data.pitch) roll: \(data.roll) yaw: \(data.yaw)")
                let rotVector = SCNVector3(Float(-data.pitch) * Constants.kRotationFactor, Float(-data.yaw) * Constants.kYawFactor, Float(-data.roll) * Constants.kRotationFactor)
                
                if rotVector.equals(SCNVector3Zero){
                    debugPrint("Stop rotate")
                    self.timer?.invalidate()
                    self.timer = nil;
                    self.aircraftViewModel.moveForward()
                } else {
                    debugPrint("Start rotate \(data.description)")
                    self.aircraftRotate(rotation: rotVector)
                    if self.timer != nil {
                        return
                    }
                    self.timer = Timer.scheduledTimer(timeInterval: Constants.kAnimationDurationMoving, target: self,
                                                      selector: #selector(self.aircraftMoveForward),
                                                      userInfo: nil, repeats: true)
                }
            } else {
               self.aircraftViewModel.moveForward()
            }
        }
        
        let scene = AircraftControllerSKScene(size: CGSize(width: width, height: height), data:joystickOutputData)
        scene.scaleMode = .resizeFill
        
        return scene
    }
}
