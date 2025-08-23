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
        guard let mission = missionLocations.first(where: { $0.id.uuidString == region.identifier }) else { return }
        print("✅ PLAYER ENTERED a mission zone: \(mission.name)")
        // This is where we will eventually trigger the interaction with the AI
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let mission = missionLocations.first(where: { $0.id.uuidString == region.identifier }) else { return }
        print("❌ Player EXITED a mission zone: \(mission.name)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            guard let mission = missionLocations.first(where: { $0.id.uuidString == region.identifier }) else { return }
            print("📱 PLAYER STARTED INSIDE a mission zone: \(mission.name)")
            // We can now trigger the same interaction logic as didEnterRegion
        }
    }
}
