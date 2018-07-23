//
//  Test.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 12/20/17.
//  Copyright © 2017 Prospertin. All rights reserved.
//

import Foundation
import ReactiveSwift
import CoreLocation

class UserLocationSource: NSObject, BindingSource {
    fileprivate let (locationSignal, locationSink) = Signal<CLLocation?, NSError>.pipe()
    typealias Value = CLLocation?
    typealias Error = NSError
    var producer: SignalProducer<CLLocation?, NSError> {
        return SignalProducer(locationSignal)
    }
    private let locationManager = CLLocationManager()
    override init() { super.init()
        locationManager.delegate = self
    }
    func startSourcingLocation() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
        } else { }
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension UserLocationSource: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationSink.send(value: locations.first)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationSink.send(error: error as NSError)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
}

class UserLocationPrinter:  BindingTargetProvider {
    private let (lifetime, token) = Lifetime.make()
    var bindingTarget: BindingTarget<CLLocation?>
    
    init() {
        bindingTarget =
            BindingTarget(lifetime: lifetime, action: UserLocationPrinter.printLocationIfAvailable)
        
    }
    
    static func printLocationIfAvailable(_ maybeLocation: CLLocation?) {
        if let location = maybeLocation {
            let c = location.coordinate
            print(c.latitude, c.longitude)
        }
    }
}
