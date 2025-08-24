//
//  InterationView.swift
//  ProjectSynapse
//
//  Created by Denis Bystruev on 8/23/25.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
}

struct InteractionView: View {
    let mission: Mission // The mission that triggered this view
    
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isThinking: Bool = false
    
    var body: some View {
        VStack {
            // Header
            Text(mission.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // Chat history
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isFromUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                    Spacer()
                                }
                            }
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: messages.count) {
                    // Auto-scroll to the newest message
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input area
            HStack {
                TextField("Send a message...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isThinking)
                
                if isThinking {
                    ProgressView()
                        .padding(.horizontal)
                } else {
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                    }
                    .disabled(inputText.isEmpty)
                }
            }
            .padding()
        }
        .onAppear(perform: startConversation)
    }
    
    private func startConversation() {
        // Initial message from the Echo
        messages.append(ChatMessage(text: "...", isFromUser: false))
        
        Task {
            isThinking = true
            do {
                let initialResponse = try await APIService.shared.sendMessage("I'm here.", to: mission.characterID)
                messages[0] = ChatMessage(text: initialResponse, isFromUser: false)
            } catch {
                messages[0] = ChatMessage(text: "Connection lost... the signal is weak.", isFromUser: false)
            }
            isThinking = false
        }
    }
    
    private func sendMessage() {
        let userMessage = inputText
        messages.append(ChatMessage(text: userMessage, isFromUser: true))
        inputText = ""
        isThinking = true
        
        Task {
            do {
                let response = try await APIService.shared.sendMessage(userMessage, to: mission.characterID)
                messages.append(ChatMessage(text: response, isFromUser: false))
            } catch {
                messages.append(ChatMessage(text: "The signal faded...", isFromUser: false))
            }
            isThinking = false
        }
    }
}
