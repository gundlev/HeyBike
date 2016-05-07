//
//  MapPin.swift
//  HeyBike
//
//  Created by Niklas Gundlev on 07/05/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import MapKit

class MapPin : NSObject, MKAnnotation, Comparable {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage?
    var timestamp: Int
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, image: UIImage?, timestamp: Int) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.timestamp = timestamp
    }
}

func <(lhs: MapPin, rhs: MapPin) -> Bool {
    return lhs.timestamp < rhs.timestamp
}

func ==(lhs: MapPin, rhs: MapPin) -> Bool {
    return lhs.timestamp == rhs.timestamp
}