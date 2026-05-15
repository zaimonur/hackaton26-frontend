//
//  ProductAssistantDTO.swift
//  drewisy
//
//  Created by Onur Zaim on 15.05.2026.
//

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct ProductAskRequest: Encodable {
    let question: String
}

struct ProductAskResponse: Decodable {
    let answer: String
}
