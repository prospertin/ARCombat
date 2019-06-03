//
//  AircraftViewModel.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 5/18/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//

import ARKit
import ReactiveSwift

class AircraftViewModel: NSObject {

    var model:AircraftModel!
    var positionChange = MutableProperty<SCNVector3?>(nil)
    var rotation = MutableProperty<SCNVector3?>( nil)
    
    func getAircraftView(name: String) -> AircraftView? {
        model = AircraftModel(name: name, sourceUri: "art.scnassets/rafspitfire.scn",
                              x:Constants.aircraftStartPosition.x,
                              y:Constants.aircraftStartPosition.y,
                              z:Constants.aircraftStartPosition.z)
        
        guard let uri = model.sourceUri else { return nil }
        guard let objectScene = SCNScene(named: uri) else { return nil }
        
        let view = AircraftView(positionChange: positionChange, rotation:rotation)
        for child in objectScene.rootNode.childNodes {
            view.wrapperNode.addChildNode(child)
        }
        resetPosition()
        //view.pivot = SCNMatrix4MakeTranslation(0, 0, 0) //-view.boundingBox.min.z)
        return view
    }
    
    @objc func moveForward() {
        let eulerAngles = model.eulers
        let x = deltaX(angleY: eulerAngles.y, angleX: eulerAngles.x)
        let z = deltaZ(angleY: eulerAngles.y, angleX: eulerAngles.x)
        let y = deltaY(angleY: eulerAngles.y, angleX: eulerAngles.x)
        //debugPrint("---> Move Forward \(Thread.isMainThread) x: \(x) y: \(y) z: \(z)");
        // This trigger view update
        positionChange.value = SCNVector3(x: x, y: y, z: z)
    }
    
    @objc func stopMovingForward(position: SCNVector3, orientation: SCNVector4) {
        positionChange.value = SCNVector3(x: 0, y: 0, z: 0)
        // Just update the model with the latest position and orientation
        model.updatePosition(x: position.x, y: position.y, z: position.z, r: orientation.w)
    }
    
    @objc func resetPosition() {
        positionChange.value = nil
        rotation.value = nil
        model.eulers = SCNVector3Zero
    }
    
    public func rotate(rotation: SCNVector3) {
        self.rotation.value = rotation
        model.updateOrientation(eulers: rotation)
    }

    private func deltaX(angleY: Float, angleX: Float) -> Float {
        // On X-Z plane rotate around Y (start from -Z axis)
        let deplacement = abs(Constants.kMovingLengthPerLoop * sin(angleY))
        let degreeY = angleY.radiansToDegrees // radianToDegree(radian: angleY)
        let degreeX = angleX.radiansToDegrees //radianToDegree(radian: angleX)
        
        switch degreeY {
        case 180 ..< 360, -180 ..< 0: //1st and 2nd quadrants
            switch degreeX {
            case -90 ..< 90, 270 ..< 360:
                return deplacement
            case 90 ..< 270, -270 ..< -90:
                return -deplacement
            default:
                return 0
            }
        case 0 ..< 180, -360 ..< -180: // 3rd and 4th quadrants
            switch degreeX {
            case -90 ..< 90, 270 ..< 360:
                return -deplacement
            case 90 ..< 270, -270 ..< -90:
                return deplacement
            default:
                return 0
            }
        default:
            return 0
        }
    }
    
    private func deltaY(angleY: Float, angleX: Float) -> Float {
        // On Y-Z plane rotate around X (start from -Z axis
        let deplacement = abs(Constants.kMovingLengthPerLoop * sin(angleX))
        //let degreeY = radianToDegree(radian: angleY)
        let degreeX = angleX.radiansToDegrees //radianToDegree(radian: angleX)
        
        switch degreeX {
        case 180 ..< 360, -180 ..< 0: //1st and 2nd quadrants
            return -deplacement
        case -360 ..< -180, 0 ..< 180: //3rd and 4th quadrants
            return deplacement
        default:
            return 0
        }
    }
    
    private func deltaZ(angleY: Float, angleX: Float) -> Float {
        // On X-Z plane rotate around Y (start from -Z axis
        let deplacementByY = abs(Constants.kMovingLengthPerLoop * cos(angleY))
        let deplacement = abs(deplacementByY * cos(angleX))
        let degreeY = angleY.radiansToDegrees //radianToDegree(radian: angleY)
        let degreeX = angleX.radiansToDegrees //radianToDegree(radian: angleX)
        
        switch degreeY {
        case -90 ..< 90, -360 ... -270, 270 ..< 360: //1st and 4th quadrants on XZ plane
            switch degreeX {
            case -90 ..< 90, 270 ..< 360: //1st and 4th quadrants on YZ plane
                return -deplacement
            case -279 ..< -90, 90 ..< 270: // 2nd and 3rd quadrants on the YZ plane
                return deplacement
            default:
                return 0
            }
        case -270 ..< -90, 90 ..< 270: // 2nd and 3rd quadrants
            switch degreeX {
            case -90 ..< 90, 270 ..< 360: //1st and 4th quadrants on YZ plane
                return deplacement
            case -279 ..< -90, 90 ..< 270: // 2nd and 3rd quadrants on the YZ plane
                return -deplacement
            default:
                return 0
            }
        default:
            return 0
        }
    }
}
