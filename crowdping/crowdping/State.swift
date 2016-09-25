//
//  State.swift
//  crowdping
//
//  Created by D'Arcy Smith on 2016-09-24.
//  Copyright © 2016 TerraTap Technologies, Inc. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Social

class State
{
    static var startTime : NSDate? = nil
    static var isSearching : Bool = false
    static var timer : Timer?
    static var beaconFound = false
    
    fileprivate static func sendNotificationToCircle(_ message: String!)
    {
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
    
    static func sendLostNotificationToCircle()
    {
        let message: String = "Grandpa Joe is missing! Help me search!"
        
        sendNotificationToCircle(message)
    }
    
    static func sendLocatedNotificationToCircle()
    {
        let message: String = "Grandpa Joe has been located. Please come to my location and search"
        
        sendNotificationToCircle(message)
    }
    
    static func sendFoundNotificationToCircle()
    {
        let message: String = "Grandpa Joe has been found. Thanks for helping!"
        
        sendNotificationToCircle(message)
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
    }
    
    static func sendToSocial(_ view : UIViewController!)
    {
        print("Social Sharing")
        let actionSheet = UIAlertController(title: "",
                                            message: "Share your Note",
                                            preferredStyle: .actionSheet)
        // Configure a new action for sharing the note in Twitter.
        let tweetAction = UIAlertAction(title: "Share on Twitter", style: UIAlertActionStyle.default) { (action) -> Void in
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc!.setInitialText("We're helping people find lost Alzheimer's patients! Please like @crowd_ping and join the search test #HackVSW")
            view.present(vc!, animated: true, completion: nil)
        }
        
        // Configure a new action to share on Facebook.
        let facebookPostAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.default) { (action) -> Void in
            let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            vc!.setInitialText("This is a test from the hackathon")
            view.present(vc!, animated: true, completion: nil)
        }
        
        let dismissAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (action) -> Void in
        }
        
        actionSheet.addAction(facebookPostAction)
        actionSheet.addAction(tweetAction)
        actionSheet.addAction(dismissAction)
        
        view.present(actionSheet, animated: true, completion: nil)
    }
}
