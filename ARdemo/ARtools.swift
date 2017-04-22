//
//  ARtools.swift
//  ARdemo
//
//  Created by Chris Woodard on 4/13/17.
//  Copyright © 2017 UsefulSoft. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

typealias ARcallBack = (ARdatum) -> Void

struct ARlocation {
    let lat:Double
    let lon:Double
    let heading:Double
    let speed:Double
}

struct ARorientation {
    let pitch:Double
    let yaw:Double
    let roll:Double
}

struct ARcompass {
    let x:Double
    let y:Double
    let degrees:Double
}

struct ARdatum {
    let location:ARlocation?
    let orientation:ARorientation?
    let compass:ARcompass?
}

class ARtools: NSObject, CLLocationManagerDelegate {

    var locMgr:CLLocationManager? = nil
    var mMgr:CMMotionManager? = nil
    var callBack:ARcallBack? = nil
    
    //current data
    var currentLocation:ARlocation? = nil
    var currentOrientation:ARorientation? = nil
    var currentCompass:ARcompass? = nil
    
    override init() {
        self.locMgr = CLLocationManager()
        self.mMgr = CMMotionManager()
        self.mMgr?.deviceMotionUpdateInterval = 0.5
    }
    
    convenience init(cb:@escaping ARcallBack) {
        self.init()
        self.locMgr?.delegate = self
        self.callBack = cb
    }
    
    func startTracking() {
        if let deviceMotionAvailable = self.mMgr?.isDeviceMotionAvailable {
            if deviceMotionAvailable {
                self.mMgr?.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main, withHandler: {[weak self] (data:CMDeviceMotion?, error:Error?) in
                    
                    guard let data = data else { return }

                    let attitude = data.attitude
                    let orientation = ARorientation(pitch: attitude.pitch, yaw: attitude.yaw, roll: attitude.roll)
                    self?.currentOrientation = orientation
                    
                    if let callBack = self?.callBack {
                        let datum = ARdatum(location: self?.currentLocation, orientation: self?.currentOrientation, compass: self?.currentCompass)
                        callBack(datum)
                    }
                })
            }
        }
    }
    
    func stopTracking() {
        self.locMgr?.stopUpdatingLocation()
        self.locMgr?.stopUpdatingHeading()
        self.mMgr?.stopDeviceMotionUpdates()
    }
    
    func askPermissionAndStartTracking() {
        self.locMgr?.requestWhenInUseAuthorization()
    }
    
//MARK: - LocationManager delegates -

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == .authorizedWhenInUse) {
            self.startTracking()
            self.locMgr?.startUpdatingLocation()
            self.locMgr?.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            let lat = loc.coordinate.latitude
            let lon = loc.coordinate.longitude
            let heading = loc.course
            let speed = loc.speed
            self.currentLocation = ARlocation(lat:lat, lon:lon, heading: heading, speed: speed)
            if let callBack = self.callBack {
                let datum = ARdatum(location: self.currentLocation, orientation: self.currentOrientation, compass: self.currentCompass)
                callBack(datum)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {

        let headingInRadians = 3.1415927 * newHeading.trueHeading / 180.0
        let headingSin = sin(headingInRadians)
        let headingCosine = cos(headingInRadians)
        
        let compass = ARcompass(x: headingCosine, y: headingSin, degrees: newHeading.trueHeading)
        
        self.currentCompass = compass
        
        if let callBack = self.callBack {
            let datum = ARdatum(location: self.currentLocation, orientation: self.currentOrientation, compass: self.currentCompass)
            callBack(datum)
        }
    }
    
//MARK: - CMMotionManager handler -
    
}
