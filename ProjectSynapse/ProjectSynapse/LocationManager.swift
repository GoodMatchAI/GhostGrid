//
//  LocationManager.swift
//  ProjectSynapse
//
//  Created by Denis Bystruev on 8/23/25.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastKnownLocation: CLLocation?
    @Published var activeMission: Mission? = nil
    
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
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            for mission in missions {
                let region = CLCircularRegion(center: mission.coordinate, radius: mission.radius, identifier: mission.id.uuidString)
                region.notifyOnEntry = true
                region.notifyOnExit = false // We only care when they enter
                locationManager.startMonitoring(for: region)
                locationManager.requestState(for: region)
                print("🔵 Started monitoring for mission: \(mission.name)")
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            startMonitoring(missions: missionLocations)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("--- Delegate Fired: didEnterRegion for identifier: \(region.identifier)")
        handleRegionEvent(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let mission = missionLocations.first(where: { $0.id.uuidString == region.identifier }) else { return }
        print("❌ Player EXITED a mission zone: \(mission.name)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("--- Delegate Fired: didDetermineState is '\(state == .inside ? "inside" : "outside")'")
        if state == .inside {
            handleRegionEvent(for: region)
        }
    }
    
    private func handleRegionEvent(for region: CLRegion) {
        print("--- Searching for match for region identifier: \(region.identifier)")
        print("--- Available mission IDs are:")
        for mission in missionLocations {
            print("    - \(mission.id.uuidString)")
        }
        
        guard let mission = missionLocations.first(where: { $0.id.uuidString == region.identifier }) else { return }
        
        // UI updates must be on the main thread
        DispatchQueue.main.async {
            // Only trigger if a mission isn't already active
            if self.activeMission == nil {
                print("✅ TRIGGERING mission: \(mission.name)")
                self.activeMission = mission
            } else {
                print("🟡 IGNORED trigger for \(mission.name), another mission is already active.")
            }
        }
    }
}
