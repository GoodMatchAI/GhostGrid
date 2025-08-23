//
//  Mission.swift
//  ProjectSynapse
//
//  Created by Denis Bystruev on 8/23/25.
//

import CoreLocation

struct Mission: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

// Hard-coded mission locations in San Francisco for our prototype
let missionLocations = [
    Mission(name: "Echo at Coit Tower", coordinate: CLLocationCoordinate2D(latitude: 37.8024, longitude: -122.4058)),
    Mission(name: "Echo at Ferry Building", coordinate: CLLocationCoordinate2D(latitude: 37.7956, longitude: -122.3937)),
    Mission(name: "Echo at City Hall", coordinate: CLLocationCoordinate2D(latitude: 37.7792, longitude: -122.4194)),
    Mission(name: "Echo at Alamo Square", coordinate: CLLocationCoordinate2D(latitude: 37.7761, longitude: -122.4349))
]
