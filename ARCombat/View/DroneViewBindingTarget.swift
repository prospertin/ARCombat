//
//  DroneViewBindingTargetProvider.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 12/22/17.
//  Copyright © 2017 Prospertin. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift

class DroneViewBindingTarget: BindingTargetProvider {
    var bindingTarget: BindingTarget<PositionChange?>
    private let (lifetime, token) = Lifetime.make()
    typealias Value = PositionChange?
    
    init(view: DroneView) {
        let moveToPosition: (PositionChange?) -> () = { delta in
            if let d = delta {
                if d.axe == CoordinateAxe.none {
                    if d.dX == 0 && d.dX == 0 && d.dZ == 0 {
                        view.removeAction(forKey: DroneView.kForwardAction)
                    } else {
                        view.updatePosition(node: view, x: CGFloat(d.dX), y: CGFloat(d.dY), z: CGFloat(d.dZ))
                    }
                } else {
                    if d.rotation != 0 {
                        if d.axe == CoordinateAxe.yAxe {
                            view.incrementalYawn(angle: CGFloat(d.rotation))
                        } else {
                            view.incrementalRotate(angle: CGFloat(d.rotation), axe: d.axe)
                        }
                    } else {
                        view.removeAction(forKey: DroneView.kIncrementalRotationAction)
                        view.rotateTo(node: view.wrapperNode, angle: CGFloat(-d.rotation), axe: CoordinateAxe.zAxe)
                    }
                }
            } else {
                view.removeAllActions()
            }
        }
        bindingTarget = BindingTarget<PositionChange?>(lifetime: lifetime, action: moveToPosition)
    }
}
