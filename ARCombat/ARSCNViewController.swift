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
        view.isHidden = false
        return view
    }()
    
    let mainViewModel = ARCombatViewModel()
    
    var aircraftView:AircraftView?
 
//    @IBAction func switchToggle(_ sender: UISwitch) {
//        if sender.isOn {
//            mainViewModel.aircraftMoveForward(eulerAngles: aircraftView!.eulerAngles)
//        } else {
//            // ONLY USE TO PAUSE. Plane can not stop in mid air: aircraftViewModel.stopMovingForward(position: view.worldPosition, orientation: view.worldOrientation)
//            mainViewModel.resetAircraftPosition()
//        }
//    }
    // MARK: - actions
    // MARK: Routine Initializers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupARSCNView()
        setupSKView()
        setupSKViewScene()
    }

    func setupARSCNView() {
        // Create a new scene and set the scene to the view
        arscnView.scene = SCNScene()
        // Add arscnView to main view
        view.addSubview(arscnView)
        arscnView.setContraintsToFillSuperview()
        // Set the view's delegate
        arscnView.delegate = self
        // Show statistics such as fps and timing information
        arscnView.showsStatistics = true
        arscnView.autoenablesDefaultLighting = true
        
     //   arscnView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }
    //Setup the SK view that contains the SK joystick ViewScene
    func setupSKView() {
        view.addSubview(skView)
        skView.setConstraints(nil,
                              left: view.leftAnchor,
                              bottom: view.bottomAnchor,
                              right: view.rightAnchor,
                              topConstant: 0,
                              leftConstant: 0,
                              bottomConstant: 0,
                              rightConstant: 0,
                              widthConstant: 0,
                              heightConstant: 180)
    }
    //Add the joystick viewScene to the skview
    func setupSKViewScene() {
        let scene = mainViewModel.getJoystickView(width: view.bounds.size.width, height: 180)
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        // skView.showsFPS = true
        //    skView.showsNodeCount = true
        //    skView.showsPhysics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        arscnView.session.run(configuration)
        addAircraft()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        arscnView.session.pause()
    }
    
    // MARK: Private
    private func addAircraft() {
        if let view = mainViewModel.getAircraftView(name: "myAircraft") {
            arscnView.scene.rootNode.addChildNode(view)
            self.aircraftView = view
        }
    }
}
