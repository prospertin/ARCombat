//
//  WorldViewController.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 5/18/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARSCNViewController: UIViewController, ARSCNViewDelegate {

    
    let aircraftViewModel = AircraftViewModel()
    var aircraftView:AircraftView?
    var timer:Timer?
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func switchToggle(_ sender: UISwitch) {
        if sender.isOn {
            moveForward()
        } else {
            // ONLY USE TO PAUSE. Plane can not stop in mid air: aircraftViewModel.stopMovingForward(position: view.worldPosition, orientation: view.worldOrientation)
            aircraftViewModel.resetPosition()
        }
    }
    // MARK: - actions
    @IBAction func upLongPressed(_ sender: UILongPressGestureRecognizer) {
        executeRotation(r: Constants.kRotationRadianPerLoop, axe: CoordinateAxe.xAxe, sender: sender)
    }
    
    @IBAction func downLongPressed(_ sender: UILongPressGestureRecognizer) {
        executeRotation(r: -Constants.kRotationRadianPerLoop, axe: CoordinateAxe.xAxe, sender: sender)
    }
    
    @IBAction func moveLeftLongPressed(_ sender: UILongPressGestureRecognizer) {
       executeRotation(r: Constants.kRotationRadianPerLoop, axe: CoordinateAxe.yAxe, sender: sender)
       
    }
    
    @IBAction func moveRightLongPressed(_ sender: UILongPressGestureRecognizer) {
        executeRotation(r: -Constants.kRotationRadianPerLoop, axe: CoordinateAxe.yAxe, sender: sender)
       
    }
    // MARK: Routine Initializers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        setupScene()
    }

    func setupScene() {
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene//
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.autoenablesDefaultLighting = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        addAircraft()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: Private
    private func addAircraft() {
        if let view = aircraftViewModel.getAircraftView(name: "myAircraft") {
            sceneView.scene.rootNode.addChildNode(view)
            self.aircraftView = view
        }
    }
    
    @objc private func moveForward() {
        if let view = aircraftView {
            aircraftViewModel.moveForward(eulerAngles: view.eulerAngles)
        }
    }
    
    private func executeRotation(r: CGFloat, axe: CoordinateAxe, sender: UILongPressGestureRecognizer) {
        
        guard let view = aircraftView else {
            return
        }
        if sender.state == .ended {
            aircraftViewModel.stopRotate(axe: axe)
            if let tm = timer {
                aircraftViewModel.moveForward(eulerAngles: view.eulerAngles)
                tm.invalidate()
                timer = nil
            }
        } else if sender.state == .began {
            aircraftViewModel.beginRotate(angle: r, axe: axe)
            timer = Timer.scheduledTimer(timeInterval: Constants.kAnimationDurationMoving, target: self,
                                         selector: #selector(moveForward),
                                         userInfo: nil, repeats: true)
        }
    }

}
