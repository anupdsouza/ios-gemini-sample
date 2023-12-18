//
//  ChatService.swift
//  GeminiChat
//
//  Created by Anup D'Souza on 16/12/23.
//

import Foundation
import SwiftUI
import GoogleGenerativeAI

enum ChatRole {
    case user
    case model
}

struct ChatMessage: Hashable, Identifiable {
    let id = UUID().uuidString
    var role: ChatRole
    var message: String
}

@Observable class ChatService {
    private var model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
    private var chat: Chat?
    private(set) var messages = [ChatMessage]()
    private(set) var loadingResponse = false
    
    func sendMessage(_ message: String) {
        loadingResponse = true
        
        if (chat == nil) {
            let history: [ModelContent] = messages.map { ModelContent(role: $0.role == .user ? "user" : "model", parts: $0.message) }
            chat = model.startChat(history: history)
        }

        messages.append(ChatMessage(role: .user, message: message))
        
        Task {
            do {
                let response = try await chat?.sendMessage(message)
                
                loadingResponse = false
                guard let text = response?.text else  {
                    messages.append(ChatMessage(role: .model, message: "Something went wrong, please try again."))
                    return
                }
                messages.append(ChatMessage(role: .model, message: text))
                
            } catch {
                loadingResponse = false
                messages.append(ChatMessage(role: .model, message: "Something went wrong, please try again."))
            }
        }
    }
}
