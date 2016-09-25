//
//  AppDelegate.swift
//  crowdping
//
//  Created by D'Arcy Smith on 2016-09-24.
//  Copyright © 2016 TerraTap Technologies, Inc. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox
import CoreLocation
import CoreBluetooth
import UserNotifications
import Alamofire

extension Data {
    func hexString() -> String {
        var token: String = ""
        for i in 0..<self.count {
            token += String(format: "%02.2hhx", self[i] as CVarArg)
        }
        
        return "\(token)"
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate
{    
    var window: UIWindow?
    let notificationCentre = NotificationCenter.default
    var startLocationMonitoringObserver : AnyObject?
    var stopLocationMonitoringObserver : AnyObject?
    var startBeaconMonitoringObserver : AnyObject?
    var stopBeaconMonitoringObserver : AnyObject?
    let locationManager = CLLocationManager()
    var peripheralManager : CBPeripheralManager!
    var rangedRegions : [CLBeaconRegion] = []
    var beaconsSeen : [(major : Int, minor : Int)] = []
    var newBeacons : [(major : Int, minor : Int)] = []
    var clearBeacons = false
    var desiredMajor : Int? = nil
    var desiredMinor : Int? = nil
    var currentLocation : CLLocation? = nil
    var isInRange = false
    var foo = false
    let APIKey = "7NxSEeut--6JUnTVlcldQ-ZqUo9oM9-6"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // Notifications configuration
        
        let notificationSettings = UIUserNotificationSettings(
            types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        
        // End Firebase configuration
        
        desiredMajor = 1
        desiredMinor = 1
        
        // Override point for customization after application launch.
        locationManager.requestAlwaysAuthorization()
        let options = [CBCentralManagerOptionShowPowerAlertKey : true]
        peripheralManager = CBPeripheralManager(delegate: self,
                                               queue: DispatchQueue.global(),
                                               options: options)
        
        locationManager.delegate                           = self
        locationManager.desiredAccuracy                    = kCLLocationAccuracyNearestTenMeters
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType                       = .other
        
        if #available(iOS 9.0, *)
        {
            locationManager.allowsBackgroundLocationUpdates = true
        }
        
        startLocationMonitoringObserver = notificationCentre.addObserver(forName: NSNotification.Name(rawValue: Notifications.StartLocationMonitoring),
                                                                         object: nil,
                                                                         queue: nil)
        {
            (note) in
            self.startLocationMonitoring()
        }
        
        stopLocationMonitoringObserver = notificationCentre.addObserver(forName: NSNotification.Name(rawValue: Notifications.StopLocationMonitoring),
                                                                         object: nil,
                                                                         queue: nil)
        {
            (note) in
            self.stopLocationMonitoring()
        }
        
        startBeaconMonitoringObserver = notificationCentre.addObserver(forName: NSNotification.Name(rawValue: Notifications.StartBeaconMonitoring),
                                                                         object: nil,
                                                                         queue: nil)
        {
            (note) in
            self.startBeaconMonitoring()
        }
        
        stopBeaconMonitoringObserver = notificationCentre.addObserver(forName: NSNotification.Name(rawValue: Notifications.StopBeaconMonitoring),
                                                                         object: nil,
                                                                         queue: nil)
        {
            (note) in
            self.stopBeaconMonitoring()
        }
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any])
    {
        let info    = userInfo["aps"] as! [String: AnyObject]
        let message = info["alert"] as? String
        
        Notifications.postMessage(self, message: message)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings)
    {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register device:", error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registration successful with a device token - \(deviceToken.hexString())")
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification)
    {
        if notification.soundName != nil
        {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        if rangedRegions.count > 0
        {
            locationManager.stopMonitoring(for: rangedRegions[0])
        }
        
        locationManager.stopUpdatingLocation()
        Notifications.removeObserver(startLocationMonitoringObserver, from: notificationCentre)
        Notifications.removeObserver(stopLocationMonitoringObserver, from: notificationCentre)
        Notifications.removeObserver(startBeaconMonitoringObserver, from: notificationCentre)
        Notifications.removeObserver(stopBeaconMonitoringObserver, from: notificationCentre)
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager)
    {
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager)
    {
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit)
    {
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)
    {
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool
    {
        return (false)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion)
    {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        currentLocation = locations.last!
        postLocation(currentLocation)
        Notifications.postLocationUpdated(self, location: currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?)
    {
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        /*
        let statusName : String!
        
        switch(status)
        {
        case .authorizedAlways:
            statusName = "always"
        case .authorizedWhenInUse:
            statusName = "when in use"
        case .denied:
            statusName = "denines"
        case .notDetermined:
            statusName = "not determined"
        case .restricted:
            statusName = "restricted"
        }
         
         print(statusName)
        */
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion)
    {
        var previousState: CLRegionState?
        
        if state != previousState
        {
            previousState = state
            
            switch(state)
            {
            case .inside:
                locationManager.startRangingBeacons(in: region as! CLBeaconRegion)
            case .outside:
                locationManager.stopRangingBeacons(in: region as! CLBeaconRegion)
            case .unknown:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        let state = UIApplication.shared.applicationState
        var foundBeacon : CLBeacon? = nil

        if beacons.contains(where: {
            (beacon) -> Bool in
            
            let major = Int(beacon.major)
            let minor = Int(beacon.minor)
            
            foundBeacon = beacon
            
            return major == desiredMajor &&
                   minor == desiredMinor
        })
        {
            if !isInRange || (!foo && foundBeacon?.rssi != 0)
            {
                isInRange = true
                State.sendLocatedNotificationToCircle()
                Notifications.postBeaconNearby(self, location: currentLocation)
            }
        }
        else
        {
            isInRange = false
            Notifications.postBeaconNotNearby(self, location: currentLocation)
        }
        
        if isInRange
        {
            if foundBeacon?.rssi == 0
            {
                if foo
                {
                    foo = false
                    Notifications.postBeaconNotRanged(self)
                }
            }
            else
            {
                foo = true
                Notifications.postBeaconRanged(self, rssi: foundBeacon!.rssi, location: currentLocation)
            }
        }
        
        if state == .active
        {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error)
    {
        print("monitoringDidFailFor \(region?.identifier) \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error)
    {
        print("rangingBeaconsDidFailFor \(error)")
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        /*
        let stateName : String!
        
        switch(peripheral.state)
        {
        case .poweredOff:
            stateName = "off"
        case .poweredOn:
            stateName = "on"
        case .resetting:
            stateName = "resetting"
        case .unauthorized:
            stateName = "unauthorized"
        case .unsupported:
            stateName = "unsupported"
        case .unknown:
            stateName = "unknown"
        }
        
        print("peripheralManagerDidUpdateState \(stateName!)")
         */
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager)
    {
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?)
    {
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest)
    {
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any])
    {
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?)
    {
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest])
    {
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic)
    {
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    {
    }
    
    // MARK: internal
    
    fileprivate func startLocationMonitoring()
    {
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
    }
    
    fileprivate func stopLocationMonitoring()
    {
        locationManager.stopUpdatingLocation()
    }
    
    fileprivate func startBeaconMonitoring()
    {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)
        {
            if CLLocationManager.isRangingAvailable()
            {
                let status = CLLocationManager.authorizationStatus()
                let region = CLBeaconRegion(proximityUUID: NSUUID(uuidString: "3724386F-04BF-427D-A4AD-34B4586791B5")! as UUID, identifier: "crowdping")
                
                region.notifyOnEntry = true
                region.notifyOnExit  = true
                region.notifyEntryStateOnDisplay = true
                rangedRegions.append(region)
                
                if status == .authorizedAlways
                {
                    locationManager.startMonitoring(for: region)
                    let delayTime = DispatchTime.now() + .seconds(1)
                    
                    DispatchQueue.main.asyncAfter(deadline:delayTime)
                    {
                        self.locationManager.requestState(for: region)
                    }
                }
            }
        }
    }
    
    fileprivate func stopBeaconMonitoring()
    {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)
        {
            if CLLocationManager.isRangingAvailable()
            {
                rangedRegions.forEach(
                    {
                        (region) in
                        self.locationManager.stopRangingBeacons(in: region)
                        self.locationManager.stopMonitoring(for: region)
                    })
            }
            
            rangedRegions.removeAll()
        }
    }
    
    fileprivate func postLocation(_ currentLocation : CLLocation!)
    {
        let parameters : [String : AnyObject] = [
            "major"     : desiredMajor! as AnyObject,
            "minor"     : desiredMinor! as AnyObject,
            "latitude"  : currentLocation.coordinate.latitude as AnyObject,
            "longitude" : currentLocation.coordinate.longitude as AnyObject,
        ]
        
        post(parameters)
    }
    
    fileprivate func post(_ parameters: [String : AnyObject]!)
    {
        // log.debug("enter")
        
        var newParameters = parameters
        
        newParameters?["whence"] = Int(Date().timeIntervalSince1970) as AnyObject?
        
        Alamofire.request("https://api.mlab.com/api/1/databases/crowdping/collections/locations/?apiKey=\(APIKey)",
            method: .post,
            parameters: newParameters,
            encoding: JSONEncoding.default).responseJSON
            {
                (response) in

                if let error = response.result.error as? NSError
                {
                    print("Unresolved error \(error.userInfo)")
                }
            }   
    }
}
