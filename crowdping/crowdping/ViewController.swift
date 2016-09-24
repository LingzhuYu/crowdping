//
//  ViewController.swift
//  crowdping
//
//  Created by D'Arcy Smith on 2016-09-23.
//  Copyright © 2016 TerraTap Technologies, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var beaconButton: UIButton!
    @IBOutlet weak var locationButon: UIButton!
    
    fileprivate var locationMonitoring = false
    fileprivate var beaconMonitoring = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
}
