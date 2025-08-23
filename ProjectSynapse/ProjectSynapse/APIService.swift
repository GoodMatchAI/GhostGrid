//
//  APIService.swift
//  ProjectSynapse
//
//  Created by Denis Bystruev on 8/23/25.
//

import Foundation

// A simple structure to match the JSON response from our server
struct APIResponse: Codable {
    let response: String
}

// A simple structure to encode our outgoing message
struct APIRequest: Codable {
    let message: String
}

class APIService {
    static let shared = APIService() // Singleton for easy access
    
    private let apiURL = URL(string: "https://ghost.hurated.com/interact")!
    
    // Asynchronous function to send a message and receive a response
    func sendMessage(_ message: String) async throws -> String {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode the outgoing message into JSON
        let requestBody = APIRequest(message: message)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        // Perform the network request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Ensure we got a successful HTTP response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decode the JSON response from the server
        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        
        return apiResponse.response
    }
}
