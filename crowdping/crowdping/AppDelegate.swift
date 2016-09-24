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
    var isRanging = false
    var isUpdating = false
    var beaconsSeen : [(major : Int, minor : Int)] = []
    var newBeacons : [(major : Int, minor : Int)] = []
    var clearBeacons = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        print("didFinishLaunchingWithOptions")
        
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
            print("allowsBackgroundLocationUpdates")
            locationManager.allowsBackgroundLocationUpdates = true
        }
        
        if #available(iOS 10.0, *)
        {
        }
        else if #available(iOS 8.0, *)
        {
            
            let settings = UIUserNotificationSettings(types: [ .alert, .badge, .sound ], categories: nil)
            application.registerUserNotificationSettings(settings)
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
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings)
    {
        print("didRegister")
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification)
    {
        print("******************************************************************")
        
        if notification.soundName != nil
        {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("applicationWillResignActive \(isRanging)")
        
        if isRanging
        {
            let state = UIApplication.shared.applicationState
            let stateName: String!
            
            switch(state)
            {
            case UIApplicationState.active:
                stateName = "Active"
            case UIApplicationState.background:
                stateName = "Background"
            case UIApplicationState.inactive:
                stateName = "Inactive"
            }
            
            print("starting updating locations A \(stateName!)")
            locationManager.stopUpdatingLocation()
            locationManager.startUpdatingLocation()
            isUpdating = true
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
        
        if isUpdating
        {
            print("stopping updating locations A")
            locationManager.stopUpdatingLocation()
            isUpdating = false
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        locationManager.stopMonitoring(for: rangedRegions[0])
        locationManager.stopUpdatingLocation()
        isUpdating = false
        Notifications.removeObserver(startLocationMonitoringObserver, from: notificationCentre)
        Notifications.removeObserver(stopLocationMonitoringObserver, from: notificationCentre)
        Notifications.removeObserver(startBeaconMonitoringObserver, from: notificationCentre)
        Notifications.removeObserver(stopBeaconMonitoringObserver, from: notificationCentre)
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager)
    {
        print("locationManagerDidPauseLocationUpdates")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager)
    {
        print("locationManagerDidResumeLocationUpdates")
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit)
    {
        print("didVisit")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)
    {
        print("didExitRegion \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
        print("didEnterRegion \(region.identifier)")
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool
    {
        print("locationManagerShouldDisplayHeadingCalibration")
        
        return (false)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion)
    {
        print("didStartMonitoringFor \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    {
        print("didUpdateHeading")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        print("didUpdateLocations")
        
        let location = locations.last!
        print("GPS \(location.coordinate)")
        
        Notifications.postBeaconNearby(self, location: location)

        /*
        newBeacons.forEach {
            (beacon) in
            print("uploading GPS for \(beacon.major).\(beacon.minor) - \(locations[0].coordinate)")
        }
        
        newBeacons.removeAll()
        
        if clearBeacons
        {
            beaconsSeen.removeAll()
            clearBeacons = false
        }
        */
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?)
    {
        print("didFinishDeferredUpdatesWithError")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
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
        
        print("didChangeAuthorization \(statusName!)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion)
    {
        print("didDetermineState \(region.identifier)")
        
        var previousState: CLRegionState?
        
        if state != previousState
        {
            previousState = state
            
            switch(state)
            {
            case .inside:
                print("inside")
                locationManager.startRangingBeacons(in: region as! CLBeaconRegion)
                isRanging = true
            case .outside:
                print("outside")
                locationManager.stopRangingBeacons(in: region as! CLBeaconRegion)
                isRanging = false
            case .unknown:
                print("unknown")
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        print("didRangeBeacons \(beacons.count)")
        
        let state = UIApplication.shared.applicationState
        
        beacons.forEach {
            (beacon) in
            // print("\(beacon.major) \(beacon.minor) \(beacon.rssi) \(beacon.accuracy)")
            
            let major = Int(beacon.major)
            let minor = Int(beacon.minor)
            
            if !(beaconsSeen.contains(
                where:
                {
                    (info) in
                    
                    return info.major == major &&
                           info.minor == minor
                }))
            {
                let beaconInfo = (major, minor)
                
                newBeacons.append(beaconInfo)
                beaconsSeen.append(beaconInfo)
            }
        }

        Notifications.postBeaconRanged(self, rssi: beacons[0].rssi)
        
        if newBeacons.count > 0
        {
//            print("asking for location")
//            locationManager.requestLocation()
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
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager)
    {
        print("toUpdateSubscribers")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?)
    {
        print("peripheralManagerDidStartAdvertising")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest)
    {
        print("didReceiveRead")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any])
    {
        print("willRestoreState")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?)
    {
        print("didAdd")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest])
    {
        print("didReceiveWrite")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic)
    {
        print("didSubscribeTo")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    {
        print("didUnsubscribeFrom")
    }
    
    // MARK: internal
    
    fileprivate func startLocationMonitoring()
    {
        print("startLocationMonitoring")
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
    }
    
    fileprivate func stopLocationMonitoring()
    {
        print("stopLocationMonitoring")
        locationManager.stopUpdatingLocation()
    }
    
    fileprivate func startBeaconMonitoring()
    {
        print("startBeaconMonitoring")
        
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
        print("stopBeaconMonitoring")
        
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)
        {
            if CLLocationManager.isRangingAvailable()
            {
                rangedRegions.forEach(
                    {
                        (region) in
                        print("Stopping monitoring for \(region.identifier)")
                        self.locationManager.stopRangingBeacons(in: region)
                        self.locationManager.stopMonitoring(for: region)
                    })
            }
            
            rangedRegions.removeAll()
        }
    }
}
