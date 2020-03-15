//
//  TripViewModel.swift
//  ArtOfTheTrek
//
//  Created by Rajinder on 13/03/20.
//  Copyright © 2020 appzpixel. All rights reserved.
//

import Foundation
import CodableFirebase

class TripViewModel: Codable {
    
//    private var trips: [Trip]?

    private var trip: Trip
    
    init(trip: Trip) {

        self.trip = trip
    }
 
    var name: String {

        return trip.name
    }

    var startDate: String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"

        let startDate = Date(timeIntervalSince1970: trip.startDate ?? 0)
        return dateFormatter.string(from: startDate)
    }

    var endDate: String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"

        let endDate = Date(timeIntervalSince1970: trip.endDate ?? 0)
        return dateFormatter.string(from: endDate)
    }

    
}
