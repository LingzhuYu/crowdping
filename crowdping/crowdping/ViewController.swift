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
    var beaconNotNearbyObserver : AnyObject?
    var beaconRangedObserver : AnyObject?
    var beaconNotRangedObserver : AnyObject?
    var locationUpdatedObserver : AnyObject?
    
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var beaconButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var rssiField: UITextField!
    
    fileprivate var locationMonitoring = false
    fileprivate var beaconMonitoring = false
    fileprivate var beaconFound = false
    
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
        beaconNotNearbyObserver = notificationCentre.addObserver(forName: NSNotification.Name(rawValue: Notifications.BeaconNotNearby),
                                                              object: nil,
                                                              queue: nil)
        {
            (note) in
            let location = Notifications.getLocation(note)
            print("BeaconNotNearby received \(location)")
            
            if let location = location
            {
                self.beaconNotNearby(location)
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
        beaconNotRangedObserver = notificationCentre.addObserver(forName: NSNotification.Name(rawValue: Notifications.BeaconNotRanged),
                                                                 object: nil,
                                                                 queue: nil)
        {
            (note) in
            print("BeaconNotRanged received")
            self.beaconNotRanged()
        }
        locationUpdatedObserver = notificationCentre.addObserver(forName: NSNotification.Name(rawValue: Notifications.LocationUpdated),
                                                                 object: nil,
                                                                 queue: nil)
        {
            (note) in
            let location = Notifications.getLocation(note)
            print("LocationUpdated received \(location)")
            
            if let location = location
            {
                self.locationUpdated(location)
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
        latitudeField.backgroundColor = .green
        longitudeField.text = String(location.coordinate.longitude)
        longitudeField.backgroundColor = .green
    }
    
    fileprivate func beaconNotNearby(_ location: CLLocation!)
    {
        print("beaconNotNearby \(location)")
        latitudeField.text = ""
        longitudeField.text = ""
        latitudeField.text = String(location.coordinate.latitude)
        latitudeField.backgroundColor = .red
        longitudeField.text = String(location.coordinate.longitude)
        longitudeField.backgroundColor = .red
    }
    
    fileprivate func beaconRanged(_ rssi: Int)
    {
        print("beaconRanged \(rssi)")
        beaconFound = true
        rssiField.text = ""
        rssiField.text = String(rssi)
        rssiField.backgroundColor = .green
    }
    
    fileprivate func beaconNotRanged()
    {
        print("beaconNotRanged")
        beaconFound = false
        rssiField.text = "<not in range>"
        rssiField.backgroundColor = .red
    }
    
    fileprivate func locationUpdated(_ location: CLLocation!)
    {
        print("locationUpdated \(location)")
        latitudeField.text = ""
        longitudeField.text = ""
        latitudeField.text = String(location.coordinate.latitude)
        longitudeField.text = String(location.coordinate.longitude)
        
        if beaconFound
        {
            latitudeField.backgroundColor = .red
            longitudeField.backgroundColor = .red
        }
        else
        {
            latitudeField.backgroundColor = .green
            longitudeField.backgroundColor = .green
        }
    }
}
