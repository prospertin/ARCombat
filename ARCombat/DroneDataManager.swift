//
//  DroneDataManager.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 11/29/17.
//  Copyright © 2017 Prospertin. All rights reserved.
//

import Foundation

public class DroneDataManager: DataManagerInputProtocol {
    var interactor: DataManagerOutputProtocol?

    func retrieveDroneEntity(name: String) throws {
        
        // Hard code for now
        let droneEntity = DroneEntity(name: name, sourceUri: "art.scnassets/spitfire3.scn", x: 0, y:0, z:-10)
        //let droneEntity = DroneEntity(name: name, sourceUri: "art.scnassets/ship.scn", x: 0.2, y: -1, z: -3)
        //let droneEntity = DroneEntity(name: name, sourceUri: "art.scnassets/ship.scn", x: 1, y: 0, z: -3)
        self.interactor?.onDroneEntityRetrieved(drone: droneEntity)
    }
    
    
}
