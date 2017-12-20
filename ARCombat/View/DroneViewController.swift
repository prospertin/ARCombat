//
//  ViewController.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 10/31/17.
//  Copyright © 2017 Prospertin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation

class DroneViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, DroneViewProtocol {
    
    @IBOutlet var sceneView: ARSCNView!
    let kStartingPosition = SCNVector3(0, 0, -0.6)
    let kAnimationDurationMoving: TimeInterval = 0.2
    let kMovingLengthPerLoop: CGFloat = 0.05
    let kRotationRadianPerLoop: CGFloat = 0.2
    let myDrone = DroneView()
    
    var lm:CLLocationManager!
    
    //VIPER
    var presenter: DronePresenterProtocol?
    
    // MARK: - actions
    @IBAction func upLongPressed(_ sender: UILongPressGestureRecognizer) {
        let action = SCNAction.moveBy(x: 0, y: kMovingLengthPerLoop, z: 0, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    
    @IBAction func downLongPressed(_ sender: UILongPressGestureRecognizer) {
        let action = SCNAction.moveBy(x: 0, y: -kMovingLengthPerLoop, z: 0, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    
    @IBAction func moveLeftLongPressed(_ sender: UILongPressGestureRecognizer) {
        let x = -deltas().cos
        let z = deltas().sin
        myDrone.entity?.xPos = Float(x)
        myDrone.entity?.zPos = Float(z)
        moveDrone(x: x, z: z, sender: sender)
    }
    
    @IBAction func moveRightLongPressed(_ sender: UILongPressGestureRecognizer) {
        let x = deltas().cos
        let z = -deltas().sin
        myDrone.entity?.xPos.value = Float(x)
        myDrone.entity?.zPos.value = Float(z)
        moveDrone(x: x, z: z, sender: sender)
    }
    
    @IBAction func moveForwardLongPressed(_ sender: UILongPressGestureRecognizer) {
        let x = -deltas().sin
        let z = -deltas().cos
        moveDrone(x: x, z: z, sender: sender)
    }
    
    @IBAction func moveBackLongPressed(_ sender: UILongPressGestureRecognizer) {
        let x = deltas().sin
        let z = deltas().cos
        moveDrone(x: x, z: z, sender: sender)
    }
    
    @IBAction func rotateLeftLongPressed(_ sender: UILongPressGestureRecognizer) {
        rotateDrone(yRadian: kRotationRadianPerLoop, sender: sender)
    }
    
    @IBAction func rotateRightLongPressed(_ sender: UILongPressGestureRecognizer) {
        rotateDrone(yRadian: -kRotationRadianPerLoop, sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        setupScene()
        lm = CLLocationManager()
        lm.delegate = self
            
        lm.startUpdatingHeading()
        
    }
    
    func setupScene() {
        // Create a new scene
        let scene = SCNScene() //SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene//
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        //let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        //sceneView.session.run(configuration)
        setupConfiguration()
        presenter?.startDrone(name: "myDrone")
        //addDrone()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: -
    func showDrone(with drone: DroneEntity?){
        if let dr = drone {
            self.addDrone(entity: dr)
        }
    }
    func onError(errorMsg: String) {
        
    }
    
    func showLoading() {
        
    }
    
    func hideLoading() {
        
    }
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func setupConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
// MARKS: - location
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("Data \(newHeading.magneticHeading)")
    }
    
    private func addDrone(entity: DroneEntity) {
        myDrone.loadDroneView(entity: entity)
        myDrone <~ entity
        sceneView.scene.rootNode.addChildNode(myDrone)
    }
    
    // MARK: - private helpers to handle SCNAction
    private func rotateDrone(yRadian: CGFloat, sender: UILongPressGestureRecognizer) {
        let action = SCNAction.rotateBy(x: 0, y: yRadian, z: 0, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    
    private func moveDrone(x: CGFloat, z: CGFloat, sender: UILongPressGestureRecognizer) {
        let action = SCNAction.moveBy(x: x, y: 0, z: z, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    
    private func execute(action: SCNAction, sender: UILongPressGestureRecognizer) {
        let loopAction = SCNAction.repeatForever(action)
        if sender.state == .began {
            myDrone.runAction(loopAction)
        } else if sender.state == .ended {
            myDrone.removeAllActions()
        }
    }
    
    private func deltas() -> (sin: CGFloat, cos: CGFloat) {
        return (sin: kMovingLengthPerLoop * CGFloat(sin(myDrone.eulerAngles.y)), cos: kMovingLengthPerLoop * CGFloat(cos(myDrone.eulerAngles.y)))
    }
}

