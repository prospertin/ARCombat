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
    let startButtonOnLabel = "Start"
    let startButtonOffLabel = "Stop"
    
    lazy var skView: SKView = {
        let view = SKView()
        view.isMultipleTouchEnabled = true
        view.backgroundColor = .clear
        view.isHidden = false
        return view
    }()
    
    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(startStopGame), for: .touchUpInside)
        return button
    }()
    
    let mainViewModel = ARCombatViewModel()
    var aircraftView:AircraftView?
    var joytickView:AircraftControllerSKScene?
    
    //let yawSlider = YawSlidecoderme: .zero)
    
    // MARK: - actions
    // MARK: Routine Initializers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupARSCNView()
        setupSKView()
        setupSKViewScene()
     //   setupYawSliderView()
        setupStartButton()
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
        joytickView = scene
        joytickView?.aircraftController.isUserInteractionEnabled = false
        // skView.showsFPS = true
        //    skView.showsNodeCount = true
        //    skView.showsPhysics = true
    }
    
    func setupStartButton() {
        view.addSubview(startButton)
        startButton.setTitle(startButtonOnLabel, for: .normal)
        startButton.setConstraints(nil,
                                   left: nil,
                                   bottom: view.bottomAnchor,
                                   right: nil,
                                   topConstant: 0,
                                   leftConstant: 0,
                                   bottomConstant: 20,
                                   rightConstant: 0,
                                   widthConstant: 80,
                                   heightConstant: 30)
        startButton.anchorCenterXToSuperview()
    }
    
    @objc func startStopGame() {
        if startButton.currentTitle == startButtonOnLabel {
            joytickView?.aircraftController.isUserInteractionEnabled = true
            mainViewModel.aircraftRotate(rotation: self.aircraftView!.eulerAngles) // Initialize to original orientation
            mainViewModel.aircraftViewModel.moveForward() // aircraftMoveForward()
            startButton.setTitle(startButtonOffLabel, for: .normal)
        } else {
            joytickView?.aircraftController.reset() //Reset the command first before resetting the position else, it still forwards
            joytickView?.aircraftController.isUserInteractionEnabled = false
            mainViewModel.resetAircraftPosition()
            startButton.setTitle(startButtonOnLabel, for: .normal)
        }
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
