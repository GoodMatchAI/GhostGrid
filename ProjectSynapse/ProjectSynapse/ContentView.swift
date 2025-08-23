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
            UserAnnotation()
            
            ForEach(missionLocations) { mission in
                // The visual pin for the mission
                Annotation(mission.name, coordinate: mission.coordinate) {
                    Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .indigo)
                        .font(.title)
                        .shadow(radius: 3)
                }
                
                MapCircle(center: mission.coordinate, radius: mission.radius)
                    .foregroundStyle(.indigo.opacity(0.2))
                    .stroke(.indigo.opacity(0.8), lineWidth: 2)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .ignoresSafeArea()
        .onAppear {
            locationManager.requestAuthorization()
        }
        .onChange(of: locationManager.lastKnownLocation) { _, newLocation in
            if let newLocation {
                position = .camera(
                    MapCamera(centerCoordinate: newLocation.coordinate, distance: 2000, heading: 0, pitch: 60)
                )
            }
        }
        .sheet(item: $locationManager.activeMission) { mission in
            InteractionView(mission: mission)
                .presentationDetents([.medium, .large]) // Makes a nice half/full sheet
        }
    }
}
