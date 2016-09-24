//
//  LocationAnotation.swift
//  crowdping
//
//  Created by D'Arcy Smith on 2016-09-24.
//  Copyright © 2016 TerraTap Technologies, Inc. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class LocationAnotation : NSObject, MKAnnotation
{
    let coordinate: CLLocationCoordinate2D
    let found : Bool
    
    init(_ coordinate: CLLocationCoordinate2D!, found : Bool)
    {
        self.coordinate = coordinate
        self.found      = found
        super.init()
    }
}
