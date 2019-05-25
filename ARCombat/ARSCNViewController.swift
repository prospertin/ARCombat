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

    let arscnView = ARSCNView()
    lazy var skView: SKView = {
        let view = SKView()
        view.isMultipleTouchEnabled = true
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    let aircraftViewModel = AircraftViewModel()
    var aircraftView:AircraftView?
    var timer:Timer?
    
    @IBOutlet weak var joystick: UIView!
    
  //  @IBOutlet var sceneView: ARSCNView!
    
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
        setupARSCNView()
       // setupSKView()
    }

    func setupARSCNView() {
        // Create a new scene and set the scene to the view
        arscnView.scene = SCNScene()
        // Set the view's delegate
        arscnView.delegate = self
        // Show statistics such as fps and timing information
        arscnView.showsStatistics = true
        arscnView.autoenablesDefaultLighting = true
        arscnView.setContraintsToFillSuperview()
        // Add arscnView to main view
        view.addSubview(arscnView)
        arscnView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }

    func setupSKView() {
        view.addSubview(skView)
//        skView.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 180)
    }
    
    func setupSKViewScene() {
        let scene = ARJoystickSKScene(size: CGSize(width: view.bounds.size.width, height: 180))
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        //    skView.showsFPS = true
        //    skView.showsNodeCount = true
        //    skView.showsPhysics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        arscnView.session.run(configuration)
      //  addAircraft()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        arscnView.session.pause()
    }
    
    // MARK: Private
    private func addAircraft() {
        if let view = aircraftViewModel.getAircraftView(name: "myAircraft") {
            arscnView.scene.rootNode.addChildNode(view)
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
