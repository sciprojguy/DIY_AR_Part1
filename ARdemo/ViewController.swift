//
//  ViewController.swift
//  ARdemo
//
//  Created by Chris Woodard on 4/13/17.
//  Copyright © 2017 UsefulSoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var arTools:ARtools? = nil
    
    @IBOutlet weak var gpsLat: UILabel!
    @IBOutlet weak var gpsLon: UILabel!
    @IBOutlet weak var gpsHeading: UILabel!
    
    @IBOutlet weak var compassVector: UILabel!
    @IBOutlet weak var compassDegrees: UILabel!
    
    @IBOutlet weak var attitudePitch: UILabel!
    @IBOutlet weak var attitudeRoll: UILabel!
    @IBOutlet weak var attitudeYaw: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.arTools = ARtools(cb: { datum in
        
            self.gpsLat.text = "\(datum.location!.lat)"
            self.gpsLon.text = "\(datum.location!.lon)"
            self.gpsHeading.text = "\(datum.location!.heading)"
            
            self.compassVector.text = "\(datum.compass?.x ?? 0.0), \(datum.compass?.y ?? 0.0))"
            self.compassDegrees.text = "\(datum.compass?.degrees ?? 0.0) deg"
            
            self.attitudePitch.text = "\(datum.orientation?.pitch ?? 0.0)"
            self.attitudeRoll.text = "\(datum.orientation?.roll ?? 0.0)"
            self.attitudeYaw.text = "\(datum.orientation?.yaw ?? 0.0)"
        })
        
        self.arTools?.askPermissionAndStartTracking()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

