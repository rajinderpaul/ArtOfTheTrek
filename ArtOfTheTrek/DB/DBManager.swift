//
//  DBManager.swift
//  ArtOfTheTrek
//
//  Created by Rajinder on 12/03/20.
//  Copyright © 2020 appzpixel. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase
//import RxSwift
//import RxCocoa


class DBManager {
    
    static let shared = DBManager()
    var tripsListner: ListenerRegistration?
    
    private init() {}
    
    
    func addTrip(trip: Trip, completion: @escaping (_ error: Error?)-> Void) {
    
        let data = try! FirestoreEncoder().encode(trip)
        
        Firestore.firestore().collection("Trips").addDocument(data: data) { (error) in
            completion(error)
        }
    }

    func deleteTrip(trip: Trip?, completion: @escaping (_ error: Error?)-> Void) {
    
        Firestore.firestore().collection("Trips").document(trip?.id ?? "").delete() { error in
            completion(error)
        }
    }
    
    func getTrips(tripType: TripType, completion: @escaping (_ trips: [Trip]?,  _ error: Error?)-> Void) {
        
        tripsListner?.remove()
        
        var query: Query?
        
        let currentDate = Date().timeIntervalSince1970
        
        switch tripType {
            
        case .all:
            query = Firestore.firestore().collection("Trips")
            
        case .upcoming:
            query = Firestore.firestore().collection("Trips").whereField("startDate", isGreaterThan: currentDate)
            
        case .active:
            query = Firestore.firestore().collection("Trips").whereField("startDate", isLessThanOrEqualTo: currentDate)

        case .past:
            query = Firestore.firestore().collection("Trips").whereField("endDate", isLessThan: currentDate)
            
        }
        
        
        tripsListner = query?.addSnapshotListener { querySnapshot, error in
            
            if let error = error {
                completion(nil, error)
            } else if var documents = querySnapshot?.documents  {
                
                if tripType == .active {
                    documents = documents.filter { (document) -> Bool in
                        let trip = try! FirestoreDecoder().decode(Trip.self, from: document.data())
                        return trip.endDate >= currentDate
                    }
                }
                
                let trips: [Trip] = documents.map {
                    var trip = try! FirestoreDecoder().decode(Trip.self, from: $0.data())
                    trip.id = $0.documentID
                    return trip
                }
                completion(trips, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
}


