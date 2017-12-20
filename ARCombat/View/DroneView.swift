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

class DroneView: SCNNode, BindingTargetProvider {
    
    var bindingTarget: BindingTarget<PositionChange?>
    private let (lifetime, token) = Lifetime.make()
    typealias Value = PositionChange?
    let moveToPosition: (PositionChange?) -> () = { delta in
    }
    var entity:DroneEntity?
    
    let kAnimationDurationMoving: TimeInterval = 0.2
    
    override init() {
        bindingTarget = BindingTarget(lifetime: lifetime, action: moveToPosition)
        super.init() // super init after instance variable are inited
    }

    required init?(coder aDecoder: NSCoder) {
        bindingTarget = BindingTarget(lifetime: lifetime, action: moveToPosition)
        super.init(coder: aDecoder)
    }
    
    func loadDroneView(entity: DroneEntity) {
        self.entity = entity
        guard let uri = entity.sourceUri else { return }
        guard let virtualObjectScene = SCNScene(named: uri) else { return }
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        addChildNode(wrapperNode)
        position = SCNVector3(entity.xPos, entity.yPos, entity.zPos)
        rotation = SCNVector4Zero
    }
    
    func updateHorizontalPosition(x: CGFloat, z: CGFloat, sender: UILongPressGestureRecognizer) {
        let action = SCNAction.moveBy(x: x, y: 0, z: z, duration: kAnimationDurationMoving)
        let loopAction = SCNAction.repeatForever(action)
        if sender.state == .began {
            self.runAction(loopAction)
        } else if sender.state == .ended {
            self.removeAllActions()
        }
        
    }
    
    
    private func execute(action: SCNAction, sender: UILongPressGestureRecognizer) {
        let loopAction = SCNAction.repeatForever(action)
        if sender.state == .began {
            self.runAction(loopAction)
        } else if sender.state == .ended {
            self.removeAllActions()
        }
    }

}
