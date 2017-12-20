//
//  DroneInteractor.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 11/28/17.
//  Copyright © 2017 Prospertin. All rights reserved.
//

import Foundation

public class DroneInteractor: DroneInteractorInputProtocol, DataManagerOutputProtocol {
    
    var presenter: DroneInteractorOutputProtocol?
    var dataManager: DataManagerInputProtocol?
    
    func retrieveDrone(name: String) {
        do {
            try self.dataManager?.retrieveDroneEntity(name: name);
        } catch _ {
            
        }
    }
    
    func onDroneEntityRetrieved(drone: DroneEntity) {
        presenter?.didRetrieveDroneEntity(drone)
    }
    
    func onError(errorMsg: String) {
        
    }
    
    
}
