//
//  ViewController.swift
//  crowdping
//
//  Created by D'Arcy Smith on 2016-09-23.
//  Copyright © 2016 TerraTap Technologies, Inc. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Contacts

class RangeViewController: UIViewController
{
    @IBOutlet weak var notifyCircle: UIButton!
    let notificationCentre = NotificationCenter.default
    var beaconNotNearbyObserver : AnyObject?
    var beaconRangedObserver : AnyObject?
    var beaconNotRangedObserver : AnyObject?
    var locationUpdatedObserver : AnyObject?
    
    @IBOutlet weak var timeView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var notifySwitch: UISwitch!
    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var policeButton: UIButton!
    
    fileprivate var rssiValues : [Int] = []
    fileprivate var rssiAverage = Int.min
    fileprivate let maxRSSI = 70
    fileprivate let minRSSI = 50
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        notifySwitch.isOn      = State.isSearching
        circleButton.isEnabled = State.isSearching
        policeButton.isEnabled = State.isSearching
        
        if State.isSearching
        {
            State.timer?.invalidate()
            State.timer = Timer.scheduledTimer(timeInterval: 1,
                                               target: self,
                                               selector: #selector(RangeViewController.updateTime),
                                               userInfo: nil,
                                               repeats: true)
            updateTime()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        Notifications.removeObserver(beaconNotNearbyObserver, from: notificationCentre)
        Notifications.removeObserver(beaconRangedObserver,    from: notificationCentre)
        Notifications.removeObserver(beaconNotRangedObserver, from: notificationCentre)
        Notifications.removeObserver(locationUpdatedObserver, from: notificationCentre)
    }
    
    @IBAction func notifySwitchChanged(_ sender: AnyObject)
    {
        if notifySwitch.isOn
        {
            Notifications.postStartLocationMonitoring(self)
            Notifications.postStartBeaconMonitoring(self)
            State.timer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(RangeViewController.updateTime),
                                         userInfo: nil,
                                         repeats: true)
            State.startTime = NSDate()
        }
        else
        {
            Notifications.postStopLocationMonitoring(self)
            Notifications.postStopBeaconMonitoring(self)
            State.timer?.invalidate()
            State.timer = nil
            State.startTime = nil
            State.sendFoundNotificationToCircle()
        }
        
        State.isSearching      = notifySwitch.isOn
        circleButton.isEnabled = notifySwitch.isOn
        policeButton.isEnabled = notifySwitch.isOn
    }
    
    @IBAction func notifyCircle(_ sender: AnyObject)
    {
        let alertController = UIAlertController(
            title: "Notify Circle",
            message: "Notify the members of your circle to help you find Grandpa Joe?",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel)
        {
            (action) in
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(
            title: "OK",
            style: .default)
        {
            (action) in
            State.sendLostNotificationToCircle()
        }
        alertController.addAction(OKAction)
        
        present(alertController, animated: true)
        {
        }
    }
    
    @IBAction func notifyPolice(_ sender: AnyObject)
    {
        let alertController = UIAlertController(
            title: "Call the Police",
            message: "Call the police to help you find Grandpa Joe?",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel)
        {
            (action) in
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(
            title: "OK",
            style: .default)
        {
            (action) in
            State.callPolice()
        }
        alertController.addAction(OKAction)
        
        present(alertController, animated: true)
        {
        }
    }
    
    // MARK: internal
    
    fileprivate func beaconRanged(_ rssi: Int)
    {
        print("beaconRanged \(rssi)")
        State.beaconFound = true
        
        rssiValues.append(rssi * -1)
        
        if rssiValues.count < 5
        {
            imageView.backgroundColor = .green
            return
        }
        
        if rssiValues.count > 5
        {
            rssiValues.remove(at: 0)
        }
        
        let sum = rssiValues.reduce(0, +)
        let average = sum / rssiValues.count
        
        print("\(average) \(rssiAverage)")
        
        if average < rssiAverage
        {
            print("nearer")
        }
        else if average > rssiAverage
        {
            print("farther")
        }
        else
        {
            print("same")
        }
        
        rssiAverage = average

        // realAverage = 60
        // maxRSSI = 80
        // minRSSI = 30
        
        let distance = Int((Float(rssiAverage - minRSSI) / Float(maxRSSI - minRSSI)) * 100)
        
        if(distance > 80)
        {
            imageView.backgroundColor = .green
        }
        else if(distance > 70)
        {
            imageView.backgroundColor = .yellow
        }
        else
        {
            imageView.backgroundColor = .red
        }
        
        // imageView.image = UIImage(named: "CircleButton")
    }
    
    fileprivate func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage!
    {
        let scale     = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    fileprivate func beaconNotNearby(_ location: CLLocation!)
    {
        print("beaconNotNearby \(location)")
        returnToMap()
    }
    
    fileprivate func beaconNotRanged()
    {
        print("beaconNotRanged")
        returnToMap()
    }

    func returnToMap()
    {
        State.beaconFound = false
        rssiValues = []
        rssiAverage = Int.min
        let rangeViewController = self.storyboard?.instantiateViewController(withIdentifier: "map") as! MapViewController
        self.present(rangeViewController, animated: false)
    }
    
    func updateTime()
    {
        let interval = State.startTime!.timeIntervalSinceNow * -1
        let ti       = Int(interval)
        let seconds  = (ti % 60)
        let minutes  = (ti / 60) % 60
        let hours    = (ti / 3600)
        let str : String!
        
        if minutes < 2
        {
            str = String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
        }
        else
        {
            str = String(format: "%0.2d:%0.2d", hours, minutes)
        }
        
        timeView.text = str
    }
}
