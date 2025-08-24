//
//  Mission.swift
//  ProjectSynapse
//
//  Created by Denis Bystruev on 8/23/25.
//

import Foundation
import CoreLocation

// Helper struct for decoding coordinates from the server's JSON
struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
}

// The main Mission struct, now fully Codable to match the server's response.
// It no longer needs to be Identifiable in the same way, as we fetch the data.
struct Mission: Codable, Identifiable {
    let id: String
    let name: String
    let radius: CLLocationDistance
    let location: Coordinate
    
    // This computed property is a convenient way to get the CLLocationCoordinate2D
    // that MapKit needs, directly from the decoded location data.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
    }
}
