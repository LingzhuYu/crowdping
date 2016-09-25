//
//  State.swift
//  crowdping
//
//  Created by D'Arcy Smith on 2016-09-24.
//  Copyright © 2016 TerraTap Technologies, Inc. All rights reserved.
//

import Foundation
import Alamofire

class State
{
    static var startTime : NSDate? = nil
    static var isSearching : Bool = false
    static var timer : Timer?
    static var beaconFound = false
    
    static func sendNotificationToCircle()
    {
        let message: String = "Granpa Joe is missing! Help me search!"
        
        print(message)
        
        let parameters : [String : AnyObject] = [
            "message"     : message as AnyObject,
            ]
        
        
        Alamofire.request("http://104.36.149.204/alertpush.php",
                          method: .post,
                          parameters: parameters).response
            {
                (response) in
                
                if let error = response.error as? NSError
                {
                    print("Unresolved error \(error.userInfo)")
                }
        }
    }
    
    static func callPolice()
    {
        if let phoneCallURL = URL(string: "tel://778-822-8242")
        {
            let application = UIApplication.shared
            
            if application.canOpenURL(phoneCallURL)
            {
                application.openURL(phoneCallURL)
            }
        }
    }}
