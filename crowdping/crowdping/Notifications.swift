//
//  Notifications.swift
//  crowdping
//
//  Created by D'Arcy Smith on 2016-09-24.
//  Copyright © 2016 TerraTap Technologies, Inc. All rights reserved.
//

//
//  Notifications.swift
//  neartuit
//
//  Created by D'Arcy Smith on 2016-02-10.
//  Copyright © 2016 D'Arcy Smith. All rights reserved.
//

import CoreLocation

class Notifications
{
    fileprivate static let notificationCentre = NotificationCenter.default
    static let StartLocationMonitoring = "StartLocationMonitoring"
    static let StopLocationMonitoring = "StopLocationMonitoring"
    static let StartBeaconMonitoring = "StartBeaconMonitoring"
    static let StopBeaconMonitoring = "StopBeaconMonitoring"
    static let BeaconNearby = "BeaconNearby"
    static let BeaconNotNearby = "BeaconNotNearby"
    static let BeaconRanged = "BeaconRanged"
    static let BeaconNotRanged = "BeaconNotRanged"
    static let LocationUpdated = "LocationUpdated"
    static let Message = "Message"
    
    static func removeObserver(_ observer: AnyObject?, from: NotificationCenter!)
    {
        if let observer = observer
        {
            from.removeObserver(observer)
        }
    }
    
    fileprivate static func post(_ messageName: String!, object: AnyObject?, userInfo: [AnyHashable: Any]? = nil)
    {
        notificationCentre.post(name: Notification.Name(rawValue: messageName), object: object, userInfo: userInfo)
    }
    
    static func postStartLocationMonitoring(_ object: AnyObject?)
    {
        post(StartLocationMonitoring, object: object)
    }
    
    static func postStopLocationMonitoring(_ object: AnyObject?)
    {
        post(StopLocationMonitoring, object: object)
    }
    
    static func postStartBeaconMonitoring(_ object: AnyObject?)
    {
        post(StartBeaconMonitoring, object: object)
    }
    
    static func postStopBeaconMonitoring(_ object: AnyObject?)
    {
        post(StopBeaconMonitoring, object: object)
    }
    
    static func postBeaconNearby(_ object: AnyObject?, location: CLLocation!)
    {
        let userInfo =
            [
                "location" : location
        ]
        
        post(BeaconNearby, object: object, userInfo: userInfo)
    }
    
    static func postBeaconNotNearby(_ object: AnyObject?, location: CLLocation!)
    {
        let userInfo =
            [
                "location" : location
            ]
        
        post(BeaconNotNearby, object: object, userInfo: userInfo)
    }
    
    static func postBeaconRanged(_ object: AnyObject?, rssi : Int, location: CLLocation?)
    {
        // BUG - why is location nil sometimes?
        if let location = location
        {
            let userInfo =
                [
                    "rssi"     : rssi,
                    "location" : location
                ] as [String : Any]
            
            post(BeaconRanged, object: object, userInfo: userInfo)
        }
    }
    
    static func postBeaconNotRanged(_ object: AnyObject?)
    {
        post(BeaconNotRanged, object: object)
    }
    
    static func postLocationUpdated(_ object: AnyObject?, location: CLLocation!)
    {
        let userInfo =
            [
                "location" : location
        ]
        
        post(LocationUpdated, object: object, userInfo: userInfo)
    }
    
    static func postMessage(_ object: AnyObject?, message: String!)
    {
        let userInfo =
            [
                "message" : message
            ]
        
        post(Message, object: object, userInfo: userInfo)
    }
    
    static func getLocation(_ notification: Notification!) -> CLLocation?
    {
        let location = notification.userInfo?["location"] as? CLLocation
        
        return location
    }
    
    static func getRssi(_ notification: Notification!) -> Int?
    {
        let rssi = notification.userInfo?["rssi"] as? Int
        
        return rssi
    }
    
    static func getMessage(_ notification: Notification!) -> String?
    {
        let message = notification.userInfo?["message"] as? String
        
        return message
    }
}
