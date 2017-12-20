//
//  DroneProtocol.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 11/28/17.
//  Copyright © 2017 Prospertin. All rights reserved.
//

import Foundation
import UIKit

// MARK: View
protocol DroneViewProtocol: class {
    var presenter: DronePresenterProtocol? { get set }
    
    // PRESENTER -> VIEW
    func showDrone(with drone: DroneEntity?)
    
    func onError(errorMsg: String)
    
    func showLoading()
    
    func hideLoading()
}

// MARK: Presenter
protocol DronePresenterProtocol: class {
    var view: DroneViewProtocol? { get set }
    var interactor: DroneInteractorInputProtocol? { get set }
    var router: DroneRouterProtocol? { get set }
    
    // PRESENTER -> INTERACTOR
    func startDrone(name: String)
    func moveDrone(entity: DroneEntity, dX: Float, dY: Float, dZ: Float)
}

// MARK: Interactor
protocol DroneInteractorInputProtocol: class {
    var presenter: DroneInteractorOutputProtocol? { get set }
    var dataManager: DataManagerInputProtocol? { get set }
    
    func retrieveDrone(name: String)
}

protocol DroneInteractorOutputProtocol: class {
    // INTERACTOR -> PRESENTER
    func didRetrieveDroneEntity(_ drone: DroneEntity)
    func onError(errorMsg: String)
}

// MARK: Router
protocol DroneRouterProtocol: class {
    static func createDroneViewController() -> UIViewController
    // PRESENTER -> ROUTER
    func presentSettingPage(from view: DroneViewProtocol)
}

// MARK: Entity/model
protocol DataManagerInputProtocol: class {
    var interactor:DataManagerOutputProtocol? { get set }
    
    // INTERACTOR -> DATAMANAGER
    func retrieveDroneEntity(name: String) throws
}

protocol DataManagerOutputProtocol: class {
    // DATAMANAGER -> INTERACTOR
    func onDroneEntityRetrieved(drone: DroneEntity)
    func onError(errorMsg: String)
}



