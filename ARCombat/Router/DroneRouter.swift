//
//  DroneRouter.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 11/28/17.
//  Copyright © 2017 Prospertin. All rights reserved.
//

import Foundation
import UIKit

class DroneRouter: DroneRouterProtocol {
    
    func presentSettingPage(from view: DroneViewProtocol) {
    
    }
    
    
    static var mainStoryboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    class func createDroneViewController() -> UIViewController {
        //        let navController = mainStoryboard.instantiateViewController(withIdentifier: "DroneNavigationController")
        //        if let view = navController.childViewControllers.first as? DroneViewController {
        let view = mainStoryboard.instantiateViewController(withIdentifier: "DroneViewController") as! DroneViewController
        let presenter: DronePresenterProtocol & DroneInteractorOutputProtocol = DronePresenter()
        let interactor: DroneInteractorInputProtocol & DataManagerOutputProtocol = DroneInteractor()
        let dataManager: DataManagerInputProtocol = DroneDataManager()
        let router: DroneRouterProtocol = DroneRouter()
        
        view.presenter = presenter
        
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        interactor.dataManager = dataManager
        dataManager.interactor = interactor
        
        return view
        
    }
}
