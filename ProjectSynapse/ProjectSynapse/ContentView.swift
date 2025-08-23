//
//  ContentView.swift
//  ProjectSynapse
//
//  Created by Denis Bystruev on 8/23/25.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        Map(position: $position) {
            // Show the user's location with the default blue dot
            UserAnnotation()
            
            // Show all the mission locations with a custom pin
            ForEach(missionLocations) { mission in
                Annotation(mission.name, coordinate: mission.coordinate) {
                    Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .indigo)
                        .font(.title)
                        .shadow(radius: 3)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .ignoresSafeArea()
        .onAppear {
            locationManager.requestAuthorization()
        }
        .onChange(of: locationManager.lastKnownLocation) { _, newLocation in
            // This ensures the map stays centered on the user if they move.
            if let newLocation {
                position = .camera(
                    MapCamera(centerCoordinate: newLocation.coordinate, distance: 2000, heading: 0, pitch: 60)
                )
            }
        }
    }
}
