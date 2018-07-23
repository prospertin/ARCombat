//
//  DronePresenter.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 11/28/17.
//  Copyright © 2017 Prospertin. All rights reserved.
//

import Foundation

public class DronePresenter: DronePresenterProtocol, DroneInteractorOutputProtocol {
    
    weak var view: DroneViewProtocol?
    var interactor: DroneInteractorInputProtocol?
    var router: DroneRouterProtocol?
    
    func didRetrieveDroneEntity(_ drone: DroneEntity) {
        view?.showDrone(with: drone)
    }
    
    func onError(errorMsg: String) {
        
    }
    
    func startDrone(name: String) {
        interactor?.retrieveDrone(name: name)
    }

    func moveDrone(entity: DroneEntity, dX: Float, dY: Float, dZ: Float) {
        entity.xPos += dX
        entity.yPos += dY
        entity.xPos += dZ
    }
    
}
