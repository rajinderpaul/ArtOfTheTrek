//
//  Trip.swift
//  ArtOfTheTrek
//
//  Created by Rajinder on 12/03/20.
//  Copyright © 2020 appzpixel. All rights reserved.
//

import Foundation
import CodableFirebase
import RxDataSources

public struct Trip: Codable {

    let name: String!
    let startDate: Double!
    let endDate: Double!
    var id: String? = nil
}


extension Trip: IdentifiableType {
    public var identity: String {
        return "\(Date().timeIntervalSince1970)"
    }
}

extension Trip: Equatable { }

public func == (lhs: Trip, rhs: Trip) -> Bool { return lhs.name == rhs.name }

enum TripType: Int {
    case all = 0, upcoming, active, past
}

struct SectionOfTrips {
    
  var header: String
  var items: [Item]
}

extension SectionOfTrips: AnimatableSectionModelType {
    
    typealias Item = Trip
    
    var identity: String {
           return ""
       }
    
    init(original: SectionOfTrips, items: [Trip]) {
        self = original
        self.items = items
    }
}



