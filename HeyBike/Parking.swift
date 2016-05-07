//
//  Parking.swift
//  HeyBike
//
//  Created by Niklas Gundlev on 07/05/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class Parking: Object, Comparable {
    
    dynamic var lat: Double = 0
    dynamic var lng: Double = 0
    dynamic var comment: String = ""
    dynamic var parkingId: String = ""
    dynamic var timestamp: Int = 0
    
    func fill(lat: Double, lng: Double, comment: String, timeStamp: Int, parkingId: String) {
        self.lat = lat
        self.lng = lng
        self.comment = comment
        self.timestamp = timeStamp
        self.parkingId = parkingId
    }
    
//    func createAnomation() -> MKAnnotation {
//        
//    }
}

func < (lhs: Parking, rhs: Parking) -> Bool {
    return lhs.timestamp < rhs.timestamp
}

func == (lhs: Parking, rhs: Parking) -> Bool {
    return lhs.timestamp == rhs.timestamp
}
