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
import ReactiveSwift
import ReactiveCocoa

class DroneViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, DroneViewProtocol {
    let kStartingPosition = SCNVector3(0, 0, -0.6)
    let kAnimationDurationMoving: TimeInterval = 0.2
    //let kMovingLengthPerLoop: Float = 0.5
    let kRotationRadianPerLoop: CGFloat = 0.1
    let kRollRadians: CGFloat = 0.6
    let kSpeed: CGFloat = 1.00
    let myDrone:DroneView = DroneView()
    var currentEntity:DroneEntity? = nil
   // var droneBindingTarget: DroneViewBindingTarget? = nil
    var lm:CLLocationManager!
    
    //VIPER
    var presenter: DronePresenterProtocol?
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func switchToggle(_ sender: UISwitch) {
        if sender.isOn {
            myDrone.moveForward()
        } else {
            myDrone.stopMovingForward()
            myDrone.resetPosition()
        }
    }
    // MARK: - actions
    @IBAction func upLongPressed(_ sender: UILongPressGestureRecognizer) {
        executeRotation(r: kRotationRadianPerLoop, axe: CoordinateAxe.xAxe, sender: sender)
    }
    
    @IBAction func downLongPressed(_ sender: UILongPressGestureRecognizer) {
        executeRotation(r: -kRotationRadianPerLoop, axe: CoordinateAxe.xAxe, sender: sender)
    }
    
    @IBAction func moveLeftLongPressed(_ sender: UILongPressGestureRecognizer) {
       // executeDiscreetRotation(r: -kRollRadians, axe: CoordinateAxe.zAxe)
        executeRotation(r: kRotationRadianPerLoop, axe: CoordinateAxe.yAxe, sender: sender)
    }
    
    @IBAction func moveRightLongPressed(_ sender: UILongPressGestureRecognizer) {
       // executeDiscreetRotation(r: kRollRadians, axe: CoordinateAxe.zAxe)
        executeRotation(r: -kRotationRadianPerLoop, axe: CoordinateAxe.yAxe, sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        setupScene()
        
//        lm = CLLocationManager()
//        lm.delegate = self
//
//        lm.startUpdatingHeading()
        //addCube()
    }
    
    private func addCube() {
        // The 3D cube geometry we want to draw
        let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)
        // The node that wraps the geometry so we can add it to the scene
        let boxNode = SCNNode(geometry:boxGeometry)
        // Position the box just in front of the camera
        boxNode.position = SCNVector3Make(0, 0, -0.5);
        // rootNode is a special node, it is the starting point of all
        // the items in the 3D scene
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    func setupScene() {
        // Create a new scene
        let scene = SCNScene() //SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene//
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.autoenablesDefaultLighting = true
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
        currentEntity = entity
        //Bind view to data
//        droneBindingTarget = DroneViewBindingTarget(view: myDrone)
//        droneBindingTarget! <~ currentEntity!
        sceneView.scene.rootNode.addChildNode(myDrone)
        myDrone.debugRotation()
    }
    
    private func executeRotation(r: CGFloat, axe: CoordinateAxe, sender: UILongPressGestureRecognizer) {
        myDrone.debugRotation()
        if sender.state == .ended {
            myDrone.stopRotate(axe: axe)
        } else if sender.state == .began {
            myDrone.beginRotate(angle: r, axe: axe)
        }
    }
}

