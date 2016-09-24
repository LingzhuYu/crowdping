//
//  ViewController.swift
//  crowdping
//
//  Created by D'Arcy Smith on 2016-09-23.
//  Copyright © 2016 TerraTap Technologies, Inc. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController
{
    let notificationCentre = NotificationCenter.default
    var beaconNearbyObserver : AnyObject?
    var beaconRangedObserver : AnyObject?
    
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var beaconButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var rssiField: UITextField!
    
    fileprivate var locationMonitoring = false
    fileprivate var beaconMonitoring = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        beaconNearbyObserver = notificationCentre.addObserver(forName: NSNotification.Name(rawValue: Notifications.BeaconNearby),
                                                              object: nil,
                                                              queue: nil)
        {
            (note) in
            let location = Notifications.getLocation(note)
            print("BeaconNearby received \(location)")
            
            if let location = location
            {
                self.beaconNearby(location)
            }
        }
        beaconRangedObserver = notificationCentre.addObserver(forName: NSNotification.Name(rawValue: Notifications.BeaconRanged),
                                                              object: nil,
                                                              queue: nil)
        {
            (note) in
            let rssi = Notifications.getRssi(note)
            print("BeaconRanged received \(rssi)")
            
            if let rssi = rssi
            {
                self.beaconRanged(rssi)
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func locationPressed(_ sender: AnyObject)
    {
        print("locationPressed")
        
        if locationMonitoring
        {
            Notifications.postStopLocationMonitoring(self)
        }
        else
        {
            Notifications.postStartLocationMonitoring(self)
        }
        
        locationMonitoring = !locationMonitoring
    }
    
    @IBAction func beaconPressed(_ sender: AnyObject)
    {
        print("beaconPressed")
        
        if beaconMonitoring
        {
            Notifications.postStopBeaconMonitoring(self)
        }
        else
        {
            Notifications.postStartBeaconMonitoring(self)
        }
        
        beaconMonitoring = !beaconMonitoring
    }
    
    // MARK: internal
    
    fileprivate func beaconNearby(_ location: CLLocation!)
    {
        print("beaconNearby \(location)")
        latitudeField.text = ""
        longitudeField.text = ""
        latitudeField.text = String(location.coordinate.latitude)
        longitudeField.text = String(location.coordinate.longitude)
    }
    
    fileprivate func beaconRanged(_ rssi: Int)
    {
        print("beaconRanged \(rssi)")
        rssiField.text = ""
        rssiField.text = String(rssi)
    }
}
