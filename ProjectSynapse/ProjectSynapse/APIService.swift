//
//  APIService.swift
//  ProjectSynapse
//
//  Created by Denis Bystruev on 8/23/25.
//

import Foundation

// A simple structure to match the JSON response from our server for chat
struct APIResponse: Codable {
    let response: String
}

// A simple structure to encode our outgoing message for chat
struct APIRequest: Codable {
    let message: String
}

class APIService {
    static let shared = APIService() // Singleton for easy access
    
    // The base URL for your backend server
    private let baseURL = "https://ghost.hurated.com"
    
    /// Fetches the list of all available missions from the server.
    func fetchMissions() async throws -> [Mission] {
        guard let url = URL(string: baseURL + "/missions") else {
            throw URLError(.badURL)
        }
        
        // --- THIS IS THE FIX ---
        // We must create a URLRequest object for the data task.
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Also ensure the fetch missions call gets a successful response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decode an array of Mission objects from the JSON data
        let missions = try JSONDecoder().decode([Mission].self, from: data)
        return missions
    }
    
    /// Sends a message to the AI character associated with a specific mission.
    func sendMessage(_ message: String, to missionID: String) async throws -> String {
        guard let apiURL = URL(string: baseURL + "/interact/" + missionID) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = APIRequest(message: message)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        return apiResponse.response
    }
}
