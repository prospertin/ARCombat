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
        let droneEntity = DroneEntity(name: name, sourceUri: "art.scnassets/drone.scn", x: 0, y: 0, z: 0)
        self.interactor?.onDroneEntityRetrieved(drone: droneEntity)
    }
    
    
}
