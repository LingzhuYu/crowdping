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

class ViewController: UIViewController, MKMapViewDelegate
{
    @IBOutlet weak var notifyCircle: UIButton!
    let notificationCentre = NotificationCenter.default
    var beaconNearbyObserver : AnyObject?
    var beaconNotNearbyObserver : AnyObject?
    var beaconRangedObserver : AnyObject?
    var beaconNotRangedObserver : AnyObject?
    var locationUpdatedObserver : AnyObject?
    
    @IBOutlet weak var timeView: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var notifySwitch: UISwitch!
    @IBOutlet weak var policeButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    fileprivate var beaconFound = false
    fileprivate var annotations : [MKAnnotation] = []
    fileprivate var timer : Timer?
    fileprivate var startTime : NSDate?
    
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
        
        mapView.delegate          = self
        mapView.showsUserLocation = true
        mapView.showsScale        = true
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func notifySwitchChanged(_ sender: AnyObject)
    {
        if notifySwitch.isOn
        {
            Notifications.postStartLocationMonitoring(self)
            Notifications.postStartBeaconMonitoring(self)
            timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(ViewController.updateTime),
                                     userInfo: nil,
                                     repeats: true)
            startTime = NSDate()
        }
        else
        {
            Notifications.postStopLocationMonitoring(self)
            Notifications.postStopBeaconMonitoring(self)
            timer?.invalidate()
            timer = nil
            startTime = nil
        }
        
        circleButton.isEnabled = notifySwitch.isOn
        policeButton.isEnabled = notifySwitch.isOn
    }
    
    @IBAction func notifyCircle(_ sender: AnyObject)
    {
    }
    
    @IBAction func notifyPolice(_ sender: AnyObject)
    {
    }
    
    // MARK: internal
    
    fileprivate func beaconNearby(_ location: CLLocation!)
    {
        print("beaconNearby \(location)")
        addLocation(location, found: true)
    }
    
    fileprivate func beaconNotNearby(_ location: CLLocation!)
    {
        print("beaconNotNearby \(location)")
        addLocation(location, found: false)
    }
    
    fileprivate func beaconRanged(_ rssi: Int)
    {
        print("beaconRanged \(rssi)")
        beaconFound = true
    }
    
    fileprivate func beaconNotRanged()
    {
        print("beaconNotRanged")
        beaconFound = false
    }
    
    fileprivate func locationUpdated(_ location: CLLocation!)
    {
        print("locationUpdated \(location)")
        
        addLocation(location, found: beaconFound)
        
        if beaconFound
        {
        }
        else
        {
        }
    }
    
    fileprivate func clearAnnotations()
    {
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
    }
    
    func addLocation(_ location : CLLocation, found : Bool)
    {
        let annotation  = LocationAnotation(location.coordinate, found: found)
        
        annotations.append(annotation)
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: true)
        mapView.camera.altitude *= 1.5
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        // log.debug("enter")
        
        if let _ = annotation as? MKUserLocation
        {
            // log.debug("exit")
            return nil
        }
        
        var view: MKPinAnnotationView
        let identifier = "pin"
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKPinAnnotationView
        {
            dequeuedView.annotation = annotation
            view                    = dequeuedView
        }
        else
        {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = false
            
//            view.canShowCallout = true
//            view.calloutOffset  = CGPoint(x: -5, y: 5)
//            view.rightCalloutAccessoryView  = UIButton(type: .detailDisclosure) as UIView
        }
        
        if let annotation = annotation as? LocationAnotation
        {
            if annotation.found
            {
                view.pinTintColor = UIColor.green
            }
            else
            {
                view.pinTintColor = UIColor.red
            }
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl)
    {
        let _ = view.annotation as! LocationAnotation
    }
    /*
    func mapItem(_ view : MKAnnotationView) -> MKMapItem
    {
        let addressDictionary = [String(CNPostalAddressStreetKey) : view.annotation!.title!!]
        let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    */
    
    func updateTime()
    {
        let interval = startTime!.timeIntervalSinceNow * -1
        let ti       = Int(interval)
        let minutes  = (ti / 60) % 60
        let hours    = (ti / 3600)
        
        timeView.text = String(format: "%0.2d:%0.2d", hours, minutes)
    }
}
