//
//  ContentView.swift
//  ProjectSynapse
//
//  Created by Denis Bystruev on 8/23/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // State to hold the missions fetched from the server
    @State private var missions: [Mission] = []
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            
            // The map now reads from the @State variable
            ForEach(missions) { mission in
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
        .task {
            // Use .task for modern async calls when the view appears
            await loadMissions()
        }
        .sheet(item: $locationManager.activeMission) { mission in
            // When the sheet is dismissed, clear the active mission
            InteractionView(mission: mission)
                .onDisappear {
                    locationManager.activeMission = nil
                }
        }
    }
    
    private func loadMissions() async {
        do {
            let fetchedMissions = try await APIService.shared.fetchMissions()
            self.missions = fetchedMissions
            // Once missions are loaded, tell the LocationManager to start monitoring them
            locationManager.startMonitoring(missions: fetchedMissions)
        } catch {
            print("🔴 Failed to fetch missions: \(error)")
            // Optionally, show an error to the user
        }
    }
}
