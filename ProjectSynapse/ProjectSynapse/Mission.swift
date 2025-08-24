//
//  Mission.swift
//  ProjectSynapse
//
//  Created by Denis Bystruev on 8/23/25.
//

import Foundation
import CoreLocation

struct Mission: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let radius: CLLocationDistance
    let characterID: String // <-- ADD THIS LINE
}

// Hard-coded mission locations
let missionLocations = [
    Mission(name: "Echo at Coit Tower",
            coordinate: CLLocationCoordinate2D(latitude: 37.8024, longitude: -122.4058),
            radius: 100,
            characterID: "digital_historian"),
    
    Mission(name: "Echo at Ferry Building",
            coordinate: CLLocationCoordinate2D(latitude: 37.7956, longitude: -122.3937),
            radius: 100,
            characterID: "digital_historian"),
    
    Mission(name: "Echo at 1524 Powell St",
            coordinate: CLLocationCoordinate2D(latitude: 37.799128, longitude: -122.410260),
            radius: 100,
            characterID: "paranoid_cryptographer"),
    
    Mission(name: "Echo at Alamo Square",
            coordinate: CLLocationCoordinate2D(latitude: 37.7761, longitude: -122.4349),
            radius: 100,
            characterID: "paranoid_cryptographer")
]
