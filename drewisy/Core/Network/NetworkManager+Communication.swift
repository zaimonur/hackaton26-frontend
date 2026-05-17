//
//  NetworkManager+Communication.swift
//  drewisy
//
//  Created by Onur Zaim on 17.05.2026.
//

import Foundation

extension NetworkManager {
    
    func sendMessage(receiverId: String, content: String, token: String?) async throws -> MessageDTO {
        let body = SendMessageRequest(receiver_id: receiverId, content: content)
        return try await request(
            url: "\(NetworkManager.baseURL)/api/v1/messages",
            method: "POST",
            body: body,
            token: token
        )
    }
    
    func fetchNotifications(token: String?) async throws -> [NotificationDTO] {
        return try await request(
            url: "\(NetworkManager.baseURL)/api/v1/notifications",
            method: "GET",
            body: String?.none, // Generic B için null body
            token: token
        )
    }
    
    func markNotificationAsRead(id: String, token: String?) async throws -> String {
        return try await request(
            url: "\(NetworkManager.baseURL)/api/v1/notifications/\(id)/read",
            method: "PATCH",
            body: String?.none,
            token: token
        )
    }
}
