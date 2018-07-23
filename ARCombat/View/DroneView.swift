//
//  DroneView.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 11/26/17.
//  Copyright © 2017 Prospertin. All rights reserved.
//
import UIKit
import ARKit
import SceneKit
import ReactiveCocoa
import ReactiveSwift

class DroneView: SCNNode {
    
    static let kIncrementalRotationAction: String = "incrementalRotate"
    static let kForwardAction: String = "forward"
    static let kRotateToAction: String = "rotateTo"
    
    let kMovingLengthPerLoop: Float = 0.7
    var entity:DroneEntity?
    let kAnimationDurationMoving: TimeInterval = 0.2
    let kAnimationDurationYawn: TimeInterval = 2.0
    let kYawnRollFactor: CGFloat = 6 // Roll an angle of kYawnRollFactor time the incremental rotation angle
    var timer:Timer?
    var yawnTimer:Timer?
    
    let wrapperNode:SCNNode = SCNNode()
    
    func loadDroneView(entity: DroneEntity) {
        self.entity = entity
        guard let uri = entity.sourceUri else { return }
        guard let virtualObjectScene = SCNScene(named: uri) else { return }
       // let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        addChildNode(wrapperNode)
        position = SCNVector3(entity.xPos, entity.yPos, entity.zPos)
        rotation = SCNVector4Zero //SCNVector4Make(0, 1, -0.3, GLKMathDegreesToRadians(180))
        self.pivot = SCNMatrix4MakeTranslation(0, 0, -self.boundingBox.min.z)
    }
    
    public func updatePosition(node: SCNNode, x: CGFloat, y: CGFloat, z: CGFloat) {
        let action = SCNAction.moveBy(x: x, y: y, z: z, duration: kAnimationDurationMoving)
        let loopAction = SCNAction.repeatForever(action)
        self.runAction(loopAction, forKey: DroneView.kForwardAction)
    }
    
    public func rotateTo(node: SCNNode, angle: CGFloat, axe: CoordinateAxe) {
        let action = SCNAction.rotateTo(x: axe == .xAxe ? angle : 0,
                                        y: axe == .yAxe ? angle : 0,
                                        z: axe == .zAxe ? angle : 0,
                                        duration: kAnimationDurationYawn)
        //let loopAction = SCNAction.(action, count: count)
        node.runAction(action, forKey: DroneView.kRotateToAction)
    }
    
    public func incrementalRotate(node: SCNNode, angle: CGFloat, axe: CoordinateAxe) {
        let action = SCNAction.rotateBy(x: axe == .xAxe ? angle : 0,
                                        y: axe == .yAxe ? angle : 0,
                                        z: axe == .zAxe ? angle : 0,
                                        duration: kAnimationDurationMoving)
        let loopAction = SCNAction.repeatForever(action)
        self.runAction(loopAction, forKey: DroneView.kIncrementalRotationAction)
    }
    
    public func incrementalYawn(angle: CGFloat) {
        incrementalRotate(node: self, angle: angle, axe: CoordinateAxe.yAxe)
        rotateTo(node: self.wrapperNode, angle: angle * kYawnRollFactor, axe: CoordinateAxe.zAxe)
    }
    
    public func beginRotate(angle: CGFloat, axe: CoordinateAxe) {
        //let delta = PositionChange(dX: 0, dY: 0, dZ: 0, rotation: Float(angle), axe: axe)
        if axe == CoordinateAxe.yAxe {
            self.incrementalYawn(angle: CGFloat(angle))
        } else {
            self.incrementalRotate(node: self, angle: CGFloat(angle), axe: axe)
        }
        //entity?.startPositionChange(positionChange: delta)
        if let _ = self.action(forKey: DroneView.kForwardAction) {
            timer = Timer.scheduledTimer(timeInterval: kAnimationDurationMoving, target: self,
                                             selector: #selector(DroneView.moveForward),
                                             userInfo: nil, repeats: true)
        }
    }
    
    public func stopRotate(axe: CoordinateAxe) {
        self.removeAction(forKey: DroneView.kIncrementalRotationAction)
        // Make sure to roll back to horizontal position after a yawn
        self.rotateTo(node: self.wrapperNode, angle: CGFloat(0), axe: CoordinateAxe.zAxe)
        if let tm = timer {
            moveForward()
            tm.invalidate()
            timer = nil
        }
        
        let pos = self.worldPosition
        let orientation = self.worldOrientation
        entity?.updatePosition(x: pos.x, y: pos.y, z: pos.z, r: orientation.w)
        print("x: \(pos.x) y: \(pos.y) z: \(pos.z) r: \(orientation.w)")
    }
    
//    @objc func roll(timer: Timer) {
//        let angle = timer.userInfo as! CGFloat
//        rotateTo(angle: angle, axe: CoordinateAxe.zAxe)
//        timer.invalidate()
//    }
    
    @objc func moveForward() {
        debugRotation()
        let x = deltaX(angleY: self.eulerAngles.y, angleX: self.eulerAngles.x) //Float(deltasHorizontal().sin)
        let z = deltaZ(angleY: self.eulerAngles.y, angleX: self.eulerAngles.x) //Float(deltasHorizontal().cos)
        let y = deltaY(angleY: self.eulerAngles.y, angleX: self.eulerAngles.x) //Float(deltasVertical().sin)
        print("dx: \(x) dy: \(y) dz: \(z)")
//        let delta = PositionChange(dX: x, dY: y, dZ: z, rotation: 0, axe: CoordinateAxe.none)
        self.updatePosition(node: self, x: CGFloat(x), y: CGFloat(y), z: CGFloat(z))
//        entity?.startPositionChange(positionChange: delta)
    }
    
    func stopMovingForward() {
        self.removeAction(forKey: DroneView.kForwardAction)
        // TODO try remove the line below
        let orientation = self.worldOrientation
        let pos = self.worldPosition
        entity?.updatePosition(x: pos.x, y: pos.y, z: pos.z, r: orientation.w)
        print("x: \(pos.x) y: \(pos.y) z: \(pos.z) r: \(orientation.w)")
    }
    
    func resetPosition() {
        let action = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: kAnimationDurationMoving)
        self.runAction(action, forKey: DroneView.kRotateToAction)
        wrapperNode.runAction(action, forKey: DroneView.kRotateToAction)
        
        let v = SCNVector3(0,0,-10)
        let moveAction = SCNAction.move(to: v, duration: kAnimationDurationMoving)
        self.runAction(moveAction, forKey: DroneView.kForwardAction)
        
    }
    
    private func deltaZ(angleY: Float, angleX: Float) -> Float {
        // On X-Z plane rotate around Y (start from -Z axis
        let deplacementByY = abs(kMovingLengthPerLoop * cos(angleY))
        let deplacement = abs(deplacementByY * cos(angleX))
        let degreeY = radianToDegree(radian: angleY)
        let degreeX = radianToDegree(radian: angleX)
        
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
    
    private func deltaX(angleY: Float, angleX: Float) -> Float {
        // On X-Z plane rotate around Y (start from -Z axis)
        let deplacement = abs(kMovingLengthPerLoop * sin(angleY))
        let degreeY = radianToDegree(radian: angleY)
        let degreeX = radianToDegree(radian: angleX)
        
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
        let deplacement = abs(kMovingLengthPerLoop * sin(angleX))
        //let degreeY = radianToDegree(radian: angleY)
        let degreeX = radianToDegree(radian: angleX)
        
        switch degreeX {
        case 180 ..< 360, -180 ..< 0: //1st and 2nd quadrants
            return -deplacement
        case -360 ..< -180, 0 ..< 180: //3rd and 4th quadrants
            return deplacement
        default:
            return 0
        }
    }
    
    private func radianToDegree(radian: Float) -> Int {
        return Int((180/Float.pi * radian).truncatingRemainder(dividingBy:360))
    }
    
    func debugRotation() {
        debugPrint("Euler X: \(radianToDegree(radian: eulerAngles.x))", "Y: \(radianToDegree(radian: eulerAngles.y))", "Z: \(radianToDegree(radian: eulerAngles.z))")
    }
    
    func debugPosition() {
        let pos = self.worldPosition
        let orientation = self.worldOrientation
        debugPrint("Position x: \(pos.x) y: \(pos.y) z: \(pos.z) r: \(orientation.w)")
    }
}

enum CoordinateAxe {
    case none
    case xAxe
    case yAxe
    case zAxe
}
