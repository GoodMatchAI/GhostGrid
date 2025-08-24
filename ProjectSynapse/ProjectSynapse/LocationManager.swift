//
//  LocationManager.swift
//  ProjectSynapse
//
//  Created by Denis Bystruev on 8/23/25.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastKnownLocation: CLLocation?
    @Published var activeMission: Mission? = nil
    
    // Store the missions fetched from the server
    private var monitoredMissions: [Mission] = []
    
    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startMonitoring(missions: [Mission]) {
        self.monitoredMissions = missions // Store the fetched missions
        
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            // Stop monitoring any old regions before starting new ones
            for region in locationManager.monitoredRegions {
                locationManager.stopMonitoring(for: region)
            }
            
            for mission in missions {
                let region = CLCircularRegion(center: mission.coordinate, radius: mission.radius, identifier: mission.id)
                region.notifyOnEntry = true
                region.notifyOnExit = false
                locationManager.startMonitoring(for: region)
                locationManager.requestState(for: region)
                print("🔵 Started monitoring for mission: \(mission.name)")
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        handleRegionEvent(for: region)
    }
    
    // --- THIS IS THE FIX ---
    // The old version of this method was referencing the deleted 'missionLocations' array.
    // This new version correctly uses the 'self.monitoredMissions' property.
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let mission = self.monitoredMissions.first(where: { $0.id == region.identifier }) else { return }
        print("❌ Player EXITED a mission zone: \(mission.name)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            handleRegionEvent(for: region)
        }
    }
    
    private func handleRegionEvent(for region: CLRegion) {
        // Use the stored missions for lookup
        guard let mission = self.monitoredMissions.first(where: { $0.id == region.identifier }) else { return }
        
        DispatchQueue.main.async {
            if self.activeMission == nil {
                print("✅ TRIGGERING mission: \(mission.name)")
                self.activeMission = mission
            }
        }
    }
}
