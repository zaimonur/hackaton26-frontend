//
//  CommunicationsDTO.swift
//  drewisy
//
//  Created by Onur Zaim on 17.05.2026.
//

import Foundation

struct MessageDTO: Decodable, Identifiable, Equatable {
    let id: String
    let sender_id: String
    let receiver_id: String
    let content: String
    let created_at: String
}

struct SendMessageRequest: Encodable {
    let receiver_id: String
    let content: String
}

struct NotificationDTO: Decodable, Identifiable, Equatable {
    let id: String
    let type: String
    let reference_id: String?
    let title: String
    let body: String
    let is_read: Bool
    let created_at: String
}

// MARK: - WebSocket Event Decoding
enum WSPayload {
    case message(MessageDTO)
    case notification(NotificationDTO)
    case unknown
}

struct WSEvent: Decodable {
    let type: String
    let payload: WSPayload
    
    enum CodingKeys: String, CodingKey {
        case type
        case payload
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "NEW_MESSAGE":
            let message = try container.decode(MessageDTO.self, forKey: .payload)
            self.payload = .message(message)
        case "NEW_NOTIFICATION", "ORDER_UPDATE":
            let notification = try container.decode(NotificationDTO.self, forKey: .payload)
            self.payload = .notification(notification)
        default:
            self.payload = .unknown
        }
    }
}

// MARK: - Inbox DTO
struct InboxItemResponse: Decodable, Identifiable {
    let target_id: String
    let target_name: String
    let target_role: String
    let last_message: String
    let created_at: String
    
    var id: String { target_id }
}
