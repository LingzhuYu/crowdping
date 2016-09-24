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
    static let PersonNearby = "PersonNearby"
    
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
    
    static func postPersonNearby(_ object: AnyObject?, location: CLLocation!)
    {
        let userInfo =
        [
            "location" : location
        ]
        
        post(PersonNearby, object: object, userInfo: userInfo)
    }

    static func getLocation(_ notification: Notification!) -> CLLocation?
    {
        // log.debug("enter")
        let location = notification.userInfo?["Location"] as? CLLocation
        // log.debug("exit")
    
        return location
    }
}
