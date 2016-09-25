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
        let headers: HTTPHeaders = [
            "Authorization": "key=AIzaSyA-1cAHNGqjcpX8G8ybAUht1Cc08m2m6dg",
            "Content-Type": "application/json"
        ]
        
        let parameters: Parameters =
            [
                "to" : "eX7jEHCS4Tw:APA91bGE6m-EdmCYUJSBzWI9T10wkj3T01oGclCc6FbuzhxJ0uf1FRRq5lQ-ra1kWO6GfySA4mp87KA4DTAWgdzHdxN8NMm07taRGXzcKu5jLNuxb8KFn9oSJe3G7EqsfTDCatElM492",
                "data": [
                    "Alert": "wake up!"
                ]
        ]
        
        // All three of these calls are equivalent
        Alamofire.request("https://fcm.googleapis.com/fcm/send",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers).responseJSON
            {
                (response) in
                
                if let requestBody = response.request?.httpBody
                {
                    do {
                        let jsonArray = try JSONSerialization.jsonObject(with: requestBody, options: [])
                        print("Array: \(jsonArray)")
                    }
                    catch {
                        print("Error: \(error)")
                    }
                }
                
                print("A " + String(describing: response.request?.httpBody))
                print("B " + String(describing: response.response))
                print("C " + String(describing: response.data))
                print("D " + String(describing: response.result))
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
